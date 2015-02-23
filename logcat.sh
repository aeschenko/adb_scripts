DATE=$(date "+%s").txt
adb logcat -c
wait
adb logcat -v time 1>$DATE