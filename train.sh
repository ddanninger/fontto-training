if [ $# -lt 3 ]; then
  echo '$1 <hangle A>, $2 <hangle B>, $3 <epoch>'
  exit
fi


echo `date`
printf "_____________start training [%s]->[%s], epoch [%s]_____________\n" $1 $2 $3
# make dataset
JPG_DIR=fonts_256
DATASET_DIR=datasets
CHECK_DIR=checkpoints

printf "start copying [%s] to A\n" $1
cp -r ${JPG_DIR}/$1 A
mkdir A/train
mv A/*.jpg A/train
printf "done! copying [%s] to A\n" $1

cp -r ${JPG_DIR}/$2 B
printf "start copying [%s] to B\n" $2
mkdir B/train
mv B/*.jpg B/train
printf "done! copying [%s] to B\n" $2

UNICODE_A=`printf "%X" "'$1'"`
UNICODE_B=`printf "%X" "'$2'"`
OUTPUT_DIR=${UNICODE_A}_${UNICODE_B}_${JPG_DIR}

printf "start making data [%s]\n" ${DATASET_DIR}/${OUTPUT_DIR}
mkdir $OUTPUT_DIR
mv A B $OUTPUT_DIR
mv $OUTPUT_DIR $DATASET_DIR
printf "done! making data [%s]\n" ${DATASET_DIR}/${OUTPUT_DIR}


# convert dataset into aligned images
printf "start converting data into algned images [%s]\n" ${DATASET_DIR}/${OUTPUT_DIR}/AB
python ${DATASET_DIR}/combine_A_and_B.py --fold_A=${DATASET_DIR}/${OUTPUT_DIR}/A --fold_B=${DATASET_DIR}/${OUTPUT_DIR}/B --fold_AB=${DATASET_DIR}/${OUTPUT_DIR}/AB
printf "done! converting data into algned images [%s]\n" ${DATASET_DIR}/${OUTPUT_DIR}/AB

# training
printf "start training"
echo ${OUTPUT_DIR}_pix2pix
python train.py --dataroot ${DATASET_DIR}/${OUTPUT_DIR}/AB --name ${OUTPUT_DIR}_pix2pix --model pix2pix --which_model_netG unet_256 --which_direction AtoB --lambda_A 100 --dataset_mode aligned --no_lsgan --no_flip --norm batch --pool_size 0 --display_id=0 --gpu_ids=0,1,2,3 --batchSize=60 --niter=$3 --niter_decay=0 --save_epoch_freq=$3 --loadSize=256 --fineSize=256 --input_nc=1 --output_nc=1 --slack_freq=200 --no_html --nThreads=6
printf "done! training"
python send_to_slack.py --msg="학습이 종료되었습니다." --channel=training


# test
# bash test.sh ${OUTPUT_DIR}


# upload pth to S3
aws s3 cp ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix/$3_net_G.pth s3://fontto/data/pths/${UNICODE_A}/${UNICODE_A}_${UNICODE_B}/
python send_to_slack.py --msg="`printf "[%s_%s/%s_net_G.pth]가 s3에 업로드 되었습니다." $UNICODE_A $UNICODE_B $3`" --channel=training


# delete used data for space's sake
rm -rf ${DATASET_DIR}/${OUTPUT_DIR}
printf "removed [%s]\n" ${DATASET_DIR}/${OUTPUT_DIR}

rsync -av --remove-source-files ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix ./trash
rm -rf ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix
printf "moved [%s] to trash\n" ${CHECK_DIR}/${OUTPUT_DIR}_pix2pix
printf "_____________done! training [%s]->[%s], epoch [%s]_____________\n" $1 $2 $3
