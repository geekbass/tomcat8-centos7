# Tomcat 8 / Oracle JRE / JCE Policy / Centos 7 
An afternoon of hacking tomcat 8 into a centos 7 base image with Oracle JRE and JCE Unlimited Strength Jurisdiction Policy for 256 bit encryption. Much of the image build comes from the offical tomcat docker image. This image must include the following to be considered complete:

- Centos 7 Base (Not first choice but a req)
- Oracle Java 
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

### For troubleshooting and/or more info:
[ The Official Docker Image ](https://github.com/docker-library/tomcat) for Tomcat is also available.

# To Do:
- GPG checks 
- sha check JCE 
- SSL 
- Custom Configs (server.xml, users, etc...)
- Instructions for Dropping wars during build
- Shrink the Image!!!!
- ? 