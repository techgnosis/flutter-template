incus launch images:ubuntu/25.10 android-dev


incus config device add android-dev kvm unix-char path=/dev/kvm

incus config device add android-dev amdgpu gpu

incus exec android-dev -- mkdir -p /run/user/1000

incus config device add android-dev wayland-socket proxy \
connect=unix:/run/user/1000/wayland-1 \
listen=unix:/tmp/wayland-0 \
bind=container \
uid=1000 gid=1000 \
mode=0770

# MAYBE
incus config device remove android-dev wayland-socket

# MAYBE
incus config set android-dev security.nesting true


incus exec android-dev -- apt update

incus exec android-dev -- apt-get install -y \
curl \
wget \
micro \
git \
unzip \
xz-utils \
openjdk-17-jdk \
xwayland \
libegl1 \
libpulse0

incus exec android-dev -- usermod --append --groups kvm ubuntu

incus exec android-dev -- su - ubuntu



export ANDROID_HOME=~/android
export PATH=$PATH:~/flutter/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:~/.local/bin
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export XDG_RUNTIME_DIR=/run/user/1000
export WAYLAND_DISPLAY=/tmp/wayland-0
export DISPLAY=:0

curl -fsSL https://claude.ai/install.sh | bash

curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash


wget https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip
unzip commandlinetools-linux-14742923_latest.zip
mkdir -p ~/android/cmdline-tools
mv cmdline-tools/ android/cmdline-tools/latest
rm commandlinetools-linux-14742923_latest.zip

yes | sdkmanager --licenses

# use these to check for what version you want
sdkmanager --list | grep -i android-36
sdkmanager --list | grep -i tools

sdkmanager \
"platforms;android-36.1" \
"system-images;android-36.1;google_apis;x86_64" \
"platform-tools" \
"build-tools;36.1.0"

echo "no" | avdmanager create avd \
--name flutter_emulator \
--package "system-images;android-36.1;google_apis;x86_64" \
--device "pixel"

emulator -list-avds

adb start-server

Xwayland :0

start a new terminal

emulator \
-avd flutter_emulator \
-gpu host \
-no-audio \
-no-metrics

start a new terminal

git clone https://github.com/flutter/flutter.git -b stable
flutter
flutter config --no-enable-linux-desktop
flutter config --no-enable-web
flutter doctor

mkdir the_app
cd the_app
flutter create --platforms android .

incus file push -r ./scripts android-dev/home/ubuntu/test_app/
