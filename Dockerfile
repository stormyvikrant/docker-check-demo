# # Use the official Node.js image as a base image
# FROM node:20 as build

# # Set the working directory
# WORKDIR /app

# # Copy package.json and package-lock.json
# COPY package*.json ./

# # Install dependencies
# RUN npm install

# # Copy the rest of the application files
# COPY . .

# # Build the Angular application
# RUN npm run build --prod

# # Stage 2: Serve the application
# FROM nginx:alpine

# # Copy the built files from the previous stage
# COPY --from=build /app/dist/project2 /usr/share/nginx/html

# # Expose port 80
# EXPOSE 80

# # Start Nginx server
# CMD ["nginx", "-g", "daemon off;"]



# Stage 1: Build the Angular application
FROM node:20 as build

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Argument to specify which version to increment: MAJOR, MINOR, or PATCH
ARG VERSION_TYPE=patch

# Increment the version based on the VERSION_TYPE argument
RUN if [ "$VERSION_TYPE" = "major" ]; then \
    npm version major --no-git-tag-version; \
    elif [ "$VERSION_TYPE" = "minor" ]; then \
    npm version minor --no-git-tag-version; \
    else \
    npm version patch --no-git-tag-version; \
    fi

# Extract the new version from package.json
ARG NEW_VERSION
RUN NEW_VERSION=$(node -p "require('./package.json').version") && echo "Building version $NEW_VERSION"

# Copy the rest of the application files
COPY . .

# Build the Angular application
RUN npm run build --prod

# Stage 2: Serve the application
FROM nginx:alpine

# Copy the built files from the previous stage
COPY --from=build /app/dist/project2 /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
