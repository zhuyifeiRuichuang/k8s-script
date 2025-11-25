#!/bin/bash

set -eux
HIVE_VERSION=
HADOOP_VERSION=
TEZ_VERSION=
usage() {
    cat <<EOF 1>&2
Usage: $0 [-h] [-hadoop <Hadoop version>] [-tez <Tez version>] [-hive <Hive version>] [-repo <Docker repo>]
Build the Hive Docker image (uses local tar.gz files only, no network download)
-help                Display help
-hadoop              Build image with the specified Hadoop version (required local tar.gz)
-tez                 Build image with the specified Tez version (required local tar.gz)
-hive                Build image with the specified Hive version (required local tar.gz)
-repo                Docker repository
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h)
       usage
       exit 0
       ;;
    -hadoop)
      shift
      HADOOP_VERSION=$1
      shift
      ;;
    -tez)
      shift
      TEZ_VERSION=$1
      shift
      ;;
    -hive)
      shift
      HIVE_VERSION=$1
      shift
      ;;
    -repo)
      shift
      REPO=$1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

SCRIPT_DIR=$(cd $(dirname $0); pwd)
SOURCE_DIR=${SOURCE_DIR:-"$SCRIPT_DIR/../../.."}
repo=${REPO:-apache}
WORK_DIR="$(mktemp -d)"

HADOOP_VERSION=${HADOOP_VERSION:-$(mvn -f "$SOURCE_DIR/pom.xml" -q help:evaluate -Dexpression=hadoop.version -DforceStdout)}
TEZ_VERSION=${TEZ_VERSION:-$(mvn -f "$SOURCE_DIR/pom.xml" -q help:evaluate -Dexpression=tez.version -DforceStdout)}

HADOOP_FILE_NAME="hadoop-$HADOOP_VERSION.tar.gz"
if [ ! -f "./$HADOOP_FILE_NAME" ]; then
  echo "ERROR: Hadoop file not found in current directory!"
  echo "Required file: $HADOOP_FILE_NAME"
  echo "Please place the correct Hadoop tar.gz in the current directory and try again."
  exit 1
fi
cp "./$HADOOP_FILE_NAME" "$WORK_DIR/"

TEZ_FILE_NAME="apache-tez-$TEZ_VERSION-bin.tar.gz"
if [ ! -f "./$TEZ_FILE_NAME" ]; then
  echo "ERROR: Tez file not found in current directory!"
  echo "Required file: $TEZ_FILE_NAME"
  echo "Please place the correct Tez tar.gz in the current directory and try again."
  exit 1
fi
cp "./$TEZ_FILE_NAME" "$WORK_DIR/"

if [ -n "$HIVE_VERSION" ]; then
  HIVE_FILE_NAME="apache-hive-$HIVE_VERSION-bin.tar.gz"
else
  HIVE_VERSION=$(mvn -f "$SOURCE_DIR/pom.xml" -q help:evaluate -Dexpression=project.version -DforceStdout)
  HIVE_FILE_NAME="apache-hive-$HIVE_VERSION-bin.tar.gz"
fi

if [ ! -f "./$HIVE_FILE_NAME" ]; then
  echo "ERROR: Hive file not found in current directory!"
  echo "Required file: $HIVE_FILE_NAME"
  echo "Hive version: $HIVE_VERSION"
  echo "Please place the correct Hive tar.gz in the current directory and try again."
  exit 1
fi
cp "./$HIVE_FILE_NAME" "$WORK_DIR/"

cp -R "$SOURCE_DIR/packaging/src/docker/conf" "$WORK_DIR/"
cp -R "$SOURCE_DIR/packaging/src/docker/entrypoint.sh" "$WORK_DIR/"
cp    "$SOURCE_DIR/packaging/src/docker/Dockerfile" "$WORK_DIR/"

docker build \
        "$WORK_DIR" \
        -f "$WORK_DIR/Dockerfile" \
        -t "$repo/hive:$HIVE_VERSION" \
        --build-arg "BUILD_ENV=unarchive" \
        --build-arg "HIVE_VERSION=$HIVE_VERSION" \
        --build-arg "HADOOP_VERSION=$HADOOP_VERSION" \
        --build-arg "TEZ_VERSION=$TEZ_VERSION" \

rm -r "${WORK_DIR}"
