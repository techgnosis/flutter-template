Don't want to use the MCP server. Agents are good at CLIs. Let it talk to the flutter daemon directly



Steps for agentic flutter dev with hot reload
1. flutter run --machine first creates a Debug APK (capable of hot reload) and puts flutter into daemon mode
2. The daemon runs `adb install app.apk` which installs the APK into the emulator
3. The app itself, being written with the Flutter SDK, is able to open a port inside the emulator network (not visible to the outside network) called the Dart VM Service Port
4. The daemon uses adb to create a tunnel to the Dart VM Service Port
5. The agent sends a message to Flutter daemon STDIN which tells it to use the Dart compiler in the Flutter SDK to recompile any new dart into a "delta"
6. The delta is sent to the emulator via adb and updates only the new parts of the app, i.e. a hot reload

How to see the emulator
adb connect localhost:5555
scrcpy

use Incus system containers. Much too complicated for OCI containers.

# Incus
Just use the 'dir' storage driver for now. I am not doing anything complex.

Don't worry about cloud-init yet either. Record all the steps to get a working environment in this project. Get everything working and then you can cloud-init to automate a working environment

Just run as root user in the incus container

`sudo incus project switch default`
`sudo incus project set user-1000 restricted=false`
`incus config device add flutter kvm unix-char path=/dev/kvm`
`incus config device add flutter amdgpu gpu`
`incus config set flutter security.nesting true`




# apt
```
apt-get update
apt-get install -y \
curl \
wget \
git \
unzip \
xz-utils \
openjdk-17-jdk \
xvfb
```

# bash
export BOT=true
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

xvfb :1 -screen 0 1920x1080x24 &
DISPLAY=:1 emulator -avd flutter_emulator -gpu host -no-audio -no-metrics -no-window &>/dev/null &

adb devices

# Flutter SDK
Turns out the flutter archive is actually a packaged git repo. Might as well just clone it

`git clone https://github.com/flutter/flutter.git -b stable`

`flutter`
This will download the Dart SDK on the first run

`flutter config --no-enable-linux-desktop`
`flutter config --no-enable-web`

`flutter doctor`
