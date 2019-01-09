#!/bin/sh

# set -ex

# export GRPC_GO_LOG_SEVERITY_LEVEL=info
# export GRPC_GO_LOG_VERBOSITY_LEVEL=2

# mkdir -p /opt/driver/etc
# mkdir -p /opt/driver/bin

# Start drivers
# echo "[ht-parser][${1}] Starting drivers as background processes..."

# ln -sf /opt/drivers/bash/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/bash/bin/native-jar-with-dependencies.jar /opt/driver/bin/native-jar-with-dependencies.jar
# ln -sf /opt/drivers/bash/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/bash/bin/driver --address localhost:9432 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][1/9] Bash driver listening on localhost:9432"

# ln -sf /opt/drivers/go/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/go/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/go/bin/driver --address localhost:9433 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][2/9] Go driver listening on localhost:9433"

# ln -sf /opt/drivers/java/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/java/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/java/bin/driver --address localhost:9434 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][3/9] Java driver listening on localhost:9434"

# ln -sf /opt/drivers/javascript/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/javascript/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/javascript/bin/driver --address localhost:9435 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][4/9] Javascript driver listening on localhost:9435"

# ln -sf /opt/drivers/php/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/php/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/php/bin/driver --address localhost:9436 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][5/9] Php driver listening on localhost:9436"

# ln -sf /opt/drivers/python/bin/.local /opt/driver/bin/.local
# ln -sf /opt/drivers/python/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/python/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/python/bin/driver --address localhost:9437 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][6/9] Python driver listening on localhost:9437"

# ln -sf /opt/drivers/ruby/bin/lib /opt/driver/bin/lib
# ln -sf /opt/drivers/ruby/bin/gems /opt/driver/bin/gems
# ln -sf /opt/drivers/ruby/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/ruby/bin/native.rb /opt/driver/bin/native.rb
# ln -sf /opt/drivers/ruby/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/ruby/bin/driver --address localhost:9438 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][7/9] Ruby driver listening on localhost:9438"

# ln -sf /opt/drivers/typescript/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/typescript/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/typescript/bin/driver --address localhost:9439 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][8/9] Typescript driver listening on localhost:9439"

# ln -sf /opt/drivers/cpp/bin/native /opt/driver/bin/native
# ln -sf /opt/drivers/cpp/etc/manifest.toml /opt/driver/etc/manifest.toml
# /opt/drivers/cpp/bin/driver --address localhost:9440 --log-level debug &
# sleep 5
# echo "[ht-parser][${1}][9/9] C/C++ driver listening on localhost:9440"

# echo "[ht-parser][${1}] Drivers readied."

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