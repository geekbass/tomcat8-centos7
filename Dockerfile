FROM centos:centos7
MAINTAINER wbassler23@gmail.com

# Environment Vars
#ENV JAVA_HOME /usr/java/jdk1.8.0_171-amd64/bin/java
ENV CATALINA_HOME /opt/tomcat 
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts
ENV JAVA_VERSION 8u171
ENV JAVA_BUILD 8u171-b11
ENV JAVA_DL_HASH 512cd62ec5174c3487ac17c61aaa89e8 
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.30
ENV TOMCAT_SHA512 f7e84fed604dc183dc1bdad07f3b025547d95d024ccfb05da68f5f45256f3082af6ba28c7f0148ae4ee43637248a0074c92bb12198ab58331d0c4f04906b86b6
ENV TOMCAT_FULL_URL https://www.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
#ENV GPG_KEYS 05AB33110949707C93A279E3D3EFE6B686867BA6 07E48665A34DCAFAE522E5E6266191C37C037D42 47309207D818FFD8DCD3F83F1931D684307A10A5 541FBE7D8F78B25E055DDEE13C370389288584E7 61B832AC2F1C5A90F0F9B00A1C506407564C17A3 713DA88BE50911535FE716F5208B0AB1D63011C7 79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED 9BA44C2621385CB966EBA586F72C284D731FABEE A27677289986DB50844682F8ACB77FC2E86E29AC A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23
ENV APACHE_NATIVE_VERSION 1.2.16
ENV APACHE_NATIVE_URL https://www.apache.org/dist/tomcat/tomcat-connectors/native/${APACHE_NATIVE_VERSION}/source/tomcat-native-${APACHE_NATIVE_VERSION}-src.tar.gz
ENV APACHE_NATIVE_SHA512 0345f85fbab406f25c25c8fc06bf55f3d166fa14bfcf542bddb5dc5db4c8c7bd0c5b71603d85261d71152ead3023b112144f2ffa5ede14ae8595013f79c802aa


# Install the Needful
RUN set -x \    
    && yum -y update \
    && yum -y install wget tar openssl unzip openssl-devel apr-devel make \
    && yum -y groupinstall "Development Tools"

# Install JDK, Copy Certs, Install 256 Bit Encryption
RUN set -x \
    && cd / \
    && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_BUILD}/${JAVA_DL_HASH}/jdk-${JAVA_VERSION}-linux-x64.rpm" \
    && yum localinstall jdk*.rpm -y \
    && rm -rf *.rpm \
    && wget  --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
        "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" \
    && unzip jce_policy-8.zip \
    && mv -f UnlimitedJCEPolicyJDK8/*.jar . \
    && rm -rf UnlimitedJCEPolicyJDK8 jce_policy-8.zip

# Final RPM clean up to save disk space
RUN set -e \
    && yum -y clean all \
    && rm -rf /var/cache/yum 

# Install Tomcat, Create User/Group, Configs, 
RUN mkdir -pv "${CATALINA_HOME}" \
    && mkdir -pv "${CATALINA_HOME}/ssl"

# Apache Native Libraries for SSL
RUN set -e \
    && curl -fSL "${APACHE_NATIVE_URL}" -o tomcat-native-${APACHE_NATIVE_VERSION}-src.tar.gz \
    #&& curl -fSL "$APACHE_NATIVE_URL.asc" -o native.tar.gz.asc \
    #&& gpg --verify native.tar.gz.asc  \
    && echo "${APACHE_NATIVE_SHA512} *tomcat-native-${APACHE_NATIVE_VERSION}-src.tar.gz" | sha512sum -c - \
    && tar -xvf tomcat-native-${APACHE_NATIVE_VERSION}-src.tar.gz -C /tmp \
    && cd /tmp/tomcat-native*-src/native/ \
    && ./configure \
        --with-apr=/usr/bin/apr-1-config \
        --with-java-home=/usr/java/jdk1.8.0_171-amd64 \
        --with-ssl=yes \
        --prefix=${CATALINA_HOME} \
        #--with-os-type=include/linux \
    && make \
    && make install

# Change to the working directory
WORKDIR ${CATALINA_HOME}

# Begin install of Tomcat
RUN set -x \
    #&& for key in $GPG_KEYS; do \
	#	gpg --keyserver pool.sks-keyservers.net --recv-keys "$key"; \
	#done \
    && curl -fSL ${TOMCAT_FULL_URL} -o tomcat.tar.gz \
    && echo "${TOMCAT_SHA512} *tomcat.tar.gz" | sha512sum -c - \
    #&& curl -fSL ${TOMCAT_FULL_URL}.asc -o tomcat.tar.gz.asc \
    #&& gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
    && rm -rf bin/*.bat \
    && rm -rf tomcat.tar.gz* 
    
# Add the setenv.sh for Apache Native stuffs
ADD ./configs/setenv.sh ${CATALINA_HOME}/bin/

# Comment/Uncomment these lines if you want to add your own configs such as
# server.xml , War files, etc... to the image. You can also choose to bind mount from host.
#ADD ./configs/server.xml ${CATALINA_HOME}/conf/
#ADD ./configs/tomcat-users.xml ${CATALINA_HOME}/conf/
#ADD ./wars/* ${CATALINA_HOME}/webapps/

# Create tomcat user
RUN groupadd -r tomcat  \
    && useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat \
    && chown -R tomcat:tomcat ${CATALINA_HOME}

# Expose the following ports. 8443 will provide SSL.
EXPOSE 8080
EXPOSE 8443
EXPOSE 8009

# Run as tomcat as tomcat!
USER tomcat 

# Run it
CMD ["catalina.sh", "run"]```

