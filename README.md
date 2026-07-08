# Setup Bats and Bats libraries

This GitHub Action installs [Bats](https://github.com/bats-core/bats-core) and the four major bats libraries:

* [bats-support](https://github.com/bats-core/bats-support)
* [bats-assert](https://github.com/bats-core/bats-assert)
* [bats-detik](https://github.com/bats-core/bats-detik)
* [bats-file](https://github.com/bats-core/bats-file)

The action can be also instructed to select which libraries to install.
While Linux is fully supported, windows and macos runners should work as well, check the [specific](#windows-and-macos-support) readme part.

## How to use it

``` yaml
on: [push]

jobs:
   my_test:
     runs-on: ubuntu-latest
     name: Install Bats and bats libs
     steps:
       - name: Checkout
         uses: actions/checkout@v5
       - name: Setup Bats and bats libs
         id: setup-bats
         uses: bats-core/bats-action@4.0.0
       - name: My test
         shell: bash
         env:
          BATS_LIB_PATH: ${{ steps.setup-bats.outputs.lib-path }}
          TERM: xterm
         run: bats test/my-test
```

By default the action will pass the `BATS_LIB_PATH` value as output `lib-path`.
You can use it like the below example and load the libraries in your tests with:

```bash
_tests_helper() {
    export BATS_LIB_PATH="${BATS_LIB_PATH:?BATS_LIB_PATH must be set by bats-action}"
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file
    bats_load_library bats-detik/detik.bash
}
```

## Libraries Path

For each of the Bats libraries, you can choose to install them in the default location or specify a custom path.

On Linux and macOS, the action now prefers the system library location only when the runner user can write there. Otherwise it falls back to `$HOME/.local/share/bats`, which avoids noisy cache restore failures on hosted runners.

For example, if you want to install `bats-support` in the `./test/bats-support` directory, you can configure it as follows:


``` yaml
      [...]
       - name: Setup Bats and Bats libs
         id: setup-bats
         uses: bats-core/bats-action@4.0.0
         with:
           support-path: ${{ github.workspace }}/test/bats-support
      [...]
```

## Authenticated requests

The action performs a number of calls against github API URLs to discover bats release numbers and download assets. To help against github rate limits, you can pass a valid github token so that those requests are authenticated. Example:

``` yaml
      [...]
       - name: Setup Bats and Bats libs
         id: setup-bats
         uses: bats-core/bats-action@4.0.0
         with:
           github-token: ${{ secrets.GITHUB_TOKEN }}
      [...]
```

If you don't have a token (for example, because you're using this action in a non-github pipeline), you can omit the token and things shoud work just fine, however you'll be slightly more likely to run into github rate limits, so keep this in mind if you encounter problems.


## About Caching

The caching mechanism for the `bats` binary is always available. Library caching works best when the library destination is writable by the runner user. With the default configuration on hosted runners, the action falls back to `$HOME/.local/share/bats`, so cache restore works without permission warnings.

If you explicitly point a library at a privileged path such as `/usr/lib/...`, cache restore may still hit permission warnings because `actions/cache` restores as the runner user before the install step runs.

**If you want reliable caching for bats libraries, install them inside the HOME directory**.
For instance this is an example that will use the github workspace handle (works for linux/win/mac):

```yaml
      [...]
       - name: Setup Bats and bats libs
         id: setup-bats
         uses: bats-core/bats-action@4.0.0
         with:
           support-path: "${{ github.workspace }}/tests/bats-support"
           assert-path: "${{ github.workspace }}/tests/bats-assert"
           detik-path: "${{ github.workspace }}/tests/bats-detik"
           file-path: "${{ github.workspace }}/tests/bats-file"
      [...]
```

## Windows and macos support

* Macos is fully supported for both default path and custom home path. The action uses `/usr/local/lib` when it is writable, otherwise it falls back to `$HOME/.local/share/bats`.
  * default libraries installation: `/usr/local/lib` or `$HOME/.local/share/bats`
  * default temp directory (for dev testing): `/tmp`
* Linux uses `/usr/lib` when it is writable, otherwise it falls back to `$HOME/.local/share/bats`.
  * default libraries installation: `/usr/lib` or `$HOME/.local/share/bats`
* Windows is fully supported as well, however they may be some hiccup around the libraries installation in another drive that is not `C:`.
Please report any issue.
  * default libraries installation: `/c/Users/runneradmin`
  * default temp directory (for dev testing): `$HOME/AppData/Local/Temp`

## Inputs

| Key              | Default | Required | Description                                    |
|------------------|---------|----------|------------------------------------------------|
| bats-install     | `true`    | false    | Bats installation, cache supported              |
| bats-version     | `latest`  | false    | Bats version   |
| support-install  | `true`    | false    | Bats-support installation      |
| support-version  | `0.3.0`   | false    | Bats-support version       |
| support-path     | `/usr/lib/bats-support` | false | Bats-support path |
| support-clean    | `true`    | false    | Bats-support: clean temp files                  |
| assert-install   | `true`    | false    | Bats-assert installation      |
| assert-version   | `2.1.0`   | false    | Bats-assert version         |
| assert-path      | `/usr/lib/bats-assert` | false | Bats-assert path |
| assert-clean     | `true`    | false    | Bats-assert: clean temp files                   |
| detik-install    | `true`   | false    | Bats-detik installation        |
| detik-version    | `1.3.0`   | false    | Bats-detik version        |
| detik-path       | `/usr/lib/bats-detik` | false | Bats-detik path |
| detik-clean      | `true`    | false    | Bats-detik: clean temp files                    |
| file-install     | `true`    | false    | Bats-file installation     |
| file-version     | `0.4.0`   | false    | Bats-file version            |
| file-path        | `/usr/lib/bats-file` | false | Bats-file path   |
| file-clean       | `true`    | false    | Bats-file: clean temp files                     |

## Outputs

| Key              | Description                                    |
|------------------|------------------------------------------------|
| bats-installed   | True/False if bats has been installed          |
| support-installed| True/False if bats-support has been installed  |
| assert-installed | True/False if bats-assert has been installed   |
| detik-installed  | True/False if bats-detik has been installed    |
| file-installed   | True/False if bats-file has been installed     |
| lib-path         | Bats lib path to use to load the libraries     |
| tmp-path         | Temporary path with each library tests         |
