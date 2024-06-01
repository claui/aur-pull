source libexec/constants.bash

function read_config {
  local default_value dotted_key variable_name
  variable_name="${1?}"
  dotted_key="${2?}"
  default_value="${3?}"

  read -r -d '\n' "${variable_name?}" < <(
    _print_setting \
      "${variable_name}" "${dotted_key}" "${default_value}"
  ) || true
}

export -f read_config


function read_config_homedir_aware {
  local default_value dotted_key variable_name
  variable_name="${1?}"
  dotted_key="${2?}"
  default_value="${3?}"

  read -r -d '\n' "${variable_name?}" < <(
    _print_setting \
      "${variable_name}" "${dotted_key}" "${default_value}" \
      | sed -e "s#^~/#${HOME}/#"
  ) || true
}

export -f read_config_homedir_aware


function _print_setting {
  local default_value settings_path dotted_key variable_name
  variable_name="${1?}"
  dotted_key="${2?}"
  default_value="${3?}"
  settings_path="${XDG_CONFIG_HOME:-"${HOME}/.config"}/${__SETTINGS_FILE}"

  python "${__PROJECT_ROOT}/libexec/print_setting.py" \
    "${settings_path}" "${dotted_key}" "${default_value}"
}
