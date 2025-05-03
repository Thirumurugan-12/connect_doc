# Use a Flutter image with the latest stable version
FROM ghcr.io/cirruslabs/flutter:3.29.3

# Set the working directory inside the container
WORKDIR /app

# Copy the Flutter project files into the container
COPY . .

# Expose the port for the Flutter web server
EXPOSE 40000

# Install dependencies
RUN flutter pub get

# Command to run the Flutter development server
CMD ["flutter", "run", "-d", "web-server", "--web-port=40000", "--web-hostname=0.0.0.0"]