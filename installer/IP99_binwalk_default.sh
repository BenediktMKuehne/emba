#!/bin/bash

# EMBA - EMBEDDED LINUX ANALYZER
#
# Copyright 2020-2022 Siemens AG
# Copyright 2020-2022 Siemens Energy AG
#
# EMBA comes with ABSOLUTELY NO WARRANTY. This is free software, and you are
# welcome to redistribute it under the terms of the GNU General Public License.
# See LICENSE file for usage of this software.
#
# EMBA is licensed under GPLv3
#
# Author(s): Michael Messner, Pascal Eckmann
# Contributor(s): Stefan Haboeck, Nikolas Papaioannou

# Description:  Installs binwalk and dependencies for EMBA

IP99_binwalk_default() {
  module_title "${FUNCNAME[0]}"

  if [[ "$LIST_DEP" -eq 1 ]] || [[ $IN_DOCKER -eq 1 ]] || [[ $DOCKER_SETUP -eq 0 ]] || [[ $FULL -eq 1 ]]; then
    cd "$HOME_PATH" || ( echo "Could not install EMBA component binwalk" && exit 1 )
    INSTALL_APP_LIST=()

    print_tool_info "git" 1
    print_tool_info "locales" 1
    print_tool_info "qtbase5-dev" 1
    print_tool_info "build-essential" 1
    print_tool_info "mtd-utils" 1
    print_tool_info "gzip" 1
    print_tool_info "bzip2" 1
    print_tool_info "tar" 1
    print_tool_info "arj" 1
    print_tool_info "lhasa" 1
    print_tool_info "p7zip" 1
    print_tool_info "p7zip-rar" 1
    print_tool_info "p7zip-full" 1
    print_tool_info "cabextract" 1
    print_tool_info "util-linux" 1

    # tools only available on Kali Linux:
    if [[ "$OTHER_OS" -eq 0 ]] && [[ "$UBUNTU_OS" -eq 0 ]]; then
      # firmware-mod-kit is only available on Kali Linux
      print_tool_info "firmware-mod-kit" 1
    else
      echo -e "$RED""$BOLD""Not installing firmware-mod-kit. Your EMBA installation will be incomplete""$NC"
    fi

    print_tool_info "cramfsswap" 1
    print_tool_info "squashfs-tools" 1
    print_tool_info "zlib1g-dev" 1
    print_tool_info "liblzma-dev" 1
    print_tool_info "liblzo2-dev" 1
    print_tool_info "sleuthkit" 1
    print_tool_info "default-jdk" 1
    print_tool_info "lzop" 1
    print_tool_info "cpio" 1

    print_tool_info "python3-pip" 1
    print_tool_info "python3-opengl" 1
    print_tool_info "python3-pyqt5" 1
    print_tool_info "python3-pyqt5.qtopengl" 1
    print_tool_info "python3-numpy" 1
    print_tool_info "python3-scipy" 1
    #print_tool_info "python3-lzo" 1
    # pipenv install --deploy "python-lzo"
    # python-setuptools is needed for ubireader installation
    print_tool_info "python-setuptools" 1
    print_tool_info "srecord" 1

    pipenv install --deploy "nose"
    pipenv install --deploy "coverage"
    pipenv install --deploy "pyqtgraph"
    pipenv install --deploy "capstone"
    pipenv install --deploy "cstruct"
    pipenv install --deploy "matplotlib"

    print_git_info "binwalk" "EMBA-support-repos/binwalk" "Binwalk is a fast, easy to use tool for analyzing, reverse engineering, and extracting firmware images."
    echo -e "$ORANGE""binwalk will be downloaded and installed from source.""$NC"
    print_git_info "yaffshiv" "devttys0/yaffshiv" "A simple YAFFS file system parser and extractor, written in Python."
    echo -e "$ORANGE""yaffshiv will be downloaded.""$NC"
    print_git_info "sasquatch" "devttys0/sasquatch" "The sasquatch project is a set of patches to the standard unsquashfs utility (part of squashfs-tools) that attempts to add support for as many hacked-up vendor-specific SquashFS implementations as possible."
    echo -e "$ORANGE""sasquatch will be downloaded.""$NC"
    print_git_info "jefferson" "sviehb/jefferson" "JFFS2 filesystem extraction tool"
    echo -e "$ORANGE""jefferson will be downloaded.""$NC"
    print_git_info "cramfs-tools" "npitre/cramfs-tools" "Cramfs - cram a filesystem onto a small ROM"
    echo -e "$ORANGE""cramfs-tools will be downloaded.""$NC"
    print_git_info "ubi_reader" "jrspruitt/ubi_reader" "UBI Reader is a Python module and collection of scripts capable of extracting the contents of UBI and UBIFS images"
    echo -e "$ORANGE""ubi_reader will be downloaded.""$NC"
    print_file_info "stuffit520.611linux-i386.tar.gz" "Extract StuffIt archive files" "https://downloads.tuxfamily.org/sdtraces/BottinHTML/stuffit520.611linux-i386.tar.gz" "external/binwalk/unstuff/tuffit520.611linux-i386.tar.gz" "external/binwalk/unstuff/"

    if [[ "$LIST_DEP" -eq 1 ]] || [[ $DOCKER_SETUP -eq 1 ]] ; then
      ANSWER=("n")
    else
      echo -e "\\n""$MAGENTA""$BOLD""binwalk, yaffshiv, sasquatch, jefferson, unstuff, cramfs-tools and ubi_reader (if not already on the system) will be downloaded and installed!""$NC"
      ANSWER=("y")
    fi
    case ${ANSWER:0:1} in
      y|Y )
        apt-get install "${INSTALL_APP_LIST[@]}" -y --no-install-recommends

        pipenv install --deploy nose
        pipenv install --deploy coverage
        pipenv install --deploy pyqtgraph
        pipenv install --deploy capstone
        pipenv install --deploy cstruct
        pipenv install --deploy matplotlib
        # pipenv install --deploy "python-lzo>=1.14"

        if ! [[ -d external/binwalk ]]; then
          #git clone https://github.com/ReFirmLabs/binwalk.git external/binwalk
          git clone https://github.com/EMBA-support-repos/binwalk.git external/binwalk
        fi

        if ! [[ -d external/cpu_rec ]]; then
          git clone https://github.com/EMBA-support-repos/cpu_rec.git external/cpu_rec
          # this does not make sense for the read only docker container - we have to do it
          # during EMBA startup
          if ! [[ -d "$HOME"/.config/binwalk/modules/ ]]; then
            mkdir -p "$HOME"/.config/binwalk/modules/
          fi
          cp -pr external/cpu_rec/cpu_rec.py "$HOME"/.config/binwalk/modules/
          cp -pr external/cpu_rec/cpu_rec_corpus "$HOME"/.config/binwalk/modules/
        fi
        if ! command -v yaffshiv > /dev/null ; then
          if ! [[ -d external/binwalk/yaffshiv ]]; then
            git clone https://github.com/EMBA-support-repos/yaffshiv external/binwalk/yaffshiv
          fi
          cd ./external/binwalk/yaffshiv/ || ( echo "Could not install EMBA component yaffshiv" && exit 1 )
          python3 setup.py install
          cd "$HOME_PATH" || ( echo "Could not install EMBA component yaffshiv" && exit 1 )
        else
          echo -e "$GREEN""yaffshiv already installed""$NC"
        fi

        if ! command -v sasquatch > /dev/null ; then
          if ! [[ -d external/binwalk/sasquatch ]]; then
            git clone https://github.com/EMBA-support-repos/sasquatch external/binwalk/sasquatch
          fi
          cd external/binwalk/sasquatch || ( echo "Could not install EMBA component sasquatch" && exit 1 )
          wget https://github.com/devttys0/sasquatch/pull/47.patch
          patch -p1 < 47.patch
          CFLAGS="-fcommon -Wno-misleading-indentation" ./build.sh -y
          cd "$HOME_PATH" || ( echo "Could not install EMBA component sasquatch" && exit 1 )
        else
          echo -e "$GREEN""sasquatch already installed""$NC"
        fi

        if ! command -v jefferson > /dev/null ; then
          if ! [[ -d external/binwalk/jefferson ]]; then
            git clone https://github.com/EMBA-support-repos/jefferson external/binwalk/jefferson
          fi

          # while read -r TOOL_NAME; do
          #   pipenv install --deploy "$TOOL_NAME"
          # done < ./external/binwalk/jefferson/requirements.txt

          pipenv install --deploy -r ./external/binwalk/jefferson/requirements.txt
          cd ./external/binwalk/jefferson/ || ( echo "Could not install EMBA component jefferson" && exit 1 )
          python3 ./setup.py install
          cd "$HOME_PATH" || ( echo "Could not install EMBA component jefferson" && exit 1 )
        else
          echo -e "$GREEN""jefferson already installed""$NC"
        fi

        if ! command -v unstuff > /dev/null ; then
          mkdir -p ./external/binwalk/unstuff
          wget --no-check-certificate -O ./external/binwalk/unstuff/stuffit520.611linux-i386.tar.gz https://downloads.tuxfamily.org/sdtraces/BottinHTML/stuffit520.611linux-i386.tar.gz
          tar -zxv -f ./external/binwalk/unstuff/stuffit520.611linux-i386.tar.gz -C ./external/binwalk/unstuff
          cp ./external/binwalk/unstuff/bin/unstuff /usr/local/bin/
        else
          echo -e "$GREEN""unstuff already installed""$NC"
        fi

        if ! command -v cramfsck > /dev/null ; then
          if [[ -f "/opt/firmware-mod-kit/trunk/src/cramfs-2.x/cramfsck" ]]; then
            ln -s /opt/firmware-mod-kit/trunk/src/cramfs-2.x/cramfsck /usr/bin/cramfsck
          fi

          if ! [[ -d external/binwalk/cramfs-tools ]]; then
            git clone https://github.com/EMBA-support-repos/cramfs-tools external/binwalk/cramfs-tools
          fi
          make -C ./external/binwalk/cramfs-tools/
          install ./external/binwalk/cramfs-tools/mkcramfs /usr/local/bin
          install ./external/binwalk/cramfs-tools/cramfsck /usr/local/bin
        else
          echo -e "$GREEN""cramfsck already installed""$NC"
        fi

        if ! [[ -d external/binwalk/ubi_reader ]]; then
          git clone https://github.com/EMBA-support-repos/ubi_reader external/binwalk/ubi_reader
        fi
        cd ./external/binwalk/ubi_reader || ( echo "Could not install EMBA component ubi_reader" && exit 1 )
        python3 setup.py install
        cd "$HOME_PATH" || ( echo "Could not install EMBA component ubi_reader" && exit 1 )

        if command -v binwalk > /dev/null ; then
          echo "WARNING: Uninstalling binwalk version"
          cd ./external/binwalk || ( echo "Could not install EMBA component binwalk" && exit 1 )
          sudo apt remove binwalk python3-binwalk -y
          python3 setup.py uninstall
          cd "$HOME_PATH" || ( echo "Could not install EMBA component binwalk" && exit 1 )
        fi

        if ! command -v binwalk > /dev/null ; then
          cd ./external/binwalk || ( echo "Could not install EMBA component binwalk" && exit 1 )
          python3 setup.py install
          cd "$HOME_PATH" || ( echo "Could not install EMBA component binwalk" && exit 1 )
        fi

        if [[ -d ./external/binwalk ]]; then
          rm ./external/binwalk -r
        fi

        if [[ -f "/usr/local/bin/binwalk" ]] ; then
          echo -e "$GREEN""binwalk installed successfully""$NC"
        elif [[ ! -f "/usr/local/bin/binwalk" ]] ; then
          echo -e "$ORANGE""binwalk installation failed - check it manually""$NC"
        fi
      ;;
    esac
  fi
} 
