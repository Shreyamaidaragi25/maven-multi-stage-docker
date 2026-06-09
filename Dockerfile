# ==========================================
# Stage 1: The Build Stage
# ==========================================
# Use a full Maven image with JDK to compile the code
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml first to leverage Docker cache for dependencies
COPY pom.xml .

# Download dependencies. This layer will be cached unless pom.xml changes
RUN mvn dependency:go-offline -B

# Copy the actual source code
COPY src ./src

# Package the application (skipping tests for a faster build)
RUN mvn clean package -DskipTests

# ==========================================
# Stage 2: The Runtime Stage
# ==========================================
# Use a lightweight JRE (Java Runtime Environment) Alpine image
FROM eclipse-temurin:17-jre-alpine

# Set a non-root user for better security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

WORKDIR /app

# Copy ONLY the compiled JAR file from the 'builder' stage
# Adjust 'my-app-1.0.0.jar' to match your actual generated JAR name
COPY --from=builder /app/target/*.jar app.jar

# Expose the port your application listens on (e.g., 8080)
EXPOSE 8080

# Execute the application
ENTRYPOINT ["java", "-jar", "app.jar"]