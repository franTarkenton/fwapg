FROM osgeo/gdal:ubuntu-small-3.4.0

RUN apt-get update && apt-get --assume-yes upgrade \
&& apt-get -qq install -y --no-install-recommends make \
&& apt-get -qq install -y --no-install-recommends wget \
&& apt-get -qq install -y --no-install-recommends zip \
&& apt-get -qq install -y --no-install-recommends unzip \
&& apt-get -qq install -y --no-install-recommends parallel

RUN apt-get -qq install -y --no-install-recommends postgresql-common \
&& apt-get -qq install -y --no-install-recommends yes \
&& apt-get -qq install -y --no-install-recommends gnupg \
&& yes '' | sh /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh \
&& apt-get -qq install -y --no-install-recommends postgresql-client-14

WORKDIR /home/fwapg
COPY ["sql", "sql/"]
COPY ["extras", "extras/"]
COPY [".env.docker", "Makefile", "./"]
