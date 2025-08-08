# Use Ubuntu as base image for better compatibility with Flutter
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"
ENV ANDROID_HOME="/opt/android-sdk"
ENV ANDROID_SDK_ROOT="$ANDROID_HOME"
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Install basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter and Android dependencies
RUN apt-get update && apt-get install -y \
    libglu1-mesa \
    openjdk-17-jdk \
    usbutils \
    android-tools-adb \
    android-tools-fastboot \
    && rm -rf /var/lib/apt/lists/*

# Install Linux desktop build dependencies
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Download and install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Pre-download development binaries
RUN flutter precache

# Accept Android licenses and install Android SDK
RUN mkdir -p $ANDROID_HOME && \
    cd $ANDROID_HOME && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip && \
    rm commandlinetools-linux-9477386_latest.zip && \
    mkdir -p cmdline-tools/latest && \
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true

# Install Android SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Enable flutter web and linux
RUN flutter config --enable-web
RUN flutter config --enable-linux-desktop

# Create plugdev group and add to it
RUN groupadd -f plugdev

# Create a non-root user for development
RUN groupadd --gid 1000 developer \
    && useradd --uid 1000 --gid developer --shell /bin/bash --create-home developer \
    && usermod -a -G plugdev developer \
    && usermod -a -G sudo developer \
    && echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Give developer user ownership of Flutter and Android SDK
RUN chown -R developer:developer $FLUTTER_HOME $ANDROID_HOME

# Switch to developer user
USER developer

# Set working directory
WORKDIR /workspace

# Expose ports for web development and debugging
EXPOSE 3000 8080 9000

# Keep container running
CMD ["sleep", "infinity"]
