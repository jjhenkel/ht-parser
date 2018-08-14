#!/bin/sh

# Make log directory
mkdir -p ./logs

# Start drivers
echo "[ht-parser][${1}] Starting drivers as background processes..."
/opt/drivers/bash/bin/driver --address /tmp/bash --network unix &> ./logs/bash-driver.txt  & 
echo "[ht-parser][${1}][1/8] Bash driver listening on unix:///tmp/bash"
/opt/drivers/go/bin/driver --address /tmp/go --network unix &> ./logs/go-driver.txt & 
echo "[ht-parser][${1}][2/8] Go driver listening on unix:///tmp/go"
/opt/drivers/java/bin/driver --address /tmp/java --network unix &> ./logs/java-driver.txt &
echo "[ht-parser][${1}][3/8] Java driver listening on unix:///tmp/java"
/opt/drivers/javascript/bin/driver --address /tmp/javascript --network unix &> ./logs/javascript-driver.txt &
echo "[ht-parser][${1}][4/8] Javascript driver listening on unix:///tmp/javascript"
/opt/drivers/php/bin/driver --address /tmp/php --network unix &> ./logs/php-driver.txt &
echo "[ht-parser][${1}][5/8] Php driver listening on unix:///tmp/php"
/opt/drivers/python/bin/driver --address /tmp/python --network unix &> ./logs/python-driver.txt &
echo "[ht-parser][${1}][6/8] Python driver listening on unix:///tmp/python"
/opt/drivers/ruby/bin/driver --address /tmp/ruby --network unix &> ./logs/ruby-driver.txt & 
echo "[ht-parser][${1}][7/8] Ruby driver listening on unix:///tmp/ruby"
/opt/drivers/typescript/bin/driver --address /tmp/typescript --network unix &> ./logs/typescript-driver.txt & 
echo "[ht-parser][${1}][8/8] Typescript driver listening on unix:///tmp/typescript"
echo "[ht-parser][${1}] Drivers readied."

# Shallow clone
echo "[ht-parser][${1}] Cloning into /target (shallow clone)..."
git clone --depth 1 $1 ./target &> ./logs/shallow-clone.txt
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

# Make output dir for UASTs
mkdir -p ./repository-uasts

# Run enry and pipe to python app
echo "[ht-parser][${1}] Running enry + parser..."
enry -json | python3 /app/glue.py $REPO $BRANCH $COMMIT
echo "[ht-parser][${1}] Enry + parser completed."

# Go up a directory and compress
cd ../
tar -zcf "$(basename ${1} .git)-$BRANCH-$COMMIT.tar.gz" ./target/
tar -zcf "$(basename ${1} .git)-$BRANCH-$COMMIT-logs.tar.gz" ./logs/

# Log last bits of info
echo "[ht-parser][${1}] Produced: $(pwd)$(basename ${1} .git)-$BRANCH-$COMMIT.tar.gz"
echo "[ht-parser][${1}] Produced: $(pwd)$(basename ${1} .git)-$BRANCH-$COMMIT-logs.tar.gz"
echo "[ht-parser][${1}] Finished."