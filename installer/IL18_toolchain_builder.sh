#!/bin/bash

# EMBA - EMBEDDED LINUX ANALYZER
#
# Copyright 2020-2024 Siemens Energy AG
#
# EMBA comes with ABSOLUTELY NO WARRANTY. This is free software, and you are
# welcome to redistribute it under the terms of the GNU General Public License.
# See LICENSE file for usage of this software.
#
# EMBA is licensed under GPLv3
#
# Author(s): Benedikt Kuehne

# Description:  Installs full toolchain builder dependencies

IL18_toolchain_builder() {
  module_title "${FUNCNAME[0]}"

  print_git_info "crosstool-ng" "EMBA-support-repos/crosstool-ng" "TODO"

  if [[ "${LIST_DEP}" -eq 1 ]] || [[ "${IN_DOCKER}" -eq 1 ]] || [[ "${DOCKER_SETUP}" -eq 0 ]] || [[ "${FULL}" -eq 1 ]]; then
    INSTALL_APP_LIST=()
    cd "${HOME_PATH}" || ( echo "Could not install EMBA component toolchain_builder" && exit 1 )


    if [[ "${LIST_DEP}" -eq 1 ]] || [[ "${DOCKER_SETUP}" -eq 1 ]] ; then
      ANSWER=("n")
    else
      echo -e "\\n""${MAGENTA}""${BOLD}""These applications (if not already on the system) will be downloaded!""${NC}"
      ANSWER=("y")
    fi

    case ${ANSWER:0:1} in
      y|Y )

      # TODO
        apt-get install "${INSTALL_APP_LIST[@]}" -y --no-install-recommends
        if ! [[ -d external/vmlinux-to-elf ]]; then
          git clone https://github.com/EMBA-support-repos/vmlinux-to-elf external/vmlinux-to-elf
        fi

        if ! [[ -d external/kconfig-hardened-check ]]; then
          git clone https://github.com/EMBA-support-repos/kconfig-hardened-check.git external/kconfig-hardened-check
        fi
      ;;
    esac
  fi
}