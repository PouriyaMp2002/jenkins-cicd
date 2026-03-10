# Jenkins CI/CD Pipeline – Dockerized Java Application

This repository demonstrates a **complete DevOps CI/CD workflow** using **Jenkins, Docker, Maven, SonarQube, Nexus, and AWS container services.**

This project demonstrates a CI/CD pipeline *triggered by developer commits* using a **Github webhook**. When a new commit is pushed, Jenkins automatically starts the pipeline and executes the **Continuous Integration (CI) stages**, which include building the application, running tests, and performing static code analysis.

If the CI stages complete successfully, the pipeline proceeds to the **Continuous Delivery (CD) stages**. In this phase, the application is containerized using Docker, the image is *pushed* to **AWS Elastic Container Registry (ECR)**, and the updated container is deployed to **AWS Elastic Container Service (ECS)**.

---

## Project Goal

The purpose of this project is to demonstrate how a modern DevOps pipeline can automatically:

- Build and test a Java application
- Perform static code analysis
- Enforce quality gates
- Publish build artifacts
- Build and push Docker images
- Deploy containers to a cloud environment

---

## CI/CD Pipeline Breakdown

```text
Developer Commit
        ↓
Jenkins Pipeline Trigger
        ↓
Build Application (Maven)
        ↓
Unit Tests
        ↓
Integration Tests
        ↓
SonarQube Code Analysis
        ↓
Publish Artifact to Nexus
        ↓
Build Docker Image
        ↓
Push Image to AWS ECR
        ↓
Deploy to AWS ECS
```

---

## Jenkins Pipeline

The CI/CD pipeline is defined using a **Jenkinsfile**, enabling **Pipeline as Code**.  
This allows the entire build and deployment process to be version-controlled within the repository.

The Jenkins pipeline automates the following stages:

### Build Stage
- Jenkins pulls the latest code from the repository
- Maven compiles the project and resolves dependencies

### Testing Stage
- Unit tests are executed
- Integration tests validate application functionality

### Code Analysis
- SonarQube performs static code analysis

### Artifact Publishing
- The generated build artifact (`.jar`) is uploaded to **Nexus Repository Manager**
- Nexus acts as a centralized artifact storage system

### Containerization
- Docker builds a container image using the provided Dockerfile
- The application artifact is packaged inside a **Tomcat runtime container**

### Image Registry
- The Docker image is pushed to **AWS Elastic Container Registry (ECR)**

### Deployment
- The new container image is deployed to **AWS Elastic Container Service (ECS)**
- ECS updates the running service with the new image version

---

## Dockerfile

The project uses **a multi-stage Docker build** to compile the application and package it into a runtime container.

### Stage 1 – Build Stage
Uses **Maven** as the build image.

Steps performed:
- Clone the repository from **GitHub**
- Navigate to the project directory
- Build the application using Maven

### Stage 2 – Runtime Stage
Uses **Tomcat** as the runtime container.

Steps performed:
- Remove the existing Tomcat web application
- Replace it with the compiled `.jar` file from the first stage
- Deploy the application as the **root web application**

### Container Configuration
- Expose application port **8080**
- Start the **Tomcat server**

---

## Project Outcome

The goal of this project is to showcase practical experience with:

- CI/CD pipeline automation
- Containerization with Docker
- Artifact management using Nexus
- Static code analysis using SonarQube
- Cloud container deployment using AWS ECS and ECR

using **industry-standard DevOps tools and practices**.
