# Project Structure Migration Guide

## Overview

The tfsecurity project has been restructured to improve maintainability, separation of concerns, and follow Go best practices.

## Key Changes

### 1. Command Structure
- **Old**: `internal/app/tfsecurity/cmd`
- **New**: `internal/pkg/commands`

### 2. Application Layer
- **New**: `internal/pkg/app` - Contains main application logic
- **New**: `internal/pkg/scanner` - Centralized scanning functionality

### 3. Test Utilities
- **New**: `internal/pkg/testutil` - Common testing helpers

### 4. Package Organization

#### Before:
```
internal/
├── app/
│   └── tfsecurity/
│       └── cmd/
├── pkg/
│   ├── config/
│   ├── custom/
│   ├── formatter/
│   ├── ignores/
│   ├── legacy/
│   ├── metrics/
│   └── updater/
```

#### After:
```
internal/
├── pkg/
│   ├── app/           # Application logic
│   ├── commands/      # CLI commands
│   ├── config/        # Configuration
│   ├── custom/        # Custom checks
│   ├── formatter/     # Output formatters
│   ├── ignores/       # Ignore functionality
│   ├── legacy/        # Legacy support
│   ├── metrics/       # Metrics collection
│   ├── scanner/       # Scanning logic
│   ├── testutil/      # Test utilities
│   └── updater/       # Update functionality
```

## Import Path Changes

### Updated Imports:
- `github.com/khulnasoft/tfsecurity/internal/app/tfsecurity/cmd` → `github.com/khulnasoft/tfsecurity/internal/pkg/commands`
- `cmd.Root()` → `commands.NewRootCommand()`

### Example Migration:

#### Before:
```go
import "github.com/khulnasoft/tfsecurity/internal/app/tfsecurity/cmd"

func main() {
    if err := cmd.Root().Execute(); err != nil {
        // handle error
    }
}
```

#### After:
```go
import "github.com/khulnasoft/tfsecurity/internal/pkg/commands"

func main() {
    if err := commands.NewRootCommand().Execute(); err != nil {
        // handle error
    }
}
```

## Benefits

1. **Better Separation of Concerns**: CLI logic separated from business logic
2. **Improved Testability**: Clear interfaces and dependency injection
3. **Cleaner Package Structure**: Flatter, more intuitive organization
4. **Better Maintainability**: Easier to locate and modify specific functionality
5. **Consistent Naming**: All packages follow standard Go conventions

## Migration Checklist

- [ ] Update import statements in main.go
- [ ] Update command references in tests
- [ ] Update documentation references
- [ ] Verify all builds pass
- [ ] Run full test suite

## Breaking Changes

- The `cmd.Root()` function has been replaced with `commands.NewRootCommand()`
- Error handling for exit codes has been simplified
- Some internal package paths have changed

## Future Improvements

The new structure enables:
- Better unit testing with clear interfaces
- Easier addition of new commands
- Cleaner separation between CLI and core logic
- Better dependency management
