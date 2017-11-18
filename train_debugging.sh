#!/usr/bin/env bash
echo `date`

# make dataset
JPG_DIR=fonts_256
DATASET_DIR=datasets
CHECK_DIR=checkpoints

DEBUGGING_DATA=B9DD_D569_debugging


# these values should be changed accordingly
NUM_THREADS=6
GPU_IDS=0,1,2,3
SLACK_FREQ=10000

BATCH_SIZE=60
EPOCH=10


printf "_____________start debugging [%s]_____________\n" ${DATASET_DIR}/${DEBUGGING_DATA}

if [ ! -d ${DATASET_DIR}/${DEBUGGING_DATA} ]
then
    printf "can't find directory [%s]" ${DATASET_DIR}/${DEBUGGING_DATA}
    exit
fi


# training
printf "start training\n"
python train.py --dataroot ${DATASET_DIR}/${DEBUGGING_DATA}/AB --name ${DEBUGGING_DATA}_pix2pix --model pix2pix --which_model_netG unet_256 --which_direction AtoB --lambda_A 100 --dataset_mode aligned --no_lsgan --no_flip --norm batch --pool_size 0 --display_id=0 --gpu_ids=${GPU_IDS} --batchSize=${BATCH_SIZE} --niter=${EPOCH} --niter_decay=0 --save_epoch_freq=${EPOCH} --loadSize=256 --fineSize=256 --input_nc=1 --output_nc=1 --slack_freq=${SLACK_FREQ} --no_html --nThreads=${NUM_THREADS} --debugging
printf "done! training\n"

# remove chechpoint
if [ -d ${CHECK_DIR}/${DEBUGGING_DATA}_pix2pix ]
then
    rm -rf ${CHECK_DIR}/${DEBUGGING_DATA}_pix2pix
    printf "removed [%s]\n" ${CHECK_DIR}/${DEBUGGING_DATA}_pix2pix
fi

printf "_____________done! debugging [%s]_____________\n" ${DATASET_DIR}/${DEBUGGING_DATA}
