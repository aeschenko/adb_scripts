# makes N screenshots in a row, like video frame by frame
# Usage: "sh screenshot.sh 5" if you need 5 screenshots
# makes 1 screenshot if N not provided

if [[ $(adb devices | wc -l) == "       2" ]]; then         #[adb devices] outputs 2 lines if no device/emulator connected
    echo "No device or emulator connected, closing the script."
    exit
fi

DEVICE=$(adb shell getprop | grep product.device)
DEVICE=${DEVICE#*:}
DEVICE=${DEVICE#*[}
DEVICE=${DEVICE%]*}

DATE=$(date +%Y%m%d%H%M%S)

APPEND=$DEVICE-$DATE

adb shell mkdir sdcard/$APPEND
if [ -n "$1" ]; then
	steps=$1
	dir=$APPEND
else
	steps=1
	dir=""
fi

for i in `seq 1 $steps`; do 
    adb shell screencap -p /sdcard/$APPEND/$APPEND$i.png
done
adb pull /sdcard/$APPEND $dir
adb shell rm -rf /sdcard/$APPEND