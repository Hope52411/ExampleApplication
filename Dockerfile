# syntax=docker/dockerfile:1
FROM cimg/node:22.1.0
ENV NODE_ENV=production
COPY ["package.json","package-lock.json*","./"]
RUN npm install
COPY . .
CMD [ "npm","start" ]