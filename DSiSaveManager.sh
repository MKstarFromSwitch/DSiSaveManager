#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

scriptdir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GREEN=$'\033[0;32m'
RESET=$'\033[0m'
config="$scriptdir/config.ini"

if [[ ! -f "$config" ]]; then
    echo "config.ini not found."
    exit 1
fi

SDCARD="$(crudini --get "$config" DSiSaveManager SdRoot)"

if [[ "$SDCARD" == "/path/to/sd" ]]; then
    echo "SdRoot is not configured in config.ini."
    exit 1
fi

echo
echo -e "${GREEN}DSiSaveManager 1.0${RESET}"
echo "This was bugfixed by ChatGPT"
echo
echo "Your current configured SD card path is: $SDCARD"

read -rp "Is this correct? [Y/n] " ans

if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
    echo "OK."
else
    echo "Fix SdRoot in config.ini."
    exit 1
fi

command -v clear >/dev/null 2>&1 && clear

echo -e "${GREEN}DSiSaveManager 1.0${RESET}"
echo "This was bugfixed by ChatGPT"
echo
echo "1. Backup save data"
echo "2. Restore save data"

read -rp "Choose: " ans

case "$ans" in
    1)
        echo

        if ! command -v zenity >/dev/null 2>&1; then
            echo "Zenity is not installed."
            exit 1
        fi

        echo "Select any file in your save folder."

        path="$(
            zenity --file-selection --title="Select any file in your save folder"
        )"

        [[ -z "$path" ]] && echo "No file selected." && exit 1

        savedir="$(dirname -- "$path")"

        echo "Backing up save files..."

        mkdir -p "$scriptdir/SaveBak"

        pushd "$savedir" >/dev/null

        files=( *.sav *.pub *.prv )

        if ((${#files[@]} == 0)); then
            echo "No save files found."
            popd >/dev/null
            exit 1
        fi

        cp -- "${files[@]}" "$scriptdir/SaveBak"

        popd >/dev/null

        echo "Backup complete!"
        exit 0
        ;;

    2)
        echo

        if ! command -v zenity >/dev/null 2>&1; then
            echo "Zenity is not installed."
            exit 1
        fi

        if [[ ! -d "$scriptdir/SaveBak" ]]; then
            echo "No backup folder found."
            exit 1
        fi

        echo "Select any file in your save folder."

        path="$(
            zenity --file-selection --title="Select any file in your save folder"
        )"

        [[ -z "$path" ]] && echo "No file selected." && exit 1

        savedir="$(dirname -- "$path")"

        pushd "$scriptdir/SaveBak" >/dev/null

        filearr=( *.sav *.pub *.prv )

        if ((${#filearr[@]} == 0)); then
            echo "No backup saves found."
            popd >/dev/null
            exit 1
        fi

        echo "Choose a save to restore below."

        PS3="Restore which save? "
        select save_to_restore in "${filearr[@]}"; do
            [[ -n "$save_to_restore" ]] && break
        done

        basename="${save_to_restore%.*}"

        for ext in sav pub prv; do
            file="$basename.$ext"
            [[ -f "$file" ]] && cp -- "$file" "$savedir"
        done

        popd >/dev/null

        echo "Restore complete!"
        exit 0
        ;;

    *)
        echo "Wrong option."
        exit 1
        ;;
esac
