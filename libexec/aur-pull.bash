source libexec/branch.bash
source libexec/constants.bash
source libexec/options.bash
source libexec/remote-url.bash

function __aur_pull {
  local basedir debug dry_run force num_pkgbases pkgbases remote

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

  _assert_outside_worktree "${basedir}"

  _read_pkgbases "${basedir}"
  printf 'Found %d pkgbase(s)\n' "${#pkgbases[@]}"

  export basedir
  export debug
  export num_pkgbases="${#pkgbases[@]}"
  export remote
  parallel -k -j4 _pull_pkgbase ::: "${pkgbases[@]}"

  if [[ "${dry_run}" -ne 0 ]]; then
    printf 'Would pull from %d repositories\n' "${num_pkgbases}"
  fi
}

export -f __aur_pull


function _pull_pkgbase {
  local checkout_name fetch_remote pkgbase push_remote url
  pkgbase="${1?}"

  _log_debug 'Processing pkgbase #%d of %d: %s\n' \
    "${PARALLEL_SEQ}" "${num_pkgbases}" "${pkgbase}"
  if ! _is_inside_worktree "${basedir}/${pkgbase}"; then
    _log_debug '%s: not a Git worktree; skipping\n' "${pkgbase}"
    return
  fi
  if ! has_any_remote "${basedir}" "${pkgbase}"; then
    _log_debug '%s: no remotes found; skipping\n' "${pkgbase}"
    return
  fi
  read_remote_url "${basedir}" "${pkgbase}" "${remote}"
  # shellcheck disable=SC2016  # No expansion wanted
  _log_debug '%s: url for `%s` is: %s\n' \
    "${pkgbase}" "${remote}" "${url}"

  if [[ -z "${url}" ]]; then
    # shellcheck disable=SC2016  # No expansion wanted
    printf '%s: remote `%s` not set' "${pkgbase}" "${remote}"
    if [[ "${dry_run}" -eq 0 ]]; then
      printf '; adding\n'
      set -- add_remote_url
    else
      printf '\n'
      set -- add_remote_url_dry_run
    fi
    "$@" "${basedir}" "${pkgbase}" "${remote}"

  elif ! check_remote_url "${pkgbase}" "${url}"; then
    printf '%s: found remote URL %s' "${pkgbase}" "${url}"
    if [[ "${dry_run}" -eq 0 ]]; then
      printf '; fixing\n'
      set -- fix_remote_url
    else
      printf '\n'
      set -- fix_remote_url_dry_run
    fi
    "$@" "${basedir}" "${pkgbase}" "${remote}" "${url}"
  fi

  read_branch_remotes \
    "${basedir}" "${pkgbase}" "${__GIT_DEFAULT_BRANCH}"

  if [[ -z "${fetch_remote}" ]]; then
    printf '%s: no remote set for %s branch' \
      "${pkgbase}" "${__GIT_DEFAULT_BRANCH}"
    if [[ "${dry_run}" -eq 0 ]]; then
      printf '; adding\n'
      set -- fix_branch_remotes
    else
      printf '\n'
      set -- fix_branch_remotes_dry_run
    fi
    "$@" "${basedir}" "${pkgbase}" "${__GIT_DEFAULT_BRANCH}" \
      "${remote}" "${push_remote}"

  elif [[ "${fetch_remote}" != "${remote}" ]]; then
    # shellcheck disable=SC2016  # No expansion wanted
    printf '%s: found fetch remote `%s` for %s branch' \
      "${pkgbase}" "${fetch_remote}" "${__GIT_DEFAULT_BRANCH}"
    if [[ "${dry_run}" -eq 0 ]]; then
      printf '; fixing\n'
      set -- fix_branch_remotes
    else
      printf '\n'
      set -- fix_branch_remotes_dry_run
    fi
    "$@" "${basedir}" "${pkgbase}" "${__GIT_DEFAULT_BRANCH}" \
      "${remote}" "${push_remote:-"${fetch_remote}"}"
  fi

  read_checkout_name "${basedir}" "${pkgbase}"
  if [[ "${checkout_name}" != "${__GIT_DEFAULT_BRANCH}" ]]; then
    _log_warn '%s: skipping because %s is checked out, not %s\n' \
      "${pkgbase}" "${checkout_name}" "${__GIT_DEFAULT_BRANCH}"
    return
  fi

  if [[ "${dry_run}" -ne 0 ]]; then
    return
  fi
}

export -f _pull_pkgbase


function _assert_outside_worktree {
  local basedir
  basedir="${1?}"

  if _is_inside_worktree "${basedir}"; then
    if [[ "${force}" -eq 0 ]]; then
      echo '[ERROR] Base directory is inside a Git worktree' \
        '(use --force to override)'
      return 1
    else
      echo '[WARNING] Base directory is inside a Git worktree;' \
        'proceeding because --force is set'
    fi
  fi
}

export -f _assert_outside_worktree


function _is_inside_worktree {
  local dir
  dir="${1?}"

  if [[ "$(
    git -C "${dir}" rev-parse --is-inside-work-tree 2>/dev/null \
      || true)" != 'true' ]]
  then
    return 1
  fi
}

export -f _is_inside_worktree


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


function _log_warn {
  local pattern

  pattern="${1?}"
  shift
  # shellcheck disable=SC2059  # Pattern interpolation
  printf "[WARNING] ${pattern}" "$@"
}

export -f _log_warn
