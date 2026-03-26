# GUT (Godot Unit Test)

This is the Godot GUT testing framework.

## Installation

1. Copy this `gut` folder to your project's `addons/` folder
2. Enable the plugin in Project > Project Settings > Plugins
3. Run tests via: `Project > Tools > Run GUT`

Or run from command line:
```bash
godot --headless -s res://addons/gut/gut_cmdln.gd -gexit
```

## Writing Tests

Create test files in `tests/` folder:

```gdscript
extends GutTest

func test_example():
    assert_true(true, "This should pass")
```

## Running Tests

### In Editor
- `Project > Tools > Run GUT`

### Command Line
```bash
godot --headless -s res://addons/gut/gut_cmdln.gd -gexit
```

### GitHub Actions
See `.github/workflows/test.yml`
