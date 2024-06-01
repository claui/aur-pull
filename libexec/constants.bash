export __GIT_DEFAULT_BRANCH='master'
export __GIT_DEFAULT_REMOTE='origin'

__PROJECT_ROOT="$(pwd)/$(dirname -- "${BASH_SOURCE[0]}")/.."
export __PROJECT_ROOT

export __REMOTE_URL_BASE='https://aur.archlinux.org'
export __SETTINGS_FILE='aur-pull.toml'
