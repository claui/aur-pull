<!-- markdownlint-configure-file { "MD041": { "level": 1 } } -->

# Synopsis

```shell
aur-pull [FLAGS] BASEDIR
```

# Description

Scans subdirectories for Git repositories. Fixes their Git `fetch`
remotes, changing them to HTTPS as needed, then runs
`git pull --autostash`.

# Positional parameters

`BASEDIR` is the base directory from where aur-pull is to start
searching for subdirectories that are Git repositories.

If unset, aur-pull will pick a default value for `BASEDIR`. (See the
`CONFIGURATION` section for more details.)

Note: aur-pull only affects immediate (i.e. first-level)
subdirectories.

# Options

The following options are supported:

## `-d`, `--debug`

Makes the output more verbose.

## `-f`, `--force`

Continue even if safety checks fail. You probably do not need this.

## `-h`, `--help`

Explains how to use this command.

## `-n`, `--dry-run`

Instead of fixing Git remotes and pull from them, just print a list
of changes that would be made and then exit.

## `-V`, `--version`

Displays version info.

# Configuration

You can override some of the defaults using an `aur-pull.toml`
configuration file placed into your `${XDG_CONFIG_HOME}/` or
`~/.config/` directory.

Example `aur-pull.toml` content:

```toml
[config]
basedir = "~/aur"
```

The following persistent configuration options are supported:

## `config.basedir`

Base directory that aur-pull will use if the `BASEDIR` positional
parameter is not specified.

If the value starts with `~/`, it will resolve to the current user’s
home directory.

aur-pull defaults to the current working directory if neither
`BASEDIR` nor `config.basedir` are set.
