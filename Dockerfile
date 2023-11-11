# 构建阶段
FROM arm32v7/golang:latest AS buildState
LABEL maintainer="baiyz0825<byz0825@outlook.com>"
ENV GO111MODULE=on \
    CGO_ENABLED=1 \
    GOARCH=arm \
    GOARM=7 \
    GOOS=linux \
    GOPROXY="https://goproxy.cn,direct"
WORKDIR /apps
COPY . /apps
RUN cd /apps && go build -o bot

# 打包阶段
FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /apps
COPY --from=buildState /apps/bot /apps/
COPY --from=buildState /apps/config/config.yaml.example /apps/config/
COPY --from=buildState /apps/assert /apps/assert/
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN apt-get update
RUN apt-get install -y wkhtmltopdf
RUN apt-get install -y ca-certificates
RUN cp /apps/assert/simsun.ttc /usr/share/fonts
RUN mkdir /apps/db
RUN echo 'Asia/Shanghai' >/etc/timezone
ENV LANG C.UTF-8
EXPOSE 50008 40000
ENTRYPOINT ["/apps/bot"]
