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

# Android SDK
NDROID_SDK_ROOT=/opt/android-sdk
mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline.zip && \
unzip cmdline.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
rm cmdline.zip
