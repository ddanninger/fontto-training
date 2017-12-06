#!/bin/bash
args=("$@")

# get ip address
IP_ADDRESS=`curl bot.whatismyipaddress.com`
EPOCH=1000
TRASH_DIR=trash
NUM_TRAINING=$#
NUM_TRAINING=$((NUM_TRAINING/2))

for (( i=0; i<$#; i=$((i+2)) ))
do
    TRAIN_LIST="$TRAIN_LIST [${args[$i]} -> ${args[$((i+1))]}]"
done

echo $TRAIN_LIST

echo `date`
printf "_____________start multi training NUM_TRAINING : ${NUM_TRAINING}_____________\n" 
python send_to_slack.py --msg="____________[$IP_ADDRESS][multi training start] 새로운 멀티 학습이 시작됩니다. [${NUM_TRAINING}개] ${TRAIN_LIST}____________" --channel=training_queue


for (( i=0; i<$#; i=$((i+2)) ))
do
    echo `date`

    CHARACTER_A=${args[$i]}
    CHARACTER_B=${args[$((i+1))]}
    UNICODE_A=`printf "%X" "'$CHARACTER_A'"`
    UNICODE_B=`printf "%X" "'$CHARACTER_B'"`
    OUTPUT_DIR=${UNICODE_A}_${UNICODE_B}_${JPG_DIR}
    COUNT_PTH=`aws s3 ls s3://fontto/data/pths/${UNICODE_A}/${UNICODE_A}_${UNICODE_B} | wc -l`

    printf "_____________start training [%s]->[%s], epoch [%s], ip [%s]_____________\n" ${CHARACTER_A} ${CHARACTER_B} ${EPOCH} ${IP_ADDRESS}
    python send_to_slack.py --msg="[$IP_ADDRESS][$((i/2+1))/${NUM_TRAINING}][start] 새로운 학습이 시작됩니다. [${CHARACTER_A}]->[${CHARACTER_B}], epoch [${EPOCH}]" --channel=training_queue
    echo "[시작] $1 $2 $3"


    echo $IP_ADDRESS
    echo $CHARACTER_A
    echo $CHARACTER_B
    echo $UNICODE_A
    echo $UNICODE_B
    echo $COUNT_PTH
    # check if s3 aleady has the pth
    if [[ ${COUNT_PTH} -gt 0 ]]; then
        echo "s3에 pth 이미 존재"
        python send_to_slack.py --msg="[$IP_ADDRESS][$((i/2+1))/${NUM_TRAINING}][done][실패] s3에 이미 pth가 존재합니다. [${CHARACTER_A}]->[${CHARACTER_B}] [s3://fontto/data/pths/${UNICODE_A}/${UNICODE_A}_${UNICODE_B}]" --channel=training_queue
        continue
    fi

    # train
    bash train.sh ${CHARACTER_A} ${CHARACTER_B} ${EPOCH}

    # check if train was good or not
    if [ -f ${TRASH_DIR}/${OUTPUT_DIR}_pix2pix/$3_net_G.pth ]
    then
        echo "[성공] ${CHARACTER_A} ${CHARACTER_B} ${EPOCH}"
        python send_to_slack.py --msg="[$IP_ADDRESS][$((i/2+1))/${NUM_TRAINING}][done][성공] 학습이 종료됐습니다. [${CHARACTER_A}]->[${CHARACTER_B}], epoch [${EPOCH}]" --channel=training_queue
    else
        echo "**[실패] ${CHARACTER_A} ${CHARACTER_B} ${EPOCH}"
        printf "[%s]를 찾을 수 없습니다." ${TRASH_DIR}/${OUTPUT_DIR}_pix2pix/$3_net_G.pth
        python send_to_slack.py --msg="[$IP_ADDRESS][$((i/2+1))/${NUM_TRAINING}][done][실패] 학습이 종료됐습니다. [${CHARACTER_A}]->[${CHARACTER_B}], epoch [${EPOCH}]****" --channel=training_queue
    fi
done

echo `date`
printf "_____________done! multi training NUM_TRAINING : ${NUM_TRAINING}_____________\n" 
python send_to_slack.py --msg="____________[$IP_ADDRESS][multi training done!] 멀티 학습을 종료했습니다. [${NUM_TRAINING}개] ${TRAIN_LIST}____________" --channel=training_queue
