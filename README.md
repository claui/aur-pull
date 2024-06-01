# aur-pull

Scans subdirectories for Git repositories. Fixes their Git `fetch`
remotes, changing them to HTTPS as needed, then runs
`git pull --autostash`.

## Installation

### Installing manually

1. Make sure you have the following dependencies installed:

    - `bash`
    - `findutils`
    - `git`
    - `parallel`
    - Python
    - PyPI packages `dotty_dict` and `tomlkit`

2. Clone this repository to any directory you like.

### Installing from the AUR

Direct your favorite
[AUR helper](https://wiki.archlinux.org/title/AUR_helpers) to the
`aur-pull` package.

## Usage

See [`USAGE.md`](https://github.com/claui/aur-pull/blob/main/USAGE.md) for details.

## Contributing to aur-pull

See [`CONTRIBUTING.md`](https://github.com/claui/aur-pull/blob/main/CONTRIBUTING.md).

## License

Copyright (c) 2024 Claudia Pellegrino

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
For a copy of the License, see [LICENSE](LICENSE).
