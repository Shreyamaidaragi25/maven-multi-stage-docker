# Multi-Stage Maven Docker Project

This repository serves as a production-ready reference guide for optimizing Java/Maven applications using Docker Multi-Stage builds. By separating the build environment from the runtime environment, the final production image size is drastically reduced by roughly 80%.

---

## 🏗️ Architecture Overview

A traditional single-stage Docker build keeps all Maven dependencies, source code, and JDK compilation tools inside the final image, resulting in an unoptimized footprint (~800MB+). 

This project implements a **Multi-Stage Build**:
1. **Stage 1 (Builder):** Uses `maven:3.9.6-eclipse-temurin-17-alpine` to download dependencies and compile the source code into a runnable `.jar` file.
2. **Stage 2 (Runtime):** Uses a bare-minimum `eclipse-temurin:17-jre-alpine` environment. It copies **only** the compiled `.jar` artifact from Stage 1, leaving all compilation bloat behind.

**Final Image Size Comparison:**  
* Standard Single-Stage Build: ~800 MB
* Optimized Multi-Stage Build: **~130 MB – 400 MB**

---

## 🛠️ Step-by-Step Execution Guide

Always execute these commands from the project root directory where the `Dockerfile` and `pom.xml` reside.

### 1. Build the Docker Image
Compile the application and build the slim production image:
```bash
docker build -t maven-multi-stage:latest
```

### 2. Verify the Image Size
Check the local Docker registry to verify the success of the multi-stage optimization:
  docker images maven-multi-stage

### 3. Run the Container
Run the container in detached background mode (-d), mapping container port 8080 to host port 8081 (to avoid standard 8080 local conflicts):
docker run -d -p 8081:8080 --name running-maven-app maven-multi-stage:latest

### 4. Inspect Application Logs
Verify that the Java application executed successfully inside the container:
docker logs running-maven-app

### 5. Container Maintenance & Cleanup
To stop and remove the container instance to free up resources:
docker stop running-maven-app
docker rm running-maven-app
