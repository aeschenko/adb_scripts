# installs the last downloaded .apk file from Downloads
# Usage: "sh install_freshest.sh"

alarmshown=0
while [[ $(ls -t ~/Downloads/* | head -1) == *.apk.~ ]]; do
    timeout=1s
    if [[ $alarmshown == 0 ]]; then
        echo "It looks like apk file is downlading now. The script will continue when downloading is finished."
        alarmshown=1
    fi
    sleep $timeout
done

FILE=$(ls -t ~/Downloads/*.apk | head -1)

sdk_version=$(adb shell getprop | grep -i "ro.build.version.sdk")

sdk_version=${sdk_version#*:}
sdk_version=${sdk_version#*[}
sdk_version=${sdk_version%]*}

if [[ $sdk_version<17 ]]
then
	adb install -r "$FILE"
else 
	adb install -r -d "$FILE"
fi
