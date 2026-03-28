#!/usr/bin/env bash

function fetch() {
    local output="$1" url="$2"
    if command -v curl &>/dev/null; then
        while true; do
            curl -Ls "$url" > "$output" 2>/dev/null || echo "- Failed to download requested file."
            echo "" >> "$output"
            break
        done
    elif command -v wget &>/dev/null; then
        while true; do
            wget --no-check-certificate -qO - "$url" > "$output" 2>/dev/null || echo "- Failed to download requested file."
            echo "" >> "$output"
            break
        done
    fi
}

# delete the old sources.
rm -rf whitelist.txt profiles/*

# fetch sources from @git::ZG089/Re-Malwack:
fetch whitelist.txt https://raw.githubusercontent.com/ZG089/Re-Malwack/main/whitelist.txt
cd profiles/
for i in aggressive default lite; do
    fetch "${i}_rmlwk" "https://raw.githubusercontent.com/ZG089/Re-Malwack/tree/main/module/profiles/$i.txt"
done
echo "- Finished fetching sources from Re-Malwack's github source!"
echo "  Updating sources now..."

# git add em' and push em'
COMMIT_HASH=$(curl -s https://api.github.com/repos/ZG089/Re-Malwack/commits | grep '"sha"' | head -n 1 | cut -d '"' -f4 | cut -c 1-6)
git add * ../*
git commit -m "eva-source: Update sources to $COMMIT_HASH"
git push
