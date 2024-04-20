source libexec/version.bash

function parse_options {
  debug=0
  dry_run=0

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      -d|--debug)
        debug=1
        shift
        ;;
      -h|--help)
        _print_usage
        exit 0
        ;;
      -n|--dry-run)
        dry_run=1
        shift
        ;;
      -V|--version)
        echo >&2 "${BASENAME} v${__VERSION}"
        exit 0
        ;;
      -*)
        echo >&2 "Error: Unknown option ${1}"
        return 1
        ;;
      *)
        _set_basedir "${1}"
        shift
        ;;
    esac
  done

  # Hint for shellcheck
  export basedir debug dry_run
}

export -f parse_options


function _print_usage {
  echo >&2 "${BASENAME} v${__VERSION}"
  cat >&2 << EOF
Usage:

    ${BASENAME} [OPTIONS] BASEDIR

Supported options:

    -d, --debug     More verbose output
    -n, --dry-run   Do not fix Git remotes nor pull, just print
                    changes that would be made to the remotes
    -h, --help
    -V, --version
EOF
}

export -f _print_usage


function _assert_unset {
  local param description
  param="${1?}"
  description="${2?}"

  if [[ -n "${param}" ]]; then
    printf >&2 'Error: More than one %s provided.\n' "${description}"
    return 1
  fi
}

export -f _assert_unset


function _set_basedir {
  local value
  value="${1?}"

  _assert_unset "${basedir:-}" 'base directory'
  basedir="${value}"
}

export -f _set_basedir
