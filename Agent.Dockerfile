# Use a lightweight Debian-based image for 2026 stability
FROM debian:bookworm-slim

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk-headless \
    python3 python3-pip wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Set up Android SDK (CLI tools only)
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline.zip && \
    unzip cmdline.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm cmdline.zip

# 3. Install Flutter
ENV FLUTTER_HOME=/opt/flutter
RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME}
ENV PATH="${PATH}:${FLUTTER_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

# 4. Accept Licenses & Configure ADB
# Crucial: Tells Flutter to look for the 'adb-bridge' container instead of localhost
ENV ANDROID_ADB_SERVER_ADDRESS=adb-bridge
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" && \
    flutter config --no-analytics && \
    flutter doctor

# 5. Set up workspace
WORKDIR /workspace

# Keep the container alive for the agent/bash
CMD ["/bin/bash"]
