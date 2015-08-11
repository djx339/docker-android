FROM ubuntu:14.04
MAINTAINER Daniel D <djx339@gmail.com>

ENV ANDROID_SDK_VERSION r24.3.3
ENV ANDROID_NDK_VERSION r9d
ENV ANT_VERSION 1.9.6
ENV MAVEN_VERSION 3.3.3
ENV GRADLE_VERSION 2.5

# Install java7
RUN apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:webupd8team/java \
    && apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true \
    | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer

# Install Deps
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --force-yes \
    expect git wget libc6-i386 lib32stdc++6 lib32gcc1 \
    lib32ncurses5 lib32z1 python curl unzip make cmake gcc g++ swig openssh-server

# Install Android SDK
RUN cd /opt \
    && android_sdk_url=http://dl.google.com/android/android-sdk_${ANDROID_SDK_VERSION}-linux.tgz \
    && wget --output-document=android-sdk.tgz --quiet ${android_sdk_url} \
    && tar zxf android-sdk.tgz \
    && rm -f android-sdk.tgz \
    && chown -R root.root android-sdk-linux

# Install Android NDK
RUN cd /opt \
    && android_ndk_url=http://dl.google.com/android/ndk/android-ndk-r9d-linux-x86_64.tar.bz2 \
    && wget --output-document=android-ndk.tar.bz2 --quiet ${android_ndk_url} \
    && tar jxf android-ndk.tar.bz2 \
    && rm -f android-ndk.tar.bz2 \
    && chown -R root.root android-ndk-${ANDROID_NDK_VERSION}

# Install Ant
RUN cd /opt \
    && ant_url=http://apache.mirrors.pair.com//ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && wget --output-document=apache-ant.tar.gz --quiet ${ant_url} \
    && tar zxf apache-ant.tar.gz \
    && rm -f apache-ant.tar.gz \
    && chown -R root.root apache-ant-${ANT_VERSION}

# Install Maven
RUN cd /opt \
    && maven_url=http://mirror.olnevhost.net/pub/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz \
    && wget --output-document=apache-maven.tar.gz --quiet ${maven_url} \
    && tar zxf apache-maven.tar.gz \
    && rm -f apache-maven.tar.gz \
    && ls \
    && chown -R root.root apache-maven-${MAVEN_VERSION}

# Install Gradle
RUN cd /opt \
    && gradle_url=https://services.gradle.org/distributions/gradle-2.5-bin.zip \
    && wget --output-document=gradle.zip --quiet ${gradle_url} \
    && unzip gradle.zip \
    && rm -f gradle.zip \
    && chown -R root.root gradle-${GRADLE_VERSION}

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_NDK_HOME /opt/android-ndk-${ANDROID_NDK_VERSION}
ENV ANT_HOME /opt/apache-ant-${ANT_VERSION}
ENV MAVEN_HOME /opt/apache-maven-${MAVEN_VERSION}
ENV GRADLE_HOME /opt/gradle-${GRADLE_VERSION}
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
ENV PATH ${PATH}:${ANDROID_NDK_HOME}
ENV PATH ${PATH}:${ANT_HOME}/bin
ENV PATH ${PATH}:${MAVEN_HOME}/bin
ENV PATH ${PATH}:${GRADLE_HOME}/bin

# Install sdk elements
RUN echo y | android --verbose update sdk --all --no-ui --filter "platform-tools,tools,build-tools-22.0.1,android-19,addon-google_apis-google-19,addon-google_apis_x86-google-19,extra-android-m2repository,extra-android-support,extra-google-m2repository"
