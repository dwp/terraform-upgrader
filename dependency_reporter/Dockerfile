FROM python:3.8-alpine

RUN mkdir -p /home/app

WORKDIR /home/app

COPY . /home/app

RUN apk update && apk add bash vim git

RUN chmod +x ./scripts/*.sh && pip install pipenv

ARG ENTERPRISE_URL
ARG OPENSOURCE_REPO_LIST
ARG ENTERPRISE_REPO_LIST
ENV enterprise_url=$ENTERPRISE_URL opensource_repo_list=$OPENSOURCE_REPO_LIST enterprise_repo_list=$ENTERPRISE_REPO_LIST

CMD ["./scripts/wrapper.sh"]
