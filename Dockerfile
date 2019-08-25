FROM adamino/android:latest

LABEL maintainer="Adam Hansen"

# -----------------------------------------------------------------------------
# Environment setup
# -----------------------------------------------------------------------------
ENV NODE_VERSION=10.16.3
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global user.name "${GIT_NAME}"

# -----------------------------------------------------------------------------
# Install Node and packages
# -----------------------------------------------------------------------------
RUN \
    apt-get update -qqy \
    && curl --retry 3 -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" \
    && npm install -g \
    # Ensure we have the latest version of npm!
    npm \
    ionic \
    cordova \
    # Needed for building assets!
    cordova-res \ 
    firebase-tools \
    --unsafe-perm

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
EXPOSE \
    # ionic dev server
    8100 \
    # livereload
    35729 \
    # websocket
    53703