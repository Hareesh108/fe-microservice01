# Stage 1: Build Stage
# Use a specific version of the official Node.js image as the build stage
FROM node:21.5-bullseye AS build

# Set the working directory inside the container
WORKDIR /app/build

# Copy package.json and package-lock.json to install dependencies efficiently and leverage layer caching
COPY package*.json ./

# Set up npm cache in a designated directory to improve caching
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm install --legacy-peer-deps

# Copy the entire application source code
COPY . .

# Run the build command to generate production-ready artifacts
RUN npm run build

# Stage 2: Deployable Image
# Use a specific version of the official Nginx image as the base image for the deployable image
FROM nginxinc/nginx-unprivileged:1.24-bullseye-perl

# Expose the port that the Nginx server will listen on
EXPOSE 8081

# Copy the built artifacts from the build stage to the Nginx HTML directory
COPY --from=build /app/build /usr/share/nginx/html

# Use a custom Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
