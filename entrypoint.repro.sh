#!/bin/sh

set -ex

TARG=https://github.com/antirez/redis.git

# export GRPC_GO_LOG_SEVERITY_LEVEL=info
# export GRPC_GO_LOG_VERBOSITY_LEVEL=2

mkdir -p /opt/driver/etc
mkdir -p /opt/driver/bin

# Start drivers
echo "[ht-parser][${TARG}] Starting drivers as background processes..."

ln -sf /opt/drivers/cpp/bin/native /opt/driver/bin/native
ln -sf /opt/drivers/cpp/etc/manifest.toml /opt/driver/etc/manifest.toml
/opt/drivers/cpp/bin/driver --address localhost:9440 --log-level debug &
sleep 5
echo "[ht-parser][${TARG}] C/C++ driver listening on localhost:9440"

echo "[ht-parser][${TARG}] Drivers readied."

# Shallow clone
echo "[ht-parser][${TARG}] Cloning into /target (shallow clone)..."
git clone --depth 1 $TARG ./target
echo "[ht-parser][${TARG}] Shallow clone complete"

# Get into target dir and grab some info
echo "[ht-parser][${TARG}] cd /target"
cd ./target

echo "[ht-parser][${TARG}] Collecting repo info..."
REPO="${TARG}"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "[ht-parser][${TARG}][1/2] CURRENT_BRANCH='${BRANCH}'"
COMMIT="$(git rev-parse HEAD)"
echo "[ht-parser][${TARG}][2/2] CURRENT_COMMIT='${COMMIT}'"
echo "[ht-parser][${TARG}] Repo info collected."

# Run enry and pipe to python app
echo "[ht-parser][${TARG}] Running enry + parser..."
enry -json | python3 /app/glue.repro.py $REPO $BRANCH $COMMIT \
  >> "../$(basename ${TARG} .git)-$BRANCH-$COMMIT.tsv"
echo "[ht-parser][${TARG}] Enry + parser completed."

# Go up a directory and compress
cd ../
# tar -zcf "$(basename ${TARG} .git)-$BRANCH-$COMMIT-logs.tar.gz" ./logs/

# Log last bits of info
echo "[ht-parser][${TARG}] Produced: $(pwd)$(basename ${TARG} .git)-$BRANCH-$COMMIT.tsv"
# echo "[ht-parser][${TARG}] Produced: $(pwd)$(basename ${TARG} .git)-$BRANCH-$COMMIT-logs.tar.gz"
echo "[ht-parser][${TARG}] Finished."