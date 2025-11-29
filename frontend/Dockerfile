FROM node:14-alpine

WORKDIR /app
COPY package*.json ./

# Simplify the npm install command
RUN npm install --no-audit

COPY . .
EXPOSE 8080
CMD ["npm", "start"]