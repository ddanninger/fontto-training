#!/usr/bin/env bash
TESTSET_NAME_S3=testsets_font_256
TESTSET_NAME_OUT=testsets_256

if [ -d ${TESTSET_NAME_OUT} ]
then
    printf "[%s]가 이미 존재합니다.\n" ${TESTSET_NAME_OUT}
    exit
fi

aws s3 cp --recursive s3://fontto/data/${TESTSET_NAME_S3}/ $TESTSET_NAME_OUT/
