FROM docker.elastic.co/elasticsearch/elasticsearch-alpine-base:latest
MAINTAINER floragunn GmbH <info@floragunn.com>

ARG ELASTIC_VERSION
ARG ES_JAVA_OPTS
ARG SG_VERSION

ENV PATH /usr/share/sgadmin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

WORKDIR /usr/share/sgadmin

RUN wget https://search.maven.org/remotecontent?filepath=com/floragunn/search-guard-5/${ELASTIC_VERSION}-${SG_VERSION}/search-guard-5-${ELASTIC_VERSION}-${SG_VERSION}-sgadmin-standalone.tar.gz && \
    tar zxvf search-guard-5-${ELASTIC_VERSION}-${SG_VERSION}-sgadmin-standalone.tar.gz

RUN chmod +x /usr/share/sgadmin/tools/sgadmin.sh

ENTRYPOINT ["/usr/share/sgadmin/tools/sgadmin.sh"]
