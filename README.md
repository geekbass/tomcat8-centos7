# Tomcat 8 / Apache Native / Oracle JDK / JCE Policy / Centos 7 
An afternoon of hacking tomcat 8 into a centos 7 base image with Oracle JDK and JCE Unlimited Strength Jurisdiction Policy for 256 bit encryption. Much of the image build comes from the offical tomcat docker image. This image must include the following to be considered complete:

- Centos 7 Base (Not first choice but a req)
- Oracle Java JDK (for APR)
- Tomcat 8 or higher (currently familiar with 8)
- JCE Unlimited Strength Jurisdiction Policy 
- SSL Termination for app 
- Custom server.xml and users.xml
- War Deploy
- Persistent Storage? 

This image should ultimately be flexible. Provide the abilty run as vanilla or with custom configs. Initially will be run as a standalone on a single host. End result should support and be capable of running on Marathon and K8s orchestrators.

# How to use:
### Building the Image
```sh
git clone https://github.com/geekbass/tomcat8-centos7.git
docker build -t tom8 .
```

### Running 
Daemon Mode
```sh
docker run -d --name my-tom8 -p 8080:8080 tom8
```

Interactive Mode
```sh
docker run -it --name my-tom8 -p 8080:8080 tom8
```

You can also volume and port args to mount custom configs, wars, and ssl 8443. Examples:
```sh
-v ./host-path/webapps:/opt/tomcat/webapps # Mount you webapps 
-v ./host-path/logs:/opt/tomcat/logs # Mount the logs to host
```

### SSL Using APR
Be sure to add the SSL connector to the server.xml 
[ Tomcat 8 SSL Settings ](https://tomcat.apache.org/tomcat-8.5-doc/ssl-howto.html)

```sh
<Connector
           protocol="org.apache.coyote.http11.Http11AprProtocol"
           port="8443" maxThreads="200"
           scheme="https" secure="true" SSLEnabled="true"
           SSLCertificateFile="/opt/tomcat/ssl/server.crt"
           SSLCertificateKeyFile="/opt/tomcat/ssl/server.pem"
           SSLVerifyClient="optional" SSLProtocol="TLSv1+TLSv1.1+TLSv1.2"/>
```

Mount the cert and the key from the host with port 8443 as well as the server.xml if it wasnt baked into image.
```sh 
docker run -d --name my-tom8 -p 8080:8080 -p 8443:8443 -v /host-path/ssl/server.crt:/opt/tomcat/ssl/server.crt -v /host-path/ssl/server.pem:/opt/tomcat/ssl/server.pem -v /host-path/server.xml:/opt/tomcat/conf/server.xml tom8
```

### For troubleshooting and/or more info:
[ The Official Docker Image ](https://github.com/docker-library/tomcat) for Tomcat is also available.

# To Do:
- GPG checks 
- sha check JCE 
- Shrink the Image!!!!
- ? 