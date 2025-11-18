// Package app contains the main application logic for tfsecurity
package app

import (
	"context"
	"fmt"
	"io/fs"

	"github.com/khulnasoft/tfsecurity/internal/pkg/config"
	"github.com/khulnasoft/tfsecurity/internal/pkg/formatter"
	"github.com/khulnasoft/tfsecurity/internal/pkg/scanner"
	"github.com/khulnasoft/tfsecurity/version"
)

// App represents the main tfsecurity application
type App struct {
	config  *config.Config
	version string
}

// New creates a new tfsecurity application instance
func New(cfg *config.Config) *App {
	return &App{
		config:  cfg,
		version: version.Version,
	}
}

// Run executes the tfsecurity application with the given context and options
func (a *App) Run(ctx context.Context, options *Options) error {
	scanner := scanner.New(options.ScannerOptions...)
	
	results, metrics, err := scanner.ScanFSWithMetrics(ctx, options.FS, options.Dir)
	if err != nil {
		return fmt.Errorf("scan failed: %w", err)
	}

	formatter := formatter.New(options.Format)
	if err := formatter.Output(results, metrics, options.OutputFile); err != nil {
		return fmt.Errorf("output failed: %w", err)
	}

	return nil
}

// Options contains all the options for running the application
type Options struct {
	FS            fs.FS
	Dir           string
	Format        string
	OutputFile    string
	ScannerOptions []scanner.Option
}
