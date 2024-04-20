source libexec/constants.bash

function read_config {
  local default_value tomlq_filter variable_name
  variable_name="${1?}"
  tomlq_filter="${2?}"
  default_value="${3?}"

  read -r -d '\n' "${variable_name?}" < <(
    _print_setting \
      "${variable_name}" "${tomlq_filter}" "${default_value}"
  ) || true
}

export -f read_config


function read_config_homedir_aware {
  local default_value tomlq_filter variable_name
  variable_name="${1?}"
  tomlq_filter="${2?}"
  default_value="${3?}"

  read -r -d '\n' "${variable_name?}" < <(
    _print_setting \
      "${variable_name}" "${tomlq_filter}" "${default_value}" \
      | sed -e "s#^~/#${HOME}/#"
  ) || true
}

export -f read_config_homedir_aware


function _print_setting {
  local default_value tomlq_filter variable_name
  variable_name="${1?}"
  tomlq_filter="${2?}"
  default_value="${3?}"

  tomlq -r --arg default_value "${default_value}" \
    "${tomlq_filter} // \$default_value" \
    "${XDG_CONFIG_HOME:-"${HOME}/.config"}/${__SETTINGS_FILE}"
}
