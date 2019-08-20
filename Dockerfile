FROM npetrovsky/docker-android-sdk-ndk

MAINTAINER zhangchang<zhangchang1979@gmail.com>

RUN apt-get update && \
    apt-get install -y make autoconf automake build-essential python-dev libtool pkg-config libssl-dev g++ zlib1g-dev 

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs && \
    npm -g install react-native-cli

RUN git clone https://github.com/facebook/watchman.git && \
    cd watchman && \
    git checkout v4.9.0 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd

RUN apt-get install -y ruby-full && \
    gem install nokogiri && \
    gem install fastlane -NV

RUN git clone https://github.com/mattermost/mattermost-mobile.git && \
    cd mattermost-mobile/fastlane && \
    bundle install