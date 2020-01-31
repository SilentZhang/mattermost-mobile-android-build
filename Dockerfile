FROM ubuntu:18.04

MAINTAINER zhangchang<zhangchang1979@gmail.com>

ENV ANDROID_COMPILE_SDK="27"        \
    ANDROID_BUILD_TOOLS="28.0.3"    \
    ANDROID_SDK_TOOLS_REV="4333796" \
    ANDROID_CMAKE_REV="3.6.4111459" \
    ANDROID_CMAKE_REV_3_10="3.10.2.4988404"
    
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/platform-tools/:${ANDROID_NDK_HOME}:${ANDROID_HOME}/ndk-bundle:${ANDROID_HOME}/tools/bin/

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk curl wget git unzip file make autoconf automake build-essential python-dev libtool pkg-config libssl-dev g++ zlib1g-dev vim gpg

RUN    mkdir -p ${ANDROID_HOME} \
    && wget --quiet --output-document=${ANDROID_HOME}/android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_REV}.zip \
    && unzip -qq ${ANDROID_HOME}/android-sdk.zip -d ${ANDROID_HOME} \
    && rm ${ANDROID_HOME}/android-sdk.zip \
    && mkdir -p $HOME/.android \
    && echo 'count=0' > $HOME/.android/repositories.cfg

RUN    yes | sdkmanager --licenses > /dev/null \ 
    && yes | sdkmanager --update \
    && yes | sdkmanager 'tools' \
    && yes | sdkmanager 'platform-tools' \
    && yes | sdkmanager 'build-tools;'$ANDROID_BUILD_TOOLS \
    && yes | sdkmanager 'platforms;android-'$ANDROID_COMPILE_SDK \
    && yes | sdkmanager 'platforms;android-28' \
    && yes | sdkmanager 'extras;android;m2repository' \
    && yes | sdkmanager 'extras;google;google_play_services' \
    && yes | sdkmanager 'extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2' \
    && yes | sdkmanager 'extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2' \
    && yes | sdkmanager 'extras;google;m2repository' 

RUN    yes | sdkmanager 'cmake;'$ANDROID_CMAKE_REV \
       yes | sdkmanager --channel=3 --channel=1 'cmake;'$ANDROID_CMAKE_REV_3_10 \
    && yes | sdkmanager 'ndk-bundle' 

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

#RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
#    curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
#    curl -sSL https://get.rvm.io | bash -s stable

#RUN /bin/bash -c "source /etc/profile.d/rvm.sh"

#RUN rvm requirements && \
#    rvm install 2.6 && \
#    rvm use 2.6.3 --default 

RUN apt-get install -y ruby-full && \
    gem install nokogiri && \
    gem install fastlane -NV && \
    gem update --system

RUN cd /tmp && \
    wget https://raw.githubusercontent.com/mattermost/mattermost-mobile/master/fastlane/Gemfile -q && \
    wget https://raw.githubusercontent.com/mattermost/mattermost-mobile/master/fastlane/Gemfile.lock -q && \
    bundle install

RUN /usr/lib/jvm/java-8-openjdk-amd64/bin/keytool  -genkey -v -keystore ~/tci-mattermost.keystore -alias tci-mattermost -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=tci,OU=TCI,O=Dev,L=Tianjin,S=Tianjin,C=CN" -noprompt -storepass 123456 -keypass 123456 && \
    /usr/lib/jvm/java-8-openjdk-amd64/bin/keytool -importkeystore -srckeystore ~/tci-mattermost.keystore -destkeystore ~/tci-mattermost.keystore -deststoretype pkcs12 && \
    mkdir ~/.gradle && \
    echo "MATTERMOST_RELEASE_STORE_FILE=/root/tci-mattermost.keystore" >> ~/.gradle/gradle.properties && \
    echo "MATTERMOST_RELEASE_KEY_ALIAS=tci-mattermost" >> ~/.gradle/gradle.properties && \
    echo "MATTERMOST_RELEASE_PASSWORD=123456" >> ~/.gradle/gradle.properties

RUN apt-get update && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/* && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8
