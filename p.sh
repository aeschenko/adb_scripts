# outputs apk version
# usage: "sh p.sh yappstore-release.apk"

aapt d badging $1 | grep package