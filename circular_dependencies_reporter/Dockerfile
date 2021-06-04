FROM python:3.8-alpine

RUN sed -i 's/https/http/g' /etc/apk/repositories

RUN mkdir -p /home/app/reports

WORKDIR /home/circular_dependencies_reporter

COPY . /home/circular_dependencies_reporter

RUN apk add --update git

RUN pip install --index-url=https://pypi.python.org/simple/ --trusted-host=pypi.python.org --trusted-host=files.pythonhosted.org --trusted-host pypi.org -r requirements.txt

ARG ENTERPRISE_URL
ARG OPENSOURCE_REPO_LIST
ARG ENTERPRISE_REPO_LIST
ARG GITHUB_ENTERPRISE_PAT
ARG USERNAME
ARG GITHUB_ORG
ARG ENTERPRISE_ORG
ARG GIT_SSL_NO_VERIFY

ENV ENTERPRISE_URL=$ENTERPRISE_URL OPENSOURCE_REPO_LIST=$OPENSOURCE_REPO_LIST ENTERPRISE_REPO_LIST=$ENTERPRISE_REPO_LIST GITHUB_ENTERPRISE_PAT=$GITHUB_ENTERPRISE_PAT USERNAME=$USERNAME GITHUB_ORG=$GITHUB_ORG ENTERPRISE_ORG=$ENTERPRISE_ORG GIT_SSL_NO_VERIFY=$GIT_SSL_NO_VERIFY

CMD ["python3", "app.py"]
