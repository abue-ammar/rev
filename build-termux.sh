#!/usr/bin/env bash

set -e

pr() { echo -e "\033[0;32m[+] ${1}\033[0m"; }
ask() {
	local y
	for ((n = 0; n < 3; n++)); do
		pr "$1 [y/n]"
		if read -r y; then
			if [ "$y" = y ]; then
				return 0
			elif [ "$y" = n ]; then
				return 1
			fi
		fi
		pr "Asking again..."
	done
	return 1
}

pr "Ask for storage permission"
until
	yes | termux-setup-storage >/dev/null 2>&1
	ls /sdcard >/dev/null 2>&1
do sleep 1; done
if [ ! -f ~/.messenger_revanced_"$(date '+%Y%m')" ]; then
	pr "Setting up environment..."
	yes "" | pkg update -y && pkg upgrade -y && pkg install -y git curl jq openjdk-17 zip
	: >~/.messenger_revanced_"$(date '+%Y%m')"
fi
mkdir -p /sdcard/Download/messenger-revanced/

if [ -d messenger-revanced ] || [ -f config.toml ]; then
	if [ -d messenger-revanced ]; then cd messenger-revanced; fi
	pr "Checking for messenger-revanced updates"
	git fetch
	if git status | grep -q 'is behind\|fatal'; then
		pr "messenger-revanced is not synced with upstream."
		pr "Cloning messenger-revanced. config.toml will be preserved."
		cd ..
		cp -f messenger-revanced/config.toml .
		rm -rf messenger-revanced
		git clone https://github.com/abue-ammar/messenger-revanced --recurse --depth 1
		mv -f config.toml messenger-revanced/config.toml
		cd messenger-revanced
	fi
else
	pr "Cloning messenger-revanced."
	git clone https://github.com/abue-ammar/messenger-revanced --depth 1
	cd messenger-revanced
	grep -q 'messenger-revanced' ~/.gitconfig 2>/dev/null ||
		git config --global --add safe.directory ~/messenger-revanced
fi

[ -f ~/storage/downloads/messenger-revanced/config.toml ] ||
	cp config.toml ~/storage/downloads/messenger-revanced/config.toml

printf "\n"
until
	if ask "Open 'config.toml' to configure builds?"; then
		am start -a android.intent.action.VIEW -d file:///sdcard/Download/messenger-revanced/config.toml -t text/plain
	fi
	ask "Setup is done. Do you want to start building?"
do :; done
cp -f ~/storage/downloads/messenger-revanced/config.toml config.toml

./build.sh

cd build
PWD=$(pwd)
for op in *; do
	[ "$op" = "*" ] && {
		pr "glob fail"
		exit 1
	}
	mv -f "${PWD}/${op}" ~/storage/downloads/messenger-revanced/"${op}"
done

pr "Outputs are available in /sdcard/Download/messenger-revanced folder"
am start -a android.intent.action.VIEW -d file:///sdcard/Download/messenger-revanced -t resource/folder
sleep 2
am start -a android.intent.action.VIEW -d file:///sdcard/Download/messenger-revanced -t resource/folder
