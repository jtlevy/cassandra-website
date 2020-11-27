FROM ubuntu:18.04
# Set up non-root user, 'build', with default uid:gid
# This allows passing --build-arg to use local host user's uid:gid:
#   $ docker build \
#       -t cassandra-website:latest \
#       --build-arg UID_ARG=$(id -u) \
#       --build-arg GID_ARG=$(id -g) \
#       .
#
# Other container parameters can be overridden at build time as well:
#  - BUILD_USER_ARG:                Name of the user to run as when building the docs and site.
#  - NODE_VERSION_ARG:              Version of node to use.
#  - CASSANDRA_REPOSITORY_URL_ARG:  Git URL to use for the Cassandra repository.
ARG UID_ARG=1000
ARG GID_ARG=1000
ARG BUILD_USER_ARG=build
ARG NODE_VERSION_ARG="v12.16.2"
ARG CASSANDRA_REPOSITORY_URL_ARG="https://gitbox.apache.org/repos/asf/cassandra.git"

RUN echo "Building with arguments" \
    && echo "UID_ARG=${UID_ARG}" \
    && echo "GID_ARG=${GID_ARG}" \
    && echo "BUILD_USER_ARG=${BUILD_USER_ARG}" \
    && echo "NODE_VERSION_ARG=${NODE_VERSION_ARG}" \
    && echo "CASSANDRA_REPOSITORY_URL_ARG=${CASSANDRA_REPOSITORY_URL_ARG}"

RUN echo "Setting up user 'build'"
RUN groupadd --gid ${GID_ARG} --non-unique ${BUILD_USER_ARG}
RUN useradd --create-home --shell /bin/bash \
    --uid ${UID_ARG} --gid ${GID_ARG} --non-unique ${BUILD_USER_ARG}

# INSTALL wget, python3, java11, and other tools required to build the docs
RUN apt-get update && \
    apt-get install -y \
        wget \
        gpg \
        python3 \
        python3-pip \
        openjdk-11-jdk \
        git \
        make \
        ant \
        ant-optional \
        vim

RUN pip3 install jinja2 requests

# INSTALL nodejs and nvm
ENV NODE_PACKAGE="node-${NODE_VERSION_ARG}-linux-x64.tar.gz"
RUN wget https://nodejs.org/download/release/${NODE_VERSION_ARG}/${NODE_PACKAGE} && \
    tar -C /usr/local --strip-components 1 -xzf ${NODE_PACKAGE} && \
    rm ${NODE_PACKAGE}

# Use npm to install Antora globally, and antora-lunr for site search, and js-yaml to load YAML files
RUN npm i -g @antora/cli@2.3 @antora/site-generator-default@2.3
RUN npm i -g antora-lunr antora-site-generator-lunr

ENV BUILD_DIR="/home/${BUILD_USER_ARG}"

# Setup directories for building the docs
#  Give the build user rw access to everything in the build directory,
#   neccessary for the ASF 'website'.
RUN mkdir -p ${BUILD_DIR}/cassandra-website && \
    git clone ${CASSANDRA_REPOSITORY_URL_ARG} ${BUILD_DIR}/cassandra && \
    mkdir -p ${BUILD_DIR}/cassandra/doc/build_gen && \
    chmod -R a+rw ${BUILD_DIR} && \
    chown -R ${BUILD_USER_ARG}:${BUILD_USER_ARG} ${BUILD_DIR}

#ENV BUILD_MODE "preview"
#ENV GPG_KEY_PATH ""
#ENV GENERATE_NODETOOL_AND_CONFIG_DOCS "true"

# Set defaults for site build environment variables.
ENV GIT_EMAIL_ADDRESS "${BUILD_USER_ARG}@apache.org"
ENV GIT_USER_NAME "${BUILD_USER_ARG}"

ENV SITE_TITLE "Apache Cassandra Documentation"
ENV SITE_URL "https://cassandra.apache.org/"
ENV SITE_START_PAGE "Website"

# Build from 3.11.5 as document generation for previous versions is broken.
ENV CASSANDRA_REPOSITORY_URL "${CASSANDRA_REPOSITORY_URL_ARG}"
ENV CASSANDRA_VERSIONS "trunk cassandra-4.0 cassandra-3.11.8 cassandra-3.11.7 cassandra-3.11.6 cassandra-3.11.5"
ENV CASSANDRA_START_PATH "doc/source"
ENV CASSANDRA_WEBSITE_REPOSITORY_URL "https://gitbox.apache.org/repos/asf/cassandra-website.git"
ENV CASSANDRA_WEBSITE_VERSIONS "trunk"
ENV CASSANDRA_WEBSITE_START_PATH "site-content/source"

ENV UI_BUNDLE_ZIP_URL "https://github.com/ianjevans/antora-ui-datastax/releases/download/v0.1oss/ui-bundle.zip"
ENV CASSANDRA_DOWNLOADS_URL "https://downloads.apache.org/cassandra/"

ENV GENERATE_CASSANDRA_VERSIONED_DOCS "enabled"
ENV RENDER_SITE_HTML_CONTENT "enabled"

EXPOSE 5151/tcp

# Run as build user from here
USER ${BUILD_USER_ARG}
WORKDIR ${BUILD_DIR}
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [""]
