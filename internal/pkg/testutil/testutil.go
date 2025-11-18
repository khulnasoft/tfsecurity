// Package testutil provides utilities for testing tfsecurity
package testutil

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// TempDir creates a temporary directory for testing
func TempDir(t *testing.T) string {
	dir, err := os.MkdirTemp("", "tfsecurity-test-")
	require.NoError(t, err)
	t.Cleanup(func() {
		os.RemoveAll(dir)
	})
	return dir
}

// WriteFile writes a file with the given content to the temp directory
func WriteFile(t *testing.T, dir, filename, content string) string {
	path := filepath.Join(dir, filename)
	err := os.WriteFile(path, []byte(content), 0644)
	require.NoError(t, err)
	return path
}

// CreateTestFS creates a test filesystem with the given files
func CreateTestFS(t *testing.T, files map[string]string) string {
	dir := TempDir(t)
	
	for name, content := range files {
		WriteFile(t, dir, name, content)
	}
	
	return dir
}
