# updates the app in system path, libs are updated as well
# Usage: "sh update_system_app.sh /Users/aeschenko/Downloads/appstore-dnsYKit-release-signed(2).apk" to update yappstore-release.apk in system
# works fine with android 4.2-4.4, arm-v7a and x86


platform_adb=$(adb shell getprop | grep "ro.product.cpu.abi]");

if [[ $platform_adb == *armeabi* ]]
then
    platform=armeabi;
elif [[ $platform_adb == *x86* ]]
then
    platform=x86;
else
    echo "Unknown platform (not x86 and not armeabi-v7a) or device is not connected"
    exit
fi

rootResult=$(adb root)
if [[ $rootResult == "" || $rootResult == *restarting* ]]
then
#when restarting as root, need to wait for 1 seconds before next adb command
	sleep 1s
    echo "Root granted, which is good"
elif [[ $rootResult == *already* ]]
then
    echo "Root granted, which is good"
else
	echo "Can't root. This is not going to work. Breaking the script."
	exit
fi

remountResult=$(adb remount)
if [[ $remountResult == *succe* ]]
then
	echo "Remount succeeded, which is good again."
else
	echo "Can't remount. This is not going to work. Breaking the script."
exit
fi

sdk_version=$( adb shell getprop | grep -i "ro.build.version.sdk")

sdk_version=${sdk_version#*:}
sdk_version=${sdk_version#*[}
sdk_version=${sdk_version%]*}

# Kitkat or later
if [[ $sdk_version<19 ]]
then
    system_path=system/app;
else
    system_path=system/priv-app;

fi

if [ "$1" == "newest" ]
then
    input_file=$(ls -t ~/Downloads/*.apk | head -1)
else
    input_file="$1"
fi

input_file_name=$( basename "$input_file" )
workfolder=updateapptempfolder

#let's hardcode all known apk names

if [[ $input_file_name == *keyboard* ]]
then
    apk_name=ykeyboard-release.apk;
elif [[ $input_file_name == *ocation*roxy* ]]
then
    apk_name=ylocation_proxy-release.apk;
elif [[ $input_file_name == *rasp* ]]
then
    apk_name=yrasp-release.apk;
elif [[ $input_file_name == *disk* ]]
then
    if [[ $platform == armeabi ]]
    then
        apk_name=ydisk-release.apk;
    elif [[ $platform == x86 ]]
    then
        apk_name=ydisk_x86-release.apk;
    fi
elif [[ $input_file_name == *navi* ]]
then
    if [[ $platform == armeabi ]]
    then
        apk_name=ynavi-release.apk;
    elif [[ $platform == x86 ]]
    then
        apk_name=ynavi_x86-release.apk;
    fi
elif [[ $input_file_name == *browser* ]]
then
    if [[ $platform == armeabi ]]
    then
        apk_name=ybrowser-release.apk;
    elif [[ $platform == x86 ]]
    then
        apk_name=ybrowser_x86-release.apk;
    fi
elif [[ $input_file_name == *translate* ]]
then
    apk_name=ytranslate-release.apk;
elif [[ $input_file_name == *market* ]]
then
    apk_name=ymarket-release.apk;
elif [[ $input_file_name == *afisha* ]]
then
    apk_name=yafisha-release.apk;
elif [[ $input_file_name == *ocation*rovider* ]]
then
    apk_name=ynetwork_location_provider-release.apk;
elif [[ $input_file_name == *etting* ]]
then
    apk_name=Settings.apk;
elif [[ $input_file_name == *lay*ervices* ]]
then
    apk_name=yplay_services-release.apk;
elif [[ $input_file_name == *yshell* ]]
then
    apk_name=yshell-release.apk;
elif [[ $input_file_name == *appstore* ]]
then
    apk_name=yappstore-release.apk;
elif [[ $input_file_name == *ycaldav* ]]
then
    apk_name=ycaldav_sync-release.apk;
elif [[ $input_file_name == *onetimeinit* ]]
then
    apk_name=yonetimeinit-release.apk;
elif [[ $input_file_name == *etupwizard* ]]
then
    apk_name=ysetupwizard-release.apk;
elif [[ $input_file_name == *peech*ecognition* ]]
then
    apk_name=yspeech_recognition-release.apk;
else
    apk_name="$input_file_name";
fi

destination=$system_path/$apk_name

if [[ "$apk_name" =~ \ |\' ]]
then
    echo "Whoa-whoa-whoa! Your file name [$apk_name] contains spaces - this is not going to work. Please rename. Thanks"
    exit
fi

echo "Platform recongized as $platform"

app_package=$(aapt d badging "$input_file"| grep  "package: name=" );
app_package=${app_package#*"'"}
app_package=${app_package%"versionCode"*}
app_package=${app_package%"'"*}

app_location=$(adb shell pm path $app_package)

if [[ $app_location == */data* ]]
then
    adb shell pm uninstall $app_package &> /dev/null
    app_location=$(adb shell pm path $app_package)
fi

if [[ $app_location == */system* ]]
then

    destination=${app_location#*package:}
    # this is hack in order to get correct destination for apk
    destination=${destination%.apk*}
    destination=$destination.apk
fi

adb push "$input_file" $destination &> /dev/null
adb shell chmod 644 $destination

echo "$destination updated successfully, I suppose"

rm -rf $workfolder &> /dev/null
unzip "$input_file" -d ./$workfolder &> /dev/null
find ./$workfolder/lib/$platform* -mindepth 1 -type f -name '*.so' | while read -r FILE; do
    liba=$( basename "$FILE" )
	adb shell rm system/lib/$liba &> /dev/null
	adb push $FILE system/lib/ &> /dev/null
	adb shell chmod 644 system/lib/$liba
	echo "system/lib/$liba updated successfully, I suppose"
done

if [[ $platform == x86 ]]
then
find ./$workfolder/lib/*arm* -mindepth 1 -type f -name '*.so' | while read -r FILE; do
    	liba=$( basename "$FILE" )
	adb shell rm system/lib/arm/$liba &> /dev/null
	adb push $FILE system/lib/arm/ &> /dev/null
	adb shell chmod 644 system/lib/arm/$liba
	echo "system/lib/arm/$liba updated successfully, I suppose"
done
fi

rm -rf $workfolder