# makes N screenshots in a row, like video frame by frame
# Usage: "sh screenshot.sh 5" if you need 5 screenshots
# makes 1 screenshot if N not provided

DATE=$(date "+%s")
adb shell mkdir sdcard/$DATE
if [ -n "$1" ]; then
	steps=$1
	dir=$DATE
else
	steps=1
	dir=""
fi
for i in `seq 1 $steps`; do 
adb shell screencap -p /sdcard/$DATE/$DATE$i.png
done
adb pull /sdcard/$DATE $dir
adb shell rm -rf /sdcard/$DATE 