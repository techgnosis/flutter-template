# bash

export ANDROID_HOME=~/android
export PATH=$PATH:~/flutter/bin
export PATH=$PATH:$ANDROID_HOME/emulator/
export PATH=$PATH:~/.local/bin/
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools/

# Claude
curl -fsSL https://claude.ai/install.sh | bash

# Beads
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash


# Android
Go here
https://developer.android.com/studio
Scroll down to "Command line tools only". You can't copy the link. Click on the Linux link. This gives you an agreement popup with a link at the bottom. You can copy THAT link.

wget https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip
This includes `sdkmanager`

`mkdir -p ~/android/cmdline-tools`
`unzip commandlinetools-linux-14742923_latest.zip`
`mv cmdline-tools/ android/cmdline-tools/latest`

```
sdkmanager --licenses
sdkmanager --list | grep -i android-36
sdkmanager --list | grep -i tools
```


```
sdkmanager \
"platforms;android-36.1" \
"system-images;android-36.1;google_apis;x86_64" \
"platform-tools" \
"build-tools;36.1.0"
```

echo "no" | avdmanager create avd \
--name flutter_emulator \
--package "system-images;android-36.1;google_apis;x86_64" \
--device "pixel"

emulator -list-avds

adb start-server

emulator \
-avd flutter_emulator \
-gpu host \
-no-audio \
-no-metrics


adb devices

# Flutter SDK
Turns out the flutter archive is actually a packaged git repo. Might as well just clone it

`git clone https://github.com/flutter/flutter.git -b stable`

`flutter`
This will download the Dart SDK on the first run

`flutter config --no-enable-linux-desktop`
`flutter config --no-enable-web`

`flutter doctor`

# Claude notes


`incus exec flutter -- mkdir -p /run/user/0`

```
incus config device add flutter wayland-socket proxy \
connect=unix:/run/user/1000/wayland-1 \
listen=unix:/run/user/1000/wayland-0 \
bind=container \
uid=1000 gid=1000 \
mode=0770
```
