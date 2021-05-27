FROM python:3.8-alpine

RUN sed -i 's/https/http/g' /etc/apk/repositories

RUN mkdir -p /home/app/reports

WORKDIR /home/app

COPY . /home/app

RUN apk add --update bash git

RUN chmod +x ./scripts/*.sh && pip install --index-url=https://pypi.python.org/simple/ --trusted-host=pypi.python.org --trusted-host=files.pythonhosted.org --trusted-host pypi.org -r requirements.txt

ARG ENTERPRISE_URL
ARG OPENSOURCE_REPO_LIST
ARG ENTERPRISE_REPO_LIST
ARG NEO4J_HOST
ARG NEO4J_USER
ARG NEO4J_PASSWORD
ARG GITHUB_ENTERPRISE_PAT
ARG USERNAME
ENV ENTERPRISE_URL=$ENTERPRISE_URL OPENSOURCE_REPO_LIST=$OPENSOURCE_REPO_LIST ENTERPRISE_REPO_LIST=$ENTERPRISE_REPO_LIST NEO4J_HOST=$NEO4J_HOST NEO4J_USER=$NEO4J_USER NEO4J_PASSWORD=$NEO4J_PASSWORD GITHUB_ENTERPRISE_PAT=$GITHUB_ENTERPRISE_PAT USERNAME=$USERNAME

CMD ["./scripts/wrapper.sh"]
