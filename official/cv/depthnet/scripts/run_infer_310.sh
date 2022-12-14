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

if [[ $# -lt 3 || $# -gt 5 ]]; then 
    echo "Usage: bash run_infer_310.sh [MINDIR1_PATH] [MINDIR2_PATH] [DATA_PATH] [DEVICE_ID]
    DEVICE_ID is optional, default value is zero"
exit 1
fi

get_real_path(){
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}

model1=$(get_real_path $1)
model2=$(get_real_path $2)
data_path=$(get_real_path $3)
label_file=$(get_real_path $4)

device_id=0

if [ $# == 6 ]; then
    device_id=$6
fi

echo $model1
echo $model2
echo $data_path
echo $label_file
echo $device_id

export ASCEND_HOME=/usr/local/Ascend/
if [ -d ${ASCEND_HOME}/ascend-toolkit ]; then
    export ASCEND_HOME=/usr/local/Ascend/ascend-toolkit/latest
else
    export ASCEND_HOME=/usr/local/Ascend/latest
fi
export PATH=$ASCEND_HOME/compiler/ccec_compiler/bin:$PATH
export LD_LIBRARY_PATH=$ASCEND_HOME/lib64:/usr/local/Ascend/driver/lib64:$LD_LIBRARY_PATH
export ASCEND_OPP_PATH=$ASCEND_HOME/opp

function compile_app()
{
    cd ../ascend310_infer || exit
    if [ -f "Makefile" ]; then
        make clean
    fi
    bash build.sh &> build.log

    if [ $? -ne 0 ]; then
        echo "compile app code failed"
        exit 1
    fi
    cd - || exit
}

function preprocess_data()
{
    if [ -d preprocess_Result ]; then
        rm -rf ./preprocess_Result
    fi
    mkdir preprocess_Result

    python ../preprocess.py --dataset_path=$data_path --output_path=./preprocess_Result
}

function infer()
{
    if [ -d result_Files ]; then
        rm -rf ./result_Files
    fi
     if [ -d time_Result ]; then
        rm -rf ./time_Result
    fi
    mkdir result_Files
    mkdir time_Result
    ../ascend310_infer/out/main --model1_path=$model1 --model2_path=$model2 --dataset_path=$data_path --device_id=$device_id &> infer.log

    if [ $? -ne 0 ]; then
        echo "execute inference failed"
        exit 1
    fi
}

function cal_acc()
{
    python ../postprocess.py --label_file=./preprocess_Result/label --result_path=result_Files &>acc.log
    if [ $? -ne 0 ]; then
        echo "calculate accuracy failed"
        exit 1
    fi
}

preprocess_data
data_path=./preprocess_Result/img_data
compile_app
infer
cal_acc
