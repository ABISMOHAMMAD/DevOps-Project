FROM node:18-alpine

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install 

COPY . .

# Run as non-root for security
RUN addgroup app && adduser -S -G app app
USER app

EXPOSE 5000
CMD ["npm", "start"]

