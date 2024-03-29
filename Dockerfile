ARG ARCH=
FROM ${ARCH}alpine:3.14

RUN cd ~; \
	echo "" > /etc/apk/repositories; \
	echo "https://mirror.yandex.ru/mirrors/alpine/v3.14/main" >> /etc/apk/repositories; \
	echo "https://mirror.yandex.ru/mirrors/alpine/v3.14/community" >> /etc/apk/repositories; \
	apk update; \
	apk add bash nano mc wget net-tools pv zip unzip supervisor procps grep sudo util-linux tzdata; \
	rm -rf /var/cache/apk/*; \
	echo "export EDITOR=nano" > /etc/profile.d/editor_nano; \
	echo "Ok"

ADD files /
RUN cd ~; \
	mkdir -p /data; \
	chmod +x /root/run.sh; \
	echo "Ok"

CMD ["/root/run.sh"]