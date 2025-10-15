FROM node:18-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install 

COPY app.js .

FROM gcr.io/distroless/nodejs18

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app /usr/src/app

USER nonroot

EXPOSE 5000
CMD ["app.js"]

