# syntax=docker/dockerfile:1
FROM cimg/node:22.1.0
ENV NODE_ENV=production
COPY ["package.json","package-lock.json*","./"]
USER root
RUN chown -R circleci:circleci /home/circleci/project
USER circleci
RUN npm install --unsafe-perm
COPY . .
CMD [ "npm","start" ]