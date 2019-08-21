FROM openjdk:8

LABEL maintainer="Adam Hansen"

# -----------------------------------------------------------------------------
# Environment setup
# -----------------------------------------------------------------------------
ENV GRADLE_VERSION=4.10.3
ENV NODE_VERSION=10.16.3
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global user.name "${GIT_NAME}"

# -----------------------------------------------------------------------------
# Install Android
# -----------------------------------------------------------------------------
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/tools_r25.2.5-linux.zip" \
    ANDROID_BUILD_TOOLS_VERSION=28.0.3 \
    ANDROID_APIS="android-28" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$GRADLE_HOME/bin

WORKDIR /opt

RUN  \
    dpkg --add-architecture i386 \
    && apt-get -qq update \
    && apt-get -qq install -y wget curl gradle libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
    # Installs Android SDK
    && mkdir android && cd android  \
    && wget -O tools.zip ${ANDROID_SDK_URL} \
    && unzip tools.zip && rm tools.zip \
    && echo y | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} \
    && chmod a+x -R $ANDROID_HOME \
    && chown -R root:root $ANDROID_HOME

# -----------------------------------------------------------------------------
# Install Node and packages
# -----------------------------------------------------------------------------
RUN \
    apt-get update -qqy \
    && curl --retry 3 -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" \
    && npm install -g cordova ionic cordova-res firebase-tools --unsafe-perm

# -----------------------------------------------------------------------------
# Cleanup!
# -----------------------------------------------------------------------------
RUN \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get autoremove -y \
    && apt-get clean

# -----------------------------------------------------------------------------
# Run final actions
# -----------------------------------------------------------------------------
WORKDIR /app
EXPOSE 8100 35729 53703