FROM  amazon/aws-lambda-python:3.9

ENV POSTGRES_VER=12.6 \
 PSYCOPG_VER=2.9.1 \
 PSYCOPY_MAJ_VER=2.9 \
 PSYCOPG_VER_PATH=PSYCOPG-2-9 \
 PYTHON_VER=3.9

RUN yum install -y wget tar postgresql-devel gzip 
RUN yum groupinstall -y "Development Tools"

RUN mkdir -p /var/output

WORKDIR /var/psycopg

RUN wget -nv https://ftp.postgresql.org/pub/source/v${POSTGRES_VER}/postgresql-${POSTGRES_VER}.tar.gz
RUN tar -zxf postgresql-${POSTGRES_VER}.tar.gz
RUN wget -nv http://initd.org/psycopg/tarballs/${PSYCOPG_VER_PATH}/psycopg2-${PSYCOPG_VER}.tar.gz
RUN tar -zxf psycopg2-${PSYCOPG_VER}.tar.gz

# build without ssl
RUN cd postgresql-${POSTGRES_VER} && \
./configure --prefix /var/psycopg/postgresql-${POSTGRES_VER} --without-readline --without-zlib && \
make && \
make install

WORKDIR /var/psycopg/psycopg2-${PSYCOPG_VER}
RUN sed -ie "s/pg_config =/pg_config = \/var\/psycopg\/postgresql-$POSTGRES_VER\/bin\/pg_config/g" setup.cfg
RUN sed -i 's/static_libpq = 0/static_libpq = 1/g' setup.cfg
RUN python setup.py build

# copy compiled library to output to deliever to host
RUN cp -r /var/psycopg/psycopg2-${PSYCOPG_VER}/build/lib.linux-x86_64-${PYTHON_VER}/psycopg2 /var/output