# Dockerfile - Production-ready for Spring Boot with pre-built JAR
# Assumes JAR is already built by Jenkins and contains frontend assets

FROM openjdk:17-jdk-slim

# Create a non-root user for security
RUN groupadd -r spring -g 1000 && \
    useradd -r -g spring -u 1000 -m -s /bin/bash spring

# Set working directory
WORKDIR /app

# Copy the pre-built JAR from Jenkins workspace
# The JAR already contains frontend assets from npm build
COPY target/*.jar app.jar

# Set ownership to non-root user
RUN chown -R spring:spring /app

# Switch to non-root user
USER spring:spring

# Expose application port
EXPOSE 8080

# Health check (adjust endpoint as needed)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]