if [ $# -lt 1 ]; then
  echo '$1 <Directory for training datasets>'
  exit
fi

args=("$@")

for ((i=0;i<$#;i++)); do
        python datasets/combine_A_and_B.py --fold_A datasets/${args[$i]}/A --fold_B datasets/${args[$i]}/B --fold_AB datasets/${args[$i]}/AB
        python train.py --dataroot ./datasets/${args[$i]}/AB --name ${args[$i]}_pix2pix --model pix2pix --which_model_netG unet_256 --which_direction AtoB --lambda_A 100 --dataset_mode aligned --no_lsgan --no_flip --norm batch --pool_size 0 --display_id=0 --gpu_ids=0,1,2,3 --batchSize=180 --niter=1000 --niter_decay=0 --save_epoch_freq=300
        bash test.sh ${args[$i]}
done
