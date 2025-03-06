# syntax=docker/dockerfile:1
FROM node:22.1.0
ENV NODE_ENV=production
COPY ["package.json","package-lock.json*","./"]
RUN sudo npm install
COPY . .
CMD [ "npm","start" ]