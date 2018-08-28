#!/bin/sh

# set -ex

# export GRPC_GO_LOG_SEVERITY_LEVEL=info
# export GRPC_GO_LOG_VERBOSITY_LEVEL=2

# Start drivers
echo "[ht-parser][${1}] Starting drivers as background processes..."
/opt/drivers/bash/bin/driver --address localhost:9432 --log-level debug & 
echo "[ht-parser][${1}][1/8] Bash driver listening on unix:///tmp/bash"
/opt/drivers/go/bin/driver --address localhost:9433 --log-level debug & 
echo "[ht-parser][${1}][2/8] Go driver listening on unix:///tmp/go"
/opt/drivers/java/bin/driver --address localhost:9434 --log-level debug & 
echo "[ht-parser][${1}][3/8] Java driver listening on unix:///tmp/java"
/opt/drivers/javascript/bin/driver --address localhost:9435 --log-level debug & 
echo "[ht-parser][${1}][4/8] Javascript driver listening on unix:///tmp/javascript"
/opt/drivers/php/bin/driver --address localhost:9436 --log-level debug & 
echo "[ht-parser][${1}][5/8] Php driver listening on unix:///tmp/php"
/opt/drivers/python/bin/driver --address localhost:9437 --log-level debug & 
echo "[ht-parser][${1}][6/8] Python driver listening on unix:///tmp/python"
/opt/drivers/ruby/bin/driver --address localhost:9438 --log-level debug & 
echo "[ht-parser][${1}][7/8] Ruby driver listening on unix:///tmp/ruby"
/opt/drivers/typescript/bin/driver --address localhost:9439 --log-level debug & 
echo "[ht-parser][${1}][8/8] Typescript driver listening on unix:///tmp/typescript"
echo "[ht-parser][${1}] Drivers readied."

# Shallow clone
echo "[ht-parser][${1}] Cloning into /target (shallow clone)..."
git clone --depth 1 $1 ./target
echo "[ht-parser][${1}] Shallow clone complete"

# Get into target dir and grab some info
echo "[ht-parser][${1}] cd /target"
cd ./target

echo "[ht-parser][${1}] Collecting repo info..."
REPO="${1}"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "[ht-parser][${1}][1/2] CURRENT_BRANCH='${BRANCH}'"
COMMIT="$(git rev-parse HEAD)"
echo "[ht-parser][${1}][2/2] CURRENT_COMMIT='${COMMIT}'"
echo "[ht-parser][${1}] Repo info collected."

# Run enry and pipe to python app
echo "[ht-parser][${1}] Running enry + parser..."
enry -json | python3 /app/glue.py $REPO $BRANCH $COMMIT \
  >> "../$(basename ${1} .git)-$BRANCH-$COMMIT.tsv"
echo "[ht-parser][${1}] Enry + parser completed."

# Go up a directory and compress
cd ../
# tar -zcf "$(basename ${1} .git)-$BRANCH-$COMMIT-logs.tar.gz" ./logs/

# Log last bits of info
echo "[ht-parser][${1}] Produced: $(pwd)$(basename ${1} .git)-$BRANCH-$COMMIT.tsv"
# echo "[ht-parser][${1}] Produced: $(pwd)$(basename ${1} .git)-$BRANCH-$COMMIT-logs.tar.gz"
echo "[ht-parser][${1}] Finished."