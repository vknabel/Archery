# Changelog

## 0.3.0

-   **[Breaking]** Mint will not be bundled with Archery anymore and needs to be installed manually when using legacy Arrows.
-   **[Breaking]** Requires Swift 5.
-   **[Addition]** Generate new metadata by loaders.
-   **[Addition]** Passes custom environment variables to all scripts and arrows: `ARCHERY`, `ARCHERY_METADATA`, `ARCHERY_SCRIPT`, `ARCHERY_API_LEVEL`, `ARCHERY_LEGACY_MINT_PATH`.
-   **[Addition]** Scripts can now be run in sequence with just an array literal `do-all: [first, second, third]`
-   **[Improvement]** `vknabel/ArcheryArrow` implicitly uses the new scripting API and does not require compilation anymore.
-   **[Improvement]** Scripts can now be run in sequence without using `arrow: vknabel/ArcheryArrow`
-   **[Improvement]** Bash scripts do not require `arrow: vknabel/BashArrow` anymore.
-   **[Improvement]** `vknabel/BashArrow` implicitly uses the new scripting API and does not require compilation anymore.
- **[Deprecation]** The classical `arrow`-script type will be deprecated and will be removed in far future.

### Upcoming Breaking Changes

Previously all scripts were defined as arrow: a separate Swift Package accepting specific arguments, being installed using Mint. This mechanism is now deprecated and will be replaced by plain scripts and environment variables.

Please note the arrow-shorthand syntax `script-name: your/Arrow` deprecated in version 0.2.1 is still available and has not been removed yet.

## 0.2.1

-   Bumped internal dependencies
-   Correctly passes interrupts
-   Shorthand arrow syntax will be migrated to `vknabel/BashArrow` commands

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

-   Archerfile supports YAML

### Archerfile supports YAML

Especially if your Archerfile contains descriptions it will get hard to read soon.
As a better format we replaced JSON with YAML, which is a superset of JSON and hence won’t break your configs.
As the Archerfile should not be read directly, this update won’t break arrows.

## 0.1.1

-   Improved error messages
-   Improved README.md

## 0.1.0

-   Initial Release
