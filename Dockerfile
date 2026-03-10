# Stage 1: Build the application using Maven
FROM maven:3.9.9-eclipse-temurin-21-jammy AS build_image

# Clone the application source code
RUN git clone https://github.com/pouriyamp2002/jenkins-cicd.git

# Build the project using Maven
RUN cd jenkins-cicd && mvn install

# Stage 2: Use Tomcat to run the application
FROM tomcat:10-jdk21

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built artifact from the build stage into Tomcat
COPY --from=build_image jenkins-cicd/target/devops-demo-1.0.jar /usr/local/tomcat/webapps/ROOT.war

# Configuration
EXPOSE 8080
CMD ["catalina.sh", "run"]
