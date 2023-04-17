#!/usr/bin/env bash

# activate base
source /app/dev/miniconda3/bin/activate base
conda env list

# install
pip install protobuf \
            torch transformers datasets accelerate peft \
            icetk cpm_kernels rouge_chinese nltk jieba \
            gradio==3.20.0 mdtex2html fastapi uvicorn requests
