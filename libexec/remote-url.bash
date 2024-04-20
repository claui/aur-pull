source libexec/constants.bash

function has_any_remote {
  local basedir pkgbase
  basedir="${1?}"
  pkgbase="${2?}"

  if [[ -z "$(git -C "${basedir}/${pkgbase}" remote)" ]]; then
    return 1
  fi
}

export -f has_any_remote


function read_remote_url {
  local basedir pkgbase remote
  basedir="${1?}"
  pkgbase="${2?}"
  remote="${3?}"

  if ! git -C "${basedir}/${pkgbase}" remote | grep -q "^${remote}\$"; then
    url=
    return
  fi

  url="$(
    git -C "${basedir}/${pkgbase}" remote get-url "${remote}"
  )"

  # Hint for shellcheck
  export url
}

export -f read_remote_url


function check_remote_url {
  local pkgbase url
  pkgbase="${1?}"
  url="${2?}"

  if [[ "${url}" != "${__REMOTE_URL_BASE}/${pkgbase}.git" ]]; then
    return 1
  fi
}

export -f check_remote_url


function add_remote_url {
  local basedir pkgbase remote
  basedir="${1?}"
  pkgbase="${2?}"
  remote="${3?}"

  git -C "${basedir}/${pkgbase}" remote add "${remote}" \
    "${__REMOTE_URL_BASE}/${pkgbase}.git"
}

export -f add_remote_url


function add_remote_url_dry_run {
  local basedir pkgbase remote
  basedir="${1?}"
  pkgbase="${2?}"
  remote="${3?}"

  # shellcheck disable=SC2016  # No expansion wanted
  printf '%s: would add remote `%s` with URL: %s\n' \
    "${pkgbase}" "${remote}" "${__REMOTE_URL_BASE}/${pkgbase}.git"
}

export -f add_remote_url_dry_run


function fix_remote_url {
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

export -f fix_remote_url


function fix_remote_url_dry_run {
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

export -f fix_remote_url_dry_run
