source libexec/constants.bash

function read_branch_remotes {
  local basedir branch pkgbase
  basedir="${1?}"
  pkgbase="${2?}"
  branch="${3?}"

  fetch_remote="$(
    git -C "${basedir}/${pkgbase}" config --get --default '' \
      "branch.${branch}.remote"
  )"
  push_remote="$(
    git -C "${basedir}/${pkgbase}" config --get --default '' \
      "branch.${branch}.pushRemote"
  )"

  # Hint for shellcheck
  export fetch_remote push_remote
}

export -f read_branch_remotes


function fix_branch_remotes {
  local basedir branch fetch_remote pkgbase push_remote
  basedir="${1?}"
  pkgbase="${2?}"
  branch="${3?}"
  fetch_remote="${4?}"
  push_remote="${5?}"

  git -C "${basedir}/${pkgbase}" config --local --replace-all \
    "branch.${branch}.remote" "${fetch_remote}"
  if [[ -z "${push_remote}" ]]; then
    return
  fi
  git -C "${basedir}/${pkgbase}" config --local --replace-all \
    "branch.${branch}.pushRemote" "${push_remote}"
}

export -f fix_branch_remotes


function fix_branch_remotes_dry_run {
  local basedir branch fetch_remote pkgbase push_remote
  basedir="${1?}"
  pkgbase="${2?}"
  branch="${3?}"
  fetch_remote="${4?}"
  push_remote="${5?}"

  # shellcheck disable=SC2016  # No expansion wanted
  printf '%s: would set fetch remote to `%s`\n' \
    "${pkgbase}" "${fetch_remote}"
  if [[ -z "${push_remote}" ]]; then
    return
  fi
  # shellcheck disable=SC2016  # No expansion wanted
  printf '%s: would set push remote to `%s`\n' \
    "${pkgbase}" "${push_remote}"
}

export -f fix_branch_remotes_dry_run
