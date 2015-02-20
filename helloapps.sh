# installs N Helloworlds to connected device
# Usage: "sh helloapps.sh 5" if you need 5 apps installed
# installs 1 Helloworld if N not provided
# Please install ant ("brew install ant") and android-sdk ("brew install android-sdk") before using the script

if [[ $(adb devices | wc -l) == "       2" ]]; then         #[adb devices] outputs 2 lines if no device/emulator connected
    echo "No device or emulator connected, closing the script."
    exit
fi

if [ -n "$1" ]; then
	apps=$1
else
	apps=1
fi

DATE=$(date "+%s")
package=com.aeschenko.helloapps$DATE

for i in `seq 1 $apps`; do
    android create project -n helloapps -t 1 -p helloapps -k $package$i -a Helloapps  &> /dev/null
    wait
    cd helloapps/
    wait
    ant debug install  &> /dev/null
    echo "App #$i $package$i installed."
    wait
    cd ..
    wait
    rm -r helloapps/
    wait
done