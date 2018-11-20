# Changelog

## 0.3.0

* Mint will not be bundled with Archery anymore. Instead always your global version will be used.

## 0.2.1

* Bumped internal dependencies
* Correctly passes interrupts
* Shorthand arrow syntax will be migrated to `vknabel/BashArrow` commands

### Upcoming Breaking Change

Currently when passing a named string as a script, it will be expanded as `arrow: your/Arrow`.
The new behavior will run the provided string as a command line script as `arrow: BashArrow` and `command: your script`.
Until the next breaking update, repo names will still work as previously.
All strings containing exactly one `/`, no space and which do not start with a `.`, will still be treated as arrow.

```yaml
scripts:
  # Deprecated shorthand
  example: "vknabel/BeakArrow" # this would run the arrow
  # New behavior
  format: "swiftformat ." # this would run a `vknabel/BashArrow` command
```

## 0.2.0

* Archerfile supports YAML

### Archerfile supports YAML

Especially if your Archerfile contains descriptions it will get hard to read soon.
As a better format we replaced JSON with YAML, which is a superset of JSON and hence won’t break your configs.
As the Archerfile should not be read directly, this update won’t break arrows.

## 0.1.1

* Improved error messages
* Improved README.md

## 0.1.0

* Initial Release
