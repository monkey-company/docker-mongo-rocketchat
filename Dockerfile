FROM ubuntu
MAINTAINER naou <monaou@gmail.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
     echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
     apt-get update && \
     apt-get -y install curl ca-certificates mongodb-org supervisor --no-install-recommends && \
     curl -sL https://deb.nodesource.com/setup_4.x | bash - && \
     apt-get -y install nodejs --no-install-recommends && \
     apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN curl -SLf "https://rocket.chat/releases/latest/download" -o /tmp/rocket.chat.tgz && \
     mkdir /app && tar -zxf /tmp/rocket.chat.tgz -C /app && \
     rm /tmp/rocket.chat.tgz
RUN cd /app/bundle/programs/server && \
     npm install && \
     npm cache clear

ADD supervisor.conf /etc/supervisor.conf
ADD startup.sh /app/startup.sh
RUN mkdir -p /data/db /app/uploads

ENV MONGO_URL=mongodb://localhost:27017/rocketchat \
    HOME=/tmp \
    PORT=3000 \
    ROOT_URL=http://localhost:3000 \
    Accounts_AvatarStorePath=/app/uploads

RUN groupadd -r rocketchat && \
     useradd -r -g rocketchat rocketchat

EXPOSE 3000
VOLUME /data/db
VOLUME /app/uploads

CMD /usr/bin/supervisord -c /etc/supervisor.conf
