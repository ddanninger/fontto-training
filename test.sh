#!/usr/bin/env bash
if [ $# -lt 1 ]; then
  echo '$1 <name for trained data>'
  exit
fi

#data_root=./testsets_256/`echo $1 | cut -f 1 -d'_'`
UNICODE_A=`echo $1 | cut -f 1 -d'_'`
CHARACTER_A=`printf "\u$UNICODE_A"`
DATA_ROOT=testsets_uhbeePlus/${CHARACTER_A}/

if [ ! -d ${DATA_ROOT} ]
then
  printf "there is no testset [%s]" ${DATA_ROOT}
  exit
fi


python test.py --dataroot ${DATA_ROOT} --name $1_pix2pix --model test --which_model_netG unet_256 --which_direction AtoB --dataset_mode single --norm batch --gpu_ids=0,1 --how_many=100
