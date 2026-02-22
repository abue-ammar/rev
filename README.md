# Messenger ReVanced

Builds a patched Messenger APK (arm64-v8a) using [ReVanced](https://github.com/ReVanced/revanced-patches).

## Usage

1. Run the [Build workflow](../../actions/workflows/build.yml)
2. Grab your APK from [Releases](../../releases)

## Customizing `config.toml`

All keys are optional except `uptodown-dlurl`. Defaults are shown below.
Global keys (set outside any `[section]`) apply to all apps unless overridden per-app.

```toml
parallel-jobs = 1           # number of parallel build jobs (default: nproc)

# Override the source/version of patches and CLI (these are the built-in defaults;
# only add these if you want to use a different source or pin a specific version)
patches-source = "ReVanced/revanced-patches"
cli-source = "j-hc/revanced-cli"
patches-version = "latest"  # "latest", "dev", or a version tag e.g. "v5.0.0"
cli-version = "latest"      # "latest", "dev", or a version tag

[Messenger]
enabled = true             # set to false to skip building
build-mode = "apk"         # always "apk" (no module)
arch = "arm64-v8a"         # CPU architecture
version = "auto"           # "auto" (latest version supported by patches), "latest", or a specific version e.g. "500.0.0.11.110"
uptodown-dlurl = "https://facebook-messenger.en.uptodown.com/android"
excluded-patches = ""      # space-separated quoted patch names to disable, e.g. "'Patch Name' 'Another Patch'"
included-patches = ""      # space-separated quoted patch names to enable (non-default patches)
exclusive-patches = false  # if true, only included-patches are applied; all others are excluded
patcher-args = ""          # extra arguments passed to the ReVanced CLI patcher
riplib = true              # strip unused native libs to reduce APK size
```

