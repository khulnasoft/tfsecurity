# Core variables #################################
IMAGE := tfsecurity/tfsecurity
MKDOCS_IMAGE := khulnasoft/mkdocs-material:tracker
MKDOCS_PORT := 8000
BIN := tfsecurity
TEMP_DIR := ./.tmp
PWD := ${CURDIR}
PRODUCTION_REGISTRY := docker.io
SHELL := /bin/bash -o pipefail
TEST_IMAGE := busybox:latest

# Tool versions #################################
GOLANG_CI_VERSION := v1.52.2
GOLICENSES := v5.0.1
GORELEASER_VERSION := v1.19.1
GOSIMPORTS_VERSION := v0.3.8
CHRONICLE_VERSION := v0.6.0
GLOW_VERSION := v1.5.0
DOCKER_CLI_VERSION := 23.0.6

# Command templates #################################
LINT_CMD := $(TEMP_DIR)/golangci-lint run --tests=false --timeout=2m --config .golangci.yaml
GOIMPORTS_CMD := $(TEMP_DIR)/gosimports -local github.com/khulnasoft
RELEASE_CMD := DOCKER_CLI_VERSION=$(DOCKER_CLI_VERSION) $(TEMP_DIR)/goreleaser release --clean
SNAPSHOT_CMD := $(RELEASE_CMD) --skip-publish --snapshot --skip-sign
CHRONICLE_CMD := $(TEMP_DIR)/chronicle
GLOW_CMD := $(TEMP_DIR)/glow

# Formatting variables #################################
BOLD := $(shell tput -T linux bold)
PURPLE := $(shell tput -T linux setaf 5)
GREEN := $(shell tput -T linux setaf 2)
CYAN := $(shell tput -T linux setaf 6)
RESET := $(shell tput -T linux sgr0)
TITLE := $(BOLD)$(PURPLE)
SUCCESS := $(BOLD)$(GREEN)

# Test variables #################################
COVERAGE_THRESHOLD := 55

# Build variables #################################
DIST_DIR := dist
SNAPSHOT_DIR := snapshot
OS := $(shell uname | tr '[:upper:]' '[:lower:]')
SNAPSHOT_BIN := $(realpath $(PWD)/$(SNAPSHOT_DIR)/$(OS)-build_$(OS)_amd64_v1/$(BIN))
CHANGELOG := CHANGELOG.md
VERSION := $(shell git describe --dirty --always --tags)

ifeq "$(strip $(VERSION))" ""
 override VERSION := $(shell git describe --always --tags --dirty)
endif

## Helper function #################################
define title
    @printf '$(TITLE)$(1)$(RESET)\n'
endef

# Targets #########################################

## Primary targets #################################
.PHONY: all
all: clean static-analysis test ## Run all static analysis and tests
	@printf '$(SUCCESS)All checks pass!$(RESET)\n'

.PHONY: build
build:
	./scripts/build.sh

.PHONY: generate-docs
generate-docs:
	@go run ./cmd/tfsecurity-docs

.PHONY: publish-docs
publish-docs: generate-docs
	@python3 ./scripts/build_checks_nav.py


.PHONY: tagger
tagger:
	@git checkout master
	@git fetch --tags
	@echo "the most recent tag was `git describe --tags --abbrev=0`"
	@echo ""
	read -p "Tag number: " TAG; \
	 git tag -a "$${TAG}" -m "$${TAG}"; \
	 git push origin "$${TAG}"

.PHONY: typos
typos:
	which codespell || pip install codespell
	codespell -S _examples,.tfsecurity,.terraform,.git,go.sum --ignore-words .codespellignore -f

.PHONY: quality
quality:
	which golangci-lint || go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.46.2
	golangci-lint run

.PHONY: fix-typos
fix-typos:
	which codespell || pip install codespell
	codespell -S .terraform,go.sum --ignore-words .codespellignore -f -w -i1

.PHONY: clone-image-github
clone-image-github:
	./scripts/clone-images.sh ghcr.io/khulnasoft

.PHONY: pr-ready
pr-ready: quality typos

.PHONY: bench
bench:
	go test -run ^$$ -bench . ./...

# Runs MkDocs dev server to preview the docs page before it is published.
.PHONY: mkdocs-serve
mkdocs-serve:
	docker build -t $(MKDOCS_IMAGE) -f docs/Dockerfile docs
	docker  run --name mkdocs-serve --rm -v $(PWD):/docs -p $(MKDOCS_PORT):8000 $(MKDOCS_IMAGE)

.PHONY: update-defsec
update-defsec:
	go get github.com/khulnasoft-lab/defsec@latest
	go mod tidy

## Bootstrapping targets #################################

.PHONY: bootstrap-tools
bootstrap-tools: $(TEMP_DIR)
	$(call title,Bootstrapping tools)
	curl -sSfL https://raw.githubusercontent.com/anchore/chronicle/main/install.sh | sh -s -- -b $(TEMP_DIR)/ $(CHRONICLE_VERSION)
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(TEMP_DIR)/ $(GOLANG_CI_VERSION)
	curl -sSfL https://raw.githubusercontent.com/khulnasoft/go-licenses/master/golicenses.sh | sh -s -- -b $(TEMP_DIR)/ $(GOLICENSES)
	GOBIN="$(realpath $(TEMP_DIR))" go install github.com/goreleaser/goreleaser@$(GORELEASER_VERSION)
	GOBIN="$(realpath $(TEMP_DIR))" go install github.com/rinchsan/gosimports/cmd/gosimports@$(GOSIMPORTS_VERSION)
	GOBIN="$(realpath $(TEMP_DIR))" go install github.com/charmbracelet/glow@$(GLOW_VERSION)

.PHONY: bootstrap-go
bootstrap-go:
	$(call title,Bootstrapping go dependencies)
	go mod download

.PHONY: bootstrap
bootstrap: bootstrap-go bootstrap-tools ## Download and install all go dependencies (+ prep tooling in the ./tmp dir)


## Testing #########################################
.PHONY: test
test: unit ## Run unit tests

.PHONY: unit
unit:
	$(call title,Running unit tests)
	go test -race -coverprofile $(TEMP_DIR)/unit-coverage-details.txt ./...
	@.github/scripts/coverage.py $(COVERAGE_THRESHOLD) $(TEMP_DIR)/unit-coverage-details.txt

.PHONY: bench
bench:
	go test -run ^$$ -bench . ./...

## Static analysis targets #################################

.PHONY: static-analysis
static-analysis: lint check-go-mod-tidy check-licenses

.PHONY: lint
lint: ## Run gofmt + golangci lint checks
	$(call title,Running linters)
	# ensure there are no go fmt differences
	@printf "files with gofmt issues: [$(shell gofmt -l -s .)]\n"
	@test -z "$(shell gofmt -l -s .)"

	# run all golangci-lint rules
	$(LINT_CMD)
	@[ -z "$(shell $(GOIMPORTS_CMD) -d .)" ] || (echo "goimports needs to be fixed" && false)

	# go tooling does not play well with certain filename characters, ensure the common cases don't result in future "go get" failures
	$(eval MALFORMED_FILENAMES := $(shell find . | grep -e ':'))
	@bash -c "[[ '$(MALFORMED_FILENAMES)' == '' ]] || (printf '\nfound unsupported filename characters:\n$(MALFORMED_FILENAMES)\n\n' && false)"

.PHONY: format
format: ## Auto-format all source code
	$(call title,Running formatters)
	gofmt -w -s .
	$(GOIMPORTS_CMD) -w .
	go mod tidy

.PHONY: lint-fix
lint-fix: format  ## Auto-format all source code + run golangci lint fixers
	$(call title,Running lint fixers)
	$(LINT_CMD) --fix

.PHONY: check-licenses
check-licenses:
	$(TEMP_DIR)/golicenses check ./...

check-go-mod-tidy:
	@ .github/scripts/go-mod-tidy-check.sh && echo "go.mod and go.sum are tidy!"


## Build-related targets #################################

.PHONY: build
build: $(SNAPSHOT_DIR) ## Build release snapshot binaries and packages

$(SNAPSHOT_DIR): ## Build snapshot release binaries and packages
	$(call title,Building snapshot artifacts)

	@# create a config with the dist dir overridden
	@echo "dist: $(SNAPSHOT_DIR)" > $(TEMP_DIR)/goreleaser.yaml
	@cat .goreleaser.yaml >> $(TEMP_DIR)/goreleaser.yaml

	@# build release snapshots
	@bash -c "\
		VERSION=$(VERSION:v%=%) \
		$(SNAPSHOT_CMD) --config $(TEMP_DIR)/goreleaser.yaml \
	  "

.PHONY: cli
cli: $(SNAPSHOT_DIR) ## Run CLI tests
	chmod 755 "$(SNAPSHOT_BIN)"
	$(SNAPSHOT_BIN) version
	./scripts/build.sh

.PHONY: changelog
changelog: clean-changelog  ## Generate and show the changelog for the current unreleased version
	$(CHRONICLE_CMD) -vvv -n --version-file VERSION > $(CHANGELOG)
	@$(GLOW_CMD) $(CHANGELOG)

$(CHANGELOG):
	$(CHRONICLE_CMD) -vvv > $(CHANGELOG)

.PHONY: release
release:  ## Cut a new release
	@.github/scripts/trigger-release.sh

.PHONY: release
ci-release: ci-check clean-dist $(CHANGELOG)
	$(call title,Publishing release artifacts)

	# create a config with the dist dir overridden
	echo "dist: $(DIST_DIR)" > $(TEMP_DIR)/goreleaser.yaml
	cat .goreleaser.yaml >> $(TEMP_DIR)/goreleaser.yaml

	bash -c "$(RELEASE_CMD) --release-notes <(cat CHANGELOG.md) --config $(TEMP_DIR)/goreleaser.yaml"

.PHONY: ci-check
ci-check:
	@.github/scripts/ci-check.sh


.PHONY: clean
clean:
	rm -rf $(TEMP_DIR) $(DIST_DIR) $(SNAPSHOT_DIR) $(CHANGELOG)
