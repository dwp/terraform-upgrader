FROM ubuntu:latest

RUN mkdir /home/app

WORKDIR /home/app

COPY . /home/app

RUN apt-get update && apt-get install vim git-core -y

RUN chmod +x *.sh
