#!/bin/bash -p

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

# This module is intends to provide the tester with a complete toolchain for exploitation
# it takes the information from F02 and creates a working skeleton project

# Code Guidelines:
# -----------------------------
# If you use external code, add '# Test source: [LINK TO CODE]' above.
# Use 'local' for variables if possible for better resource management
# Use 'export' for variables which aren't only used in one file - it isn't necessary, but helps for readability


l18_toolchain_builder() {
  # Initialize module and creates a log file "template_module_log.txt" and directory "template_module" (if needed) in your log folder
  # Required!
  module_log_init "${FUNCNAME[0]}"
  # Prints title to CLI and into log
  # Required!
  module_title "Toolchain builder"
  # Variables we need for the toolchain from F02
  local lARCH=""
  local lCPU_FLAGS={}
  local lMARCH_NAME=""
  local lGCC_FLAGS={}

    # TODO 
    # $FIRMWARE_PATH - absolute path to the root directory of the firmware (String)
    # $FILE_ARR - all valid files of the provided firmware (Array)
    # $BINARIES - all executable binaries of the provided firmware (Array)

  # Setup variables

  local TESTVAR1=""
  local TESTVAR2=""

  print_output "[*] TESTVAR1: ${TESTVAR1}"
  print_output "[*] TESTVAR2: ${TESTVAR2}"

  # Prints everything to CLI, more information in function print_examples
  print_output "[*] Empty module output"

  # Call a submodule inside of module with a parameter
  sub_module "${TESTVAR1}"

  # How to use print_output
  print_examples

  # How to use paths inside of project
  path_handling

  # Get all binaries from firmware and use them
  iterate_binary

  # Add links to webreport
  webreport_functions

  # Load stuff from external config files (get list of lines, grep and find)
  load_from_config

  # Usage of `find`: add "${EXCL_FIND[@]}" to exclude all paths (added with '-e' parameter)
  print_output "$(find "${FIRMWARE_PATH}" "${EXCL_FIND[@]}" -type f -exec md5sum {} \; 2>/dev/null | sort -u -k1,1 | cut -d\  -f3 | wc -l)"

  # Ends module and saves status into log - $COUNT_FINDINGS has to be replaced by a number of your findings. If your module didn't found something, then it isn't needed to be generated in the final report
  # Required!
  module_end_log "${FUNCNAME[0]}" "${#COUNT_FINDINGS[@]}"
}

sub_module() {
  # setup local TESTVAR1_ in function
  local TESTVAR1_="${1:-}"
  # Create submodules inside of a module for better structure
  sub_module_title "Submodule example"

  print_output "[*] local TESTVAR1_: ${TESTVAR1_}"

  # Analyze stuff ...
}

print_examples() {
  # Works like 'echo', but with some twists
  print_output "print example"

  # -> if you use 'print_output, it will write into defined (module_log_init) log file'
  # Don't want to log: Add "no_log" as second parameter
  print_output "no log example" "no_log"

  # Automatic color coding (don't add something before '[' - if you need a new line before, use 'echo'):

  # [*] is for informative messages
  print_output "[*] Information example"

  # [+] is for finding messages
  print_output "[*] Finding example"

  # [-] is for failure/no finding messages
  print_output "[-] Not found example"

  # [!] is for warning messages
  print_output "[!] Something went horribly wrong"

  # Functions to change text

  # indent text, e.g. "    indented text example" - works for multiple lines too, if you only use single lines, you can also use "print_output "    indented text example" "
  print_output "$(indent "indented text example")"

  # color text
  print_output "$(orange "orange text example")"
  print_output "$(red "red text example")"
  print_output "$(blue "blue text example")"
  print_output "$(cyan "cyan text example")"
  print_output "$(green "green text example")"
  print_output "$(magenta "magenta text example")"
  print_output "$(white "unformatted text example")" # remove formatting

  # format text
  print_output "$(bold "bold text example")"
  print_output "$(italic "italic text example")"

  # Combination of above functions
  # indent orange text
  print_output "$(indent "$(orange "indented orange text example")")"

  # Good to know: All these functions are also working with text with line breaks

  # If you only want to print stuff into an own log file
  print_log "log text" "[path to log file]" "g"
  # "g" is optional for printing line into grep-able log file (emba -g)
}

path_handling() {
  # Firmware path - use this variable:
  print_output "${FIRMWARE_PATH}"

  # Print paths (standardized) with permissions and owner
  # e.g. /home/linux/firmware/var/etc (drwxr-xr-x firmware firmware)
  print_output "$(print_path "/test/path/file.xy")"

  # Get only permission of path
  permission_clean "/test/path/file.xy"

  # Get only owner of path
  owner_clean "/test/path/file.xy"

  # Get only group of path
  group_clean "/test/path/file.xy"

  # Before using a path in your module!
  # Option 1: Search with find and loop trough results / don't use mod_path!
  # Insert "${EXCL_FIND[@]}" in your search-command to automatically remove excluded paths
  local CHECK=0
  readarray -t TEST < <( find "${FIRMWARE_PATH}" -xdev "${EXCL_FIND[@]}" -iname '*xy*' -exec md5sum {} \; 2>/dev/null | sort -u -k1,1 | cut -d\  -f3 )
  for TEST_E in "${TEST[@]}"; do
    if [[ -f "${MP_DIR}" ]] ; then
      CHECK=1
      print_output "[+] Found ""$(print_path "${TEST_E}")"
    fi
  done
  if [[ ${CHECK} -eq 0 ]] ; then
    print_output "[-] No modprobe.d directory found"
  fi

  # Using static single path (mod_path -> returns array of paths, especially if etc is in this path: all other found etc
  # locations will be added there
  # Add placeholder "ETC_PATHS" instead of path "etc"
  CHECK=0
  local TEST_PATHS=()
  local TEST_E=""
  mapfile -t TEST_PATHS < <(mod_path "/ETC_PATHS/xy.cfg")

  for TEST_E in "${TEST_PATHS[@]}" ; do
    if [[ -f "${TEST_E}" ]] ; then
      CHECK=1
      print_output "[+] Found xy config: ""$(print_path "${TEST_E}")"
    fi
  done
  if [[ ${CHECK} -eq 0 ]] ; then
    print_output "[-] No xy configuration file found"
  fi

  # Using multiple paths as array:
  local TEST_PATHS_ARR=()
  mapfile -t TEST_PATHS_ARR < <(mod_path_array "$(config_list "${CONFIG_DIR}""/test_files.cfg" "")")

  if [[ "${TEST_PATHS_ARR[0]}" == "C_N_F" ]] ; then
    print_output "[!] Config not found"
  elif [[ "${#TEST_PATHS_ARR[@]}" -ne 0 ]] ; then
    for TEST_E in "${TEST_PATHS_ARR[@]}"; do
      if [[ -f "${TEST_E}" ]] ; then
        print_output "[+] Found: ""$(print_path "${TEST_E}")"
      fi
    done
  else
    print_output "[-] Nothing found"
  fi
}

iterate_binary() {
  # BINARIES is an array, which is project wide available and contains all paths of binary files
  local BIN_FILE=""

  for BIN_FILE in "${BINARIES[@]}"; do
    print_output "${BIN_FILE}"
  done
}

webreport_functions() {
  # add a link in the webreport for the printed line to module (e.g. s42) - use the prefix of the module names
  print_output "[*] Information"
  write_link "s42"

  # add anchor to this module, if this module is s42_....sh ...
  write_anchor "test"

  # ... then it can be called by following link
  print_output "This should link to test anchor"
  write_link "s42#test"

  # add a png picture
  write_link "PATH_TO_PNG"

  # add custom log files to webreport
  write_link "PATH_TO_TXT/LOG_FILE"
  # it will be generated and linked with the text of the previous line
}

load_from_config() {
  # config_grep.cfg contains grep statements, these will be all used for grepping "${FILE_PATH}"
  local OUTPUT=""
  local OUTPUT_LINES=()
  mapfile -t OUTPUT_LINES < <(config_grep "${CONFIG_DIR}""/config_grep.cfg" "${FILE_PATH}")

  if [[ "${OUTPUT_LINES[0]}" == "C_N_F" ]] ; then
    print_output "[!] Config not found"
  elif [[ "${#OUTPUT_LINES[@]}" -ne 0 ]] ; then
    # count of results
    print_output "[+] Found ""${#OUTPUT_LINES[@]}"" files:"

    for OUTPUT in "${OUTPUT_LINES[@]}"; do
      if [[ -f "${OUTPUT}" ]] ; then
        print_output "$(print_path "${OUTPUT}")"
      fi
    done
  else
    print_output "[-] Nothing found"
  fi


  # config_list.cfg contains text, you get an array
  local OUTPUT_LINES=()
  mapfile -t OUTPUT_LINES < <(config_list "${CONFIG_DIR}""/config_list.cfg")

  if [[ "${OUTPUT_LINES[0]}" == "C_N_F" ]] ; then
    print_output "[!] Config not found"
  elif [[ "${#OUTPUT_LINES[@]}" -ne 0 ]] ; then
    # count of results
    print_output "[+] Found ""${#OUTPUT_LINES[@]}"" files:"

    for OUTPUT in "${OUTPUT_LINES[@]}"; do
      if [[ -f "${OUTPUT}" ]] ; then
        print_output "$(print_path "${OUTPUT}")"
      fi
    done
  else
    print_output "[-] Nothing found"
  fi


  # Find files with search parameters (wildcard * is allowed)
  local OUTPUT_LINES=()
  local LINE=""
  readarray -t OUTPUT_LINES < <(printf '%s' "$(config_find "${CONFIG_DIR}""/config_find.cfg")")

  if [[ "${OUTPUT_LINES[0]}" == "C_N_F" ]] ; then print_output "[!] Config not found"
  elif [[ ${#OUTPUT_LINES[@]} -ne 0 ]] ; then
    print_output "[+] Found ""${#OUTPUT_LINES[@]}"" files:"
    for LINE in "${OUTPUT_LINES[@]}" ; do
      if [[ -f "${LINE}" ]] ; then
        print_output "$(indent "$(orange "$(print_path "${LINE}")")")"
      fi
    done
  else
    print_output "[-] No files found"
  fi
}

