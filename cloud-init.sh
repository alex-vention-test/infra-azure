#!/bin/bash
apt-get update
apt-get install -y docker.io git
systemctl enable docker
systemctl start docker

git clone https://github.com/docker/getting-started-app.git
cd getting-started-app

cat > Dockerfile << 'DOCKERFILE'
FROM node:lts-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
EXPOSE 3000
DOCKERFILE

docker build -t node-app .
docker run -d -p 3000:3000 node-app
