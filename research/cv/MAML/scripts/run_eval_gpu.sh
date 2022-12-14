#!/bin/bash
# Copyright 2022 Huawei Technologies Co., Ltd
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
if [ $# != 3 ] ; then
echo "=============================================================================================================="
echo "Please run the script as: "
echo "bash run_eval_gpu.sh [DEVICE_ID] [DATA_PATH] [CKPT_PATH]"
echo "for example: bash run_eval_gpu.sh 0 '/your/path/omniglot/' '/your/path/ckpt_outputs/maml.ckpt'"
echo "Note: set the checkpoint and dataset path in default_config.yaml"
echo "=============================================================================================================="
exit 1;
fi

export DEVICE_ID=$1
PATH2=$2
PATH3=$3
echo $PATH2
echo $PATH3

cd ..
python eval.py  \
    --device_id=$DEVICE_ID \
    --device_target="GPU" \
    --data_path=$PATH2 \
    --ckpt=$PATH3
