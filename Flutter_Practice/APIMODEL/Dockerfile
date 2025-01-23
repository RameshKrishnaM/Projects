# Use the official Ubuntu base image
FROM ubuntu:latest

# Set timezone to IST
ENV TZ=Asia/Kolkata

# Install necessary packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    tzdata \
    tree \
    ca-certificates && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Verify the timezone
RUN date

# Set the working directory inside the container
WORKDIR /app

# Create necessary directories with one command
RUN mkdir -p log 
RUN mkdir -p html

# Copy the Go binary to the container
COPY bin/main .

# Copy the html templates to the container
COPY /html ./html/

# Make the binary executable
RUN chmod +x main

# Expose the necessary port
EXPOSE 28595

# Create a non-root user and change ownership of the application
RUN useradd -m nonrootuser && chown -R nonrootuser:nonrootuser /app

# Switch to the non-root user
USER nonrootuser

# Specify the command to run the executable
CMD ["./main"]
