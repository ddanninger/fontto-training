#!/usr/bin/env bash
if [ $# -lt 3 ]; then
  echo '$1 <hangle A>, $2 <hangle B>, $3 <epoch>'
  exit
fi


echo `date`
printf "_____________start training [%s]->[%s], epoch [%s]_____________\n" $1 $2 $3
# dataset argument
JPG_DIR=fonts_256
DATASET_DIR=datasets
CHECK_DIR=checkpoints

# these values should be changed accordingly
NUM_THREADS=6
GPU_IDS=0,1,2,3
SLACK_FREQ=200
BATCH_SIZE=60
SAVE_EPOCH_FREQ=100


UNICODE_A=`printf "%X" "'$1'"`
UNICODE_B=`printf "%X" "'$2'"`
OUTPUT_DIR=${UNICODE_A}_${UNICODE_B}_${JPG_DIR}

# check if data exist
# if not exist, make data in dataset
if [ ! -d ${DATASET_DIR}/${OUTPUT_DIR} ]
then
  # convert dataset into aligned images
  printf "start converting data into algned images [%s]\n" ${DATASET_DIR}/${OUTPUT_DIR}/AB
  python ${DATASET_DIR}/combine_A_and_B.py --fold_A=${JPG_DIR}/$1 --fold_B=${JPG_DIR}/$2 --fold_AB=${DATASET_DIR}/${OUTPUT_DIR}/AB
  printf "done! converting data into algned images [%s]\n" ${DATASET_DIR}/${OUTPUT_DIR}/AB
else
  printf "dataset [%s] already exist\n" ${DATASET_DIR}/${OUTPUT_DIR}/
fi


# training
printf "start training\n"
echo ${OUTPUT_DIR}_pix2pix
python train.py --dataroot ${DATASET_DIR}/${OUTPUT_DIR}/AB --name ${OUTPUT_DIR}_pix2pix --model pix2pix --which_model_netG unet_256 --which_direction AtoB --lambda_A 100 --dataset_mode aligned --no_lsgan --no_flip --norm batch --pool_size 0 --display_id=0 --gpu_ids=${GPU_IDS} --batchSize=${BATCH_SIZE} --niter=$3 --niter_decay=0 --save_epoch_freq=${SAVE_EPOCH_FREQ} --loadSize=256 --fineSize=256 --input_nc=1 --output_nc=1 --slack_freq=${SLACK_FREQ} --no_html --nThreads=${NUM_THREADS}
printf "done! training\n"
python send_to_slack.py --msg="학습이 종료되었습니다." --channel=training


# test
# bash test.sh ${OUTPUT_DIR}


# upload pth to S3
if [ -f ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix/$3_net_G.pth ]
then
  aws s3 cp ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix/$3_net_G.pth s3://fontto/data/pths/${UNICODE_A}/${UNICODE_A}_${UNICODE_B}/
  python send_to_slack.py --msg="`printf "[%s_%s/%s_net_G.pth]가 s3에 업로드 되었습니다." $UNICODE_A $UNICODE_B $3`" --channel=training
else
  python send_to_slack.py --msg="`printf "[%s_%s/%s_net_G.pth]업로드가 실패했습니다." $UNICODE_A $UNICODE_B $3`" --channel=training
  printf "[%s]를 찾을 수 없습니다." ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix/$3_net_G.pth
fi

# delete used data for space's sake
rm -rf ${DATASET_DIR}/${OUTPUT_DIR}
printf "removed [%s]\n" ${DATASET_DIR}/${OUTPUT_DIR}

rsync -av --remove-source-files ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix ./trash
rm -rf ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix
printf "moved [%s] to trash\n" ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix
printf "_____________done! training [%s]->[%s], epoch [%s]_____________\n" $1 $2 $3
