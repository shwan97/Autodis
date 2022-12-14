#!/bin/bash
# Copyright 2021 Huawei Technologies Co., Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: bash run_infer_310.sh [MINDIR_PATH] [DATASET_PATH] [DEVICE_ID]
    DEVICE_ID is optional, it can be set by environment variable device_id, otherwise the value is zero"
exit 1
fi

get_real_path(){
    if [ "${1:0:1}" == "/" ]; then
        echo "$1"
    else
        echo "$(realpath -m $PWD/$1)"
    fi
}
model=$(get_real_path $1)

dataset_path=$(get_real_path $2)
dataset_name="imagenet2012"
DVPP="CPU"

BASE_PATH=$(cd ./"`dirname $0`" || exit; pwd)
if [ $# -ge 1 ]; then
  if [ $dataset_name == 'cifar10' ]; then
    CONFIG_FILE="${BASE_PATH}/../default_config.yaml"
  elif [ $dataset_name == 'imagenet2012' ]; then
    CONFIG_FILE="${BASE_PATH}/../default_config_imagenet.yaml"
  else
    echo "Unrecognized parameter"
    exit 1
  fi
else
  CONFIG_FILE="${BASE_PATH}/../default_config.yaml"
fi


device_id=0
if [ $# == 3 ]; then
    device_id=$3
fi

echo "mindir name: "$model
echo "dataset path: "$dataset_path
echo "device id: "$device_id

export ASCEND_HOME=/usr/local/Ascend/
if [ -d ${ASCEND_HOME}/ascend-toolkit ]; then
    export ASCEND_HOME=/usr/local/Ascend/ascend-toolkit/latest
else
    export ASCEND_HOME=/usr/local/Ascend/latest
fi
export PATH=$ASCEND_HOME/compiler/ccec_compiler/bin:$PATH
export LD_LIBRARY_PATH=$ASCEND_HOME/lib64:/usr/local/Ascend/driver/lib64:$LD_LIBRARY_PATH
export ASCEND_OPP_PATH=$ASCEND_HOME/opp

function preprocess_data()
{
   if [ -d preprocess_Result ]; then
       rm -rf ./preprocess_Result
    fi
    mkdir preprocess_Result
    python ../preprocess.py --config_path=$CONFIG_FILE --dataset=$dataset_name --data_path=$dataset_path --result_path=./preprocess_Result/
}

function compile_app()
{
    cd ../ascend310_infer/ || exit
    bash build.sh &> build.log
}

function infer()
{
    cd - || exit
    if [ -d result_Files ]; then
        rm -rf ./result_Files
    fi
    if [ -d time_Result ]; then
        rm -rf ./time_Result
    fi
    mkdir result_Files
    mkdir time_Result

    if [ "$DVPP" == "DVPP" ]; then
        ../ascend310_infer/out/main --mindir_path=$model --dataset_name=$dataset_name --input0_path=$dataset_path --device_id=$device_id --cpu_dvpp=../ascend310_infer/aipp.cfg --image_height=256 --image_width=256  &> infer.log
    else
        ../ascend310_infer/out/main --mindir_path=$model --dataset_name=$dataset_name --input0_path=$dataset_path --device_id=$device_id &> infer.log
    fi
}

function cal_acc()
{

    python ../postprocess.py --config_path=$CONFIG_FILE --result_dir=./result_Files --label_dir=./preprocess_Result/imagenet_label.json   &> acc.log

}


preprocess_data
if [ $? -ne 0 ]; then
    echo "preprocess dataset failed"
    exit 1
fi

compile_app
if [ $? -ne 0 ]; then
    echo "compile app code failed"
    exit 1
fi
infer
if [ $? -ne 0 ]; then
    echo " execute inference failed"
    exit 1
fi
cal_acc
if [ $? -ne 0 ]; then
    echo "calculate accuracy failed"
    exit 1
fi
