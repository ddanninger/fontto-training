##  fontto-training
> Train two hangle character images using Pix2Pix network to generate font for fontto service

## Requirements
- Opencv
- Pytorch
- Python3
- CPU or NVIDIA GPU + CUDA CuDNN
- visdom
- dominate
- bash

## Usage 

1. install setting
```
bash setting.sh
```
2. train two hangle
```
train.sh <hangle1> <hangle2> <epoch>
```

## Main role
1. Train hangle images using Pix2Pix network
2. Send process of training to slack
3. Upload trained pth file to S3
