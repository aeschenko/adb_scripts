# records video from device and moves the video on your computer
# Usage: "sh video.sh 100" if you need to record 100 seconds
# 15 seconds by default (if runned as "sh video.sh")

DEFAULT_TIME=15
MAX_TIME=180

sdk_version=$( adb shell getprop | grep -i "ro.build.version.sdk")
sdk_version=${sdk_version#*:}
sdk_version=${sdk_version#*[}
sdk_version=${sdk_version%]*}

# Kitkat or later
if [[ $sdk_version<19 ]]; then
    echo "Recording is not supported on the OS older than Kitkat or device is not connected"
    exit
fi

DATE=$(date "+%s")
FILE="/sdcard/$DATE.mp4"

if [ -n "$1" ]; then
    if [ $1 -gt $MAX_TIME ]; then
        TIME=$MAX_TIME
        echo "Can't record more than $MAX_TIME seconds."
    else
        TIME=$1
    fi
else
    echo "Setting up time=$DEFAULT_TIME. You can run script as [sh video.sh 60] if you need 60 seconds, for example."
    TIME=$DEFAULT_TIME
fi

echo "Recording started as $FILE for $TIME seconds."
adb shell screenrecord --bit-rate 8000000 --time-limit $TIME $FILE &> /dev/null
echo "Recording finished. Pulling $FILE into current folder:"
adb pull $FILE
adb shell rm $FILE