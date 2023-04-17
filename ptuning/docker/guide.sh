#!/usr/bin/env bash

# build docker for chatglm-6b training
docker build -t chatglm_6b_training -f train.gpu.Dockerfile .

docker tag
docker login
docker push

docker run -it -
