ARG  PYTHON_VER=3.9
FROM amazon/aws-lambda-python:$PYTHON_VER

ARG POSTGRES_VER=12.6 \
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
ENV TAG_NAME=psycopg2-${PSYCOPG_VER}-py${PYTHON_VER}
ENV BUILD_PATH=${TAG_NAME}.zip
RUN cp -r /var/psycopg/psycopg2-${PSYCOPG_VER}/build/lib.linux-x86_64-${PYTHON_VER}/psycopg2 /var/output
WORKDIR /var/output

RUN zip -r ${BUILD_PATH} ./
RUN mkdir ./final
RUN cp ${BUILD_PATH} ./final
WORKDIR /var/output/final
RUN echo POSTGRES_VER="${POSTGRES_VER}" >> build.cfg && \ 
 echo PSYCOPG_VER="${PSYCOPG_VER}" >> build.cfg && \ 
 echo PSYCOPY_MAJ_VER="${PSYCOPY_MAJ_VER}" >> build.cfg && \ 
 echo PSYCOPG_VER_PATH="${PSYCOPG_VER_PATH}" >> build.cfg && \ 
 echo PYTHON_VER="${PYTHON_VER}" >> build.cfg && \
 echo PYTHON_VER="${PYTHON_VER}" >> build.cfg && \
 echo TAG_NAME="${TAG_NAME}" >> build.cfg && \
 echo BUILD_PATH="${BUILD_PATH}" >> build.cfg
RUN cat build.cfg
