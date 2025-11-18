package updater

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"runtime"
	"time"

	semver "github.com/hashicorp/go-version"
	"github.com/inconshreveable/go-update"
	"github.com/khulnasoft/tfsecurity/version"
)

type githubRelease struct {
	TagName string `json:"tag_name"`
}

func Update() (string, error) {
	if version.Version == "" {
		return "", fmt.Errorf("you are running a locally built version")
	}

	latestAvailable, err := getLatestVersion()
	if err != nil {
		return "", err
	}

	updated, err := updateIfNewer(latestAvailable)
	if err != nil {
		return "", err
	}
	if !updated {
		return "", nil
	}
	return latestAvailable, nil
}

func getLatestVersion() (string, error) {
	client := &http.Client{
		Timeout: 30 * time.Second,
	}
	
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	
	req, err := http.NewRequestWithContext(ctx, "GET", "https://api.github.com/repos/khulnasoft/tfsecurity/releases/latest", nil)
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}
	
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to get latest version: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	var release githubRelease
	if err := json.NewDecoder(resp.Body).Decode(&release); err != nil {
		return "", fmt.Errorf("failed to decode response: %w", err)
	}

	return release.TagName, nil
}

func isNewerVersion(latestVersion string) (bool, error) {
	v1, err := semver.NewVersion(version.Version)
	if err != nil {
		return false, err
	}
	v2, err := semver.NewVersion(latestVersion)
	if err != nil {
		return false, err
	}

	return v1.LessThan(v2), nil
}

func updateIfNewer(latest string) (bool, error) {
	if newer, err := isNewerVersion(latest); err != nil {
		return false, err
	} else if !newer {
		return false, nil
	}
	
	downloadUrl := resolveDownloadUrl(latest)
	
	client := &http.Client{
		Timeout: 60 * time.Second,
	}
	
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()
	
	req, err := http.NewRequestWithContext(ctx, "GET", downloadUrl, nil)
	if err != nil {
		return false, fmt.Errorf("failed to create download request: %w", err)
	}
	
	resp, err := client.Do(req)
	if err != nil {
		return false, fmt.Errorf("failed to download update: %w", err)
	}
	defer func() { _ = resp.Body.Close() }()
	
	if resp.StatusCode != http.StatusOK {
		return false, fmt.Errorf("failed to download the latest version of tfsecurity: status code %d", resp.StatusCode)
	}
	
	if err := update.Apply(resp.Body, update.Options{}); err != nil {
		return false, fmt.Errorf("failed to apply update: %w", err)
	}
	return true, nil
}

func resolveDownloadUrl(latest string) string {
	suffix := ""
	if runtime.GOOS == "windows" {
		suffix = ".exe"
	}

	return fmt.Sprintf("https://github.com/khulnasoft/tfsecurity/releases/download/%s/tfsecurity-%s-%s%s", latest, runtime.GOOS, runtime.GOARCH, suffix)
}
