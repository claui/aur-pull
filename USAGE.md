<!-- markdownlint-configure-file { "MD041": { "level": 1 } } -->

# Synopsis

```shell
aur-pull [FLAGS] BASEDIR
```

Scans subdirectories for Git repositories. Fixes their Git `fetch`
remotes, changing them to HTTPS as needed, then runs
`git pull --autostash`.

# Positional parameters

`BASEDIR` is the base directory from where aur-pull is to start
searching for subdirectories that are Git repositories.

If unset, aur-pull assumes the current working directory as
`BASEDIR`.

Note: aur-pull only affects immediate (i.e. first-level)
subdirectories.

# Flags

The following flags are supported:

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
