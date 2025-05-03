# Use a Flutter image with the latest stable version
FROM ghcr.io/cirruslabs/flutter:3.13.0

# Set the working directory inside the container
WORKDIR /app

# Create a non-root user
RUN useradd -ms /bin/bash flutteruser

# Change ownership of the Flutter SDK directory
RUN chown -R flutteruser:flutteruser /sdks/flutter

# Change ownership of the working directory
RUN chown -R flutteruser:flutteruser /app

# Switch to the non-root user
USER flutteruser

# Copy the Flutter project files into the container
COPY . .

# Expose the port for the Flutter web server
EXPOSE 40000

# Install dependencies
RUN git config --global --add safe.directory /sdks/flutter && flutter pub get

# Command to run the Flutter development server
CMD ["flutter", "run", "-d", "web-server", "--web-port=40000", "--web-hostname=0.0.0.0"]