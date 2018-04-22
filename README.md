# Tomcat 8 / Oracle JRE / JCE Policy / Centos 7 
An afternoon of hacking tomcat 8 into a centos 7 base image with Oracle JRE and JCE Unlimited Strength Jurisdiction Policy for 256 bit encryption. Much of the image build comes from the offical tomcat docker image. This image must include the following to be considered complete:

- Centos 7 Base 
- Oracle Java 
- Tomcat 8 or higher (currenty familiar with 8)
- JCE Unlimited Strength Jurisdiction Policy 
- SSL Termination for app 
- Custom server.xml and users.xml
- War Deploy
- Persistent Storage? 

This image should ultimately be flexible. Provide the abilty run as vanilla or with custom configs. Initially will be run as a standalone on a single host. End result should support and be capable of running on Marathon and K8s orchestrators.

# How to use:


# To Do:
- GPG checks 
- sha check JCE 
- SSL 
- Custom Configs (server.xml, users, etc...)
- Instructions for Dropping wars
- ? 