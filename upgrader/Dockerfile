FROM alpine:latest

ARG TF_FINAL_VERSION
ARG TF_INT_VERSION
ARG GH_EMAIL
ARG GH_USERNAME
ENV GIT_SSL_NO_VERIFY=True

RUN sed -i 's/https/http/g' /etc/apk/repositories

RUN mkdir -p /home/app/

WORKDIR /home/app

COPY . ./

RUN apk add --update bash git curl perl \
    && git config --global user.email $GH_EMAIL && git config --global user.name $GH_USERNAME \
    && git clone https://github.com/tfutils/tfenv.git ~/.tfenv \
    && ln -s ~/.tfenv/bin/* /usr/local/bin \
    && chmod +x ./*.sh \
    && tfenv install $TF_FINAL_VERSION \
    && if [ -n $TF_INT_VERSION ]; then tfenv install $TF_INT_VERSION; fi
