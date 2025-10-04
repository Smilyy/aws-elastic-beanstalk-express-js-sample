# ----------------------------
# Dockerfile for Node.js App (for Assignment2)
# ----------------------------
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /usr/src/app

# Copy dependency definitions
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Expose port 8080 
EXPOSE 8080

# Define default command
CMD ["npm", "start"]
