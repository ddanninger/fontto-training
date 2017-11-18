#!/usr/bin/env bash

DATASET_DIR=datasets
DATASET_NAME=B9DD_D569_debugging

if [ ! -d ${DATASET_DIR}/${DATASET_NAME} ]
then
    printf "[%s]을 s3으로부터 다운로드합니다.\n" $DATASET_NAME
    aws s3 cp --recursive s3://fontto/data/${DATASET_NAME}/ ${DATASET_DIR}/${DATASET_NAME}
else
    printf "[%s]가 이미 존재합니다.\n" ${DATASET_DIR}/$DATASET_NAME
fi
