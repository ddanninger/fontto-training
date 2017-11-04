if [ $# -lt 1 ]; then
  echo '$1 <name for trained data>'
  exit
fi

data_root=./testsets/`echo $1 | cut -f 1 -d'_'`
python test.py --dataroot $data_root --name $1_pix2pix --model test --which_model_netG unet_256 --which_direction AtoB --dataset_mode single --norm batch --how_many 100 --resize_or_crop=''
