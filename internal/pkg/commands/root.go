// Package commands contains all CLI commands for tfsecurity
package commands

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/khulnasoft/tfsecurity/internal/pkg/app"
	"github.com/khulnasoft/tfsecurity/internal/pkg/config"
	"github.com/khulnasoft/tfsecurity/version"
)

// NewRootCommand creates the root command for tfsecurity
func NewRootCommand() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "tfsecurity [directory]",
		Short: "Security scanner for your Terraform code",
		Long: `tfsecurity is a simple to use, security scanner for your Terraform code.

tfsecurity uses OPA Rego policies to evaluate Terraform HCL files 
for security misconfigurations and provides detailed results and remediation steps.`,
		RunE: runRoot,
		Version: version.Version,
	}

	// Add global flags
	cmd.PersistentFlags().StringP("format", "f", "pretty", "output format: pretty, json, csv, checkstyle, junit, sarif, gif, html")
	cmd.PersistentFlags().StringP("output", "o", "", "output file path")
	cmd.PersistentFlags().Bool("no-color", false, "disable colored output")
	cmd.PersistentFlags().Bool("quiet", false, "suppress any logging")

	// Add subcommands
	cmd.AddCommand(newVersionCommand())
	cmd.AddCommand(newDocsCommand())

	return cmd
}

func runRoot(cmd *cobra.Command, args []string) error {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("failed to load configuration: %w", err)
	}

	// Create application
	app := app.New(cfg)

	// Parse flags and create options
	options, err := parseOptions(cmd, args)
	if err != nil {
		return err
	}

	// Run the application
	return app.Run(cmd.Context(), options)
}

func parseOptions(cmd *cobra.Command, args []string) (*app.Options, error) {
	// Parse command line flags and create options
	format, _ := cmd.Flags().GetString("format")
	output, _ := cmd.Flags().GetString("output")

	dir := "."
	if len(args) > 0 {
		dir = args[0]
	}

	return &app.Options{
		Dir:        dir,
		Format:     format,
		OutputFile: output,
		FS:         os.DirFS(dir),
	}, nil
}
