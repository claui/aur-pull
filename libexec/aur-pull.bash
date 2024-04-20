source libexec/constants.bash
source libexec/options.bash

function __aur_pull {
  local basedir debug dry_run num_pkgbases pkgbases remote

  parse_options "$@"

  if [[ -z "${basedir:-}" ]]; then
    basedir="$(pwd)"
  fi

  if [[ -z "${remote:-}" ]]; then
    remote="$(
      git config --get --default "${__GIT_DEFAULT_REMOTE}" \
        'clone.defaultRemoteName'
    )"
  fi

  _log_debug 'Base directory: %s\n' "${basedir}"
  _log_debug 'Using remote: %s\n' "${remote}"

  _read_pkgbases "${basedir}"
  printf 'Found %d pkgbase(s)\n' "${#pkgbases[@]}"

  export basedir
  export debug
  export num_pkgbases="${#pkgbases[@]}"
  export remote
  if [[ "${debug}" -eq 0 ]] && [[ "${dry_run}" -eq 0 ]]; then
    set -- --bar
  else
    set --
  fi
  parallel -k "$@" -j4 _pull_pkgbase ::: "${pkgbases[@]}"

  if [[ "${dry_run}" -ne 0 ]]; then
    printf 'Would pull from %d repositories\n' "${num_pkgbases}"
  fi
}

export -f __aur_pull


function _pull_pkgbase {
  local pkgbase url
  pkgbase="${1?}"

  _log_debug 'Processing pkgbase #%d of %d: %s\n' \
    "${PARALLEL_SEQ}" "${num_pkgbases}" "${pkgbase}"
  _read_remote_url "${basedir}" "${pkgbase}" "${remote}"
  # shellcheck disable=SC2016  # No expansion wanted
  _log_debug '%s: url for `%s` is: %s \n' \
    "${pkgbase}" "${remote}" "${url}"

  if [[ -z "${url}" ]]; then
    # shellcheck disable=SC2016  # No expansion wanted
    printf '%s: remote `%s` not set' "${pkgbase}" "${remote}"
    if [[ "${dry_run}" -eq 0 ]]; then
      printf '; adding\n'
      _add_remote_url "${basedir}" "${pkgbase}" "${remote}"
    else
      printf '\n'
      _add_remote_url_dry_run "${basedir}" "${pkgbase}" "${remote}"
    fi
  elif ! _check_remote_url "${pkgbase}" "${url}"; then
    printf '%s: found remote URL %s' "${pkgbase}" "${url}"
    if [[ "${dry_run}" -eq 0 ]]; then
      printf '; fixing\n'
      _fix_remote_url "${basedir}" "${pkgbase}" "${remote}" "${url}"
    else
      printf '\n'
      _fix_remote_url_dry_run "${basedir}" "${pkgbase}" "${remote}" "${url}"
    fi
  fi

  if [[ "${dry_run}" -ne 0 ]]; then
    return
  fi
}

export -f _pull_pkgbase


function _read_pkgbases {
  local basedir
  basedir="${1?}"

  read -r -a pkgbases -d '\n' < <(
    find "${basedir}" -mindepth 1 -maxdepth 1 \
      -exec basename '{}' ';' \
      | sort
  ) || true

  # Hint for shellcheck
  export pkgbases
}

export -f _read_pkgbases


function _log_debug {
  local pattern

  if [[ "${debug}" -eq 0 ]]; then
    return
  fi

  pattern="${1?}"
  shift
  # shellcheck disable=SC2059  # Pattern interpolation
  printf "[DEBUG] ${pattern}" "$@"
}

export -f _log_debug


function _read_remote_url {
  local basedir pkgbase remote
  basedir="${1?}"
  pkgbase="${2?}"
  remote="${3?}"

  if ! git -C "${basedir}/${pkgbase}" grep -qF "${remote}"; then
    url=
    return
  fi

  url="$(
    git -C "${basedir}/${pkgbase}" remote get-url "${remote}"
  )"

  # Hint for shellcheck
  export url
}

export -f _read_remote_url


function _check_remote_url {
  local pkgbase url
  pkgbase="${1?}"
  url="${2?}"

  if [[ "${url}" != "${__REMOTE_URL_BASE}/${pkgbase}.git" ]]; then
    return 1
  fi
}

export -f _check_remote_url


function _add_remote_url {
  local basedir pkgbase remote
  basedir="${1?}"
  pkgbase="${2?}"
  remote="${3?}"

  git -C "${basedir}/${pkgbase}" remote add "${remote}" \
    "${__REMOTE_URL_BASE}/${pkgbase}.git"
}

export -f _add_remote_url


function _add_remote_url_dry_run {
  local basedir pkgbase remote
  basedir="${1?}"
  pkgbase="${2?}"
  remote="${3?}"

  # shellcheck disable=SC2016  # No expansion wanted
  printf '%s: would add remote `%s` with URL: %s\n' \
    "${pkgbase}" "${remote}" "${__REMOTE_URL_BASE}/${pkgbase}.git"
}

export -f _add_remote_url_dry_run


function _fix_remote_url {
  local basedir pkgbase old_url remote
  basedir="${1?}"
  pkgbase="${2?}"
  remote="${3?}"
  old_url="${4?}"

  git -C "${basedir}/${pkgbase}" remote set-url "${remote}" \
    "${__REMOTE_URL_BASE}/${pkgbase}.git"
  git -C "${basedir}/${pkgbase}" remote set-url --push "${remote}" \
    "${old_url}"
}

export -f _fix_remote_url


function _fix_remote_url_dry_run {
  local basedir pkgbase old_url remote
  basedir="${1?}"
  pkgbase="${2?}"
  remote="${3?}"
  old_url="${4?}"

  # shellcheck disable=SC2016  # No expansion wanted
  printf '%s: would set new fetch URL for remote `%s`: %s\n' \
    "${pkgbase}" "${remote}" "${__REMOTE_URL_BASE}/${pkgbase}.git"
  # shellcheck disable=SC2016  # No expansion wanted
  printf '%s: would set new push URL for remote `%s`: %s\n' \
    "${pkgbase}" "${remote}" "${old_url}"
}

export -f _fix_remote_url_dry_run
