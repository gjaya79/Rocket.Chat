#FROM node:0.10
FROM quay.io/aptible/nodejs:v0.10.x

MAINTAINER jaya@infohawk.in

RUN groupadd -r chat \
&&  useradd -r -g chat chat

VOLUME /app/uploads

# gpg: key 4FD08014: public key "Rocket.Chat Buildmaster <buildmaster@rocket.chat>" imported
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 0E163286C20D07B9787EBE9FD7F9D0414FD08104

# Install Meteor
RUN apt-install curl procps
RUN curl https://install.meteor.com/ | sh

# Install `meteor build` dependencies
RUN apt-install python build-essential

ADD . /app
WORKDIR /app

RUN meteor build --server=http://162.243.56.103:3000 --directory .

WORKDIR /app/bundle/programs/server
RUN  npm install

USER chat

WORKDIR /app/bundle

# needs a mongoinstance - defaults to container linking with alias 'mongo'
ENV MONGO_URL=mongodb://mongo:27017/rocketchat \
    PORT=3000 \
    ROOT_URL=http://162.243.56.103:3000 \
    Accounts_AvatarStorePath=/app/uploads

EXPOSE 3000

CMD ["node", "main.js"]
