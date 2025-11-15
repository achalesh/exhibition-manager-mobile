# backend/Dockerfile — rebuild native modules for Alpine
FROM node:20-alpine

# install build tools to compile native addons (small, removed after build)
RUN apk add --no-cache --virtual .build-deps \
      build-base python3 git

WORKDIR /usr/src/app

# copy package files first so layer caches deps
COPY package*.json ./

# install production deps and build native modules
# --build-from-source ensures bcrypt/native addons are built for this image
RUN npm install --no-audit --no-fund --production --build-from-source

# copy app code
COPY . .

# remove build deps to keep image small
RUN apk del .build-deps || true

EXPOSE 4000

CMD ["npm", "start"]
