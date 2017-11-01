if [ $# -lt 1 ]; then
  echo '$1 <Directory for training datasets>'
  exit
fi

args=("$@")

for ((i=0;i<$#;i++)); do
        python datasets/combine_A_and_B.py --fold_A /home/sjang/work/fontto/pytorch-CycleGAN-and-pix2pix/datasets/${args[$i]}/A --fold_B /home/sjang/work/fontto/pytorch-CycleGAN-and-pix2pix/datasets/${args[$i]}/B --fold_AB /home/sjang/work/fontto/pytorch-CycleGAN-and-pix2pix/datasets/${args[$i]}/AB
        python train.py --dataroot ./datasets/${args[$i]}/AB --name ${args[$i]}_pix2pix --model pix2pix --which_model_netG unet_256 --which_direction AtoB --lambda_A 100 --dataset_mode aligned --no_lsgan --no_flip --norm batch --pool_size 0 --display_id=0 --gpu_ids=0,1,2,3 --batchSize=91 --niter=2000 --niter_decay=0 --save_epoch_freq=500 --resize_or_crop=''
        bash test.sh ${args[$i]}_pix2pix
done
