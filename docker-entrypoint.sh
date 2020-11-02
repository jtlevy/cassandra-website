#!/bin/bash

# Abort script if a command fails
set -e


# Setup git and ssh
git config --global user.email "${GIT_EMAIL_ADDRESS}"
git config --global user.name "${GIT_USER_NAME}"

#echo
#echo "Running in '${BUILD_MODE}' mode!"
#echo

export CASSANDRA_USE_JDK11=true
CASSANDRA_SITE_DIR="${BUILD_DIR}/cassandra-site"
CASSANDRA_DIR="${BUILD_DIR}/cassandra"
CASSANDRA_DOC="${CASSANDRA_DIR}/doc"


for version in ${CASSANDRA_VERSIONS}
do
  echo "Checking out branch '${version}'"
  pushd "${CASSANDRA_DIR}"
  git clean -xdff
  git checkout "${version}"
  git pull --rebase --prune

  echo "Building JAR files"
  # Nodetool docs are autogenerated, but that needs nodetool to be built
  ant jar
  doc_version=$(ant echo-base-version | grep "\[echo\]" | tr -s ' ' | cut -d' ' -f3)
  popd

  pushd "${CASSANDRA_DOC}"
  # cassandra-3.11 is missing gen-nodetool-docs.py, ref: CASSANDRA-16093
  if [ ! -f ./gen-nodetool-docs.py ]
  then
    wget \
      -nc \
      -O ./gen-nodetool-docs.py \
      https://raw.githubusercontent.com/apache/cassandra/a47be7eddd5855fc7723d4080ca1a63c611efdab/doc/gen-nodetool-docs.py
  fi

  echo "Generating asciidoc for version ${doc_version}"
  # generate the nodetool docs
  python3 scripts/gen-nodetool-docs.py

  # generate cassandra.yaml docs
  YAML_INPUT="${CASSANDRA_DIR}/conf/cassandra.yaml"
  YAML_OUTPUT="${CASSANDRA_DOC}/source/modules/cassandra/pages/configuration/cass_yaml_file.adoc"
  python3 scripts/convert_yaml_to_adoc.py "${YAML_INPUT}" "${YAML_OUTPUT}"

  git add .
  git commit -m "Generated nodetool and configuration documentation for ${doc_version}."
  popd
done

cd "${CASSANDRA_SITE_DIR}/site-content"
echo "Building site.yml"

python3 ./bin/site_yml_generator.py \
  -c "{\"url\":\"${CASSANDRA_REPOSITORY_URL}\",\"branches\":[$(echo \""${CASSANDRA_VERSIONS}"\" | sed 's~\ ~\",\"~g')],\"start_path\":\"${CASSANDRA_START_PATH}\"}" \
  -c "{\"url\":\"${CASSANDRA_WEBSITE_REPOSITORY_URL}\",\"branches\":[$(echo \""${CASSANDRA_WEBSITE_VERSIONS}"\" | sed 's~\ ~\",\"~g')],\"start_path\":\"${CASSANDRA_WEBSITE_START_PATH}\"}" \
  site.template.yml

echo "Building the site HTML content."
export DOCSEARCH_ENABLED=true
export DOCSEARCH_ENGINE=lunr
export NODE_PATH="$(npm -g root)"
export DOCSEARCH_INDEX_VERSION=latest
antora --generator antora-site-generator-lunr site.yml


## *************************
## CHANGE THIS TO trunk AFTER TESTING!!!!
## *************************
## Antora is run only from one branch (trunk)
#git checkout doc_redo_asciidoc
#cd doc
#
## run antora
#echo "Building the docs site with antora."
#export DOCSEARCH_ENABLED=true
#export DOCSEARCH_ENGINE=lunr
#export NODE_PATH="$(npm -g root)"
#export DOCSEARCH_INDEX_VERSION=latest
#antora --generator antora-site-generator-lunr site.yml
#
#if [ "${BUILD_MODE}" = "preview" ]
#then
#  echo "Starting webserver."
#  python3 -m http.server "${WEB_SERVER_PORT}"
#fi
