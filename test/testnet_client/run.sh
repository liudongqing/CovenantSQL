#!/bin/bash -x
set -e

TEST_WD=$(cd $(dirname $0)/; pwd)
PROJECT_DIR=$(cd ${TEST_WD}/../../; pwd)
BIN=${PROJECT_DIR}/bin

echo ${PROJECT_DIR}

# Build
# cd ${PROJECT_DIR} && make clean
# cd ${PROJECT_DIR} && make use_all_cores

cd ${TEST_WD}

echo -ne "y\n" | ${BIN}/cql-utils -tool confgen -skip-master-key

#get wallet addr
${BIN}/cql-utils -tool addrgen -skip-master-key | tee wallet.txt
wallet=$(awk '{print $3}' wallet.txt)

#transfer some coin to above address
${BIN}/cql -config ${PROJECT_DIR}/conf/testnet/config.yaml -transfer \
    '{"addr":"'${wallet}'", "amount":"100000000 Particle"}' -wait-tx-confirm

${BIN}/cql -get-balance

${BIN}/cql -create 2 -wait-tx-confirm | tee dsn.txt

#get dsn
dsn=$(cat dsn.txt)

${BIN}/cql -dsn ${dsn} \
    -command 'create table test_for_new_account(column1 int);'

${BIN}/cql -dsn ${dsn} \
    -command 'show tables;' | tee result.log

grep "1 row" result.log
