
FROM tomcat:9-jre9
COPY ./target/webapp.war /usr/local/tomcat/webapps/
