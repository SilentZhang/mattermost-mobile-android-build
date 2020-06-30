FROM npetrovsky/docker-android-sdk-ndk

MAINTAINER zhangchang<zhangchang1979@gmail.com>

RUN apt-get update && \
    apt-get install -y make autoconf automake build-essential python-dev libtool pkg-config libssl-dev g++ zlib1g-dev vim wget


RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash && \
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

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
    
RUN wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.1.tar.gz && \
    tar zxvf ruby-2.7.1.tar.gz && \
    cd ruby-2.7.1 && \
    ./configure && \
    make && \
    make install && \
    cd

RUN gem install nokogiri && \
    gem install -n /usr/local/bin fastlane -NV

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
