incus launch images:ubuntu/25.10 flutter

incus config set flutter security.nesting true

incus config device add flutter kvm unix-char path=/dev/kvm

incus config device add flutter amdgpu gpu

incus config device add flutter wayland-socket proxy \
connect=unix:/run/user/1000/wayland-1 \
listen=unix:/tmp/wayland-0 \
bind=container \
uid=1000 gid=1000 \
mode=0770


# sometimes to recover when the wayland-0 socket is gone
incus config device remove flutter wayland-socket


incus exec flutter -- apt update

incus exec flutter -- apt-get install -y \
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

incus exec flutter -- usermod --append --groups kvm ubuntu

incus exec flutter -- su - ubuntu


export ANDROID_HOME=~/android
export PATH=$PATH:~/flutter/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:~/.local/bin
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
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
incus file push -r ./scripts android-dev/home/ubuntu/the_app/
