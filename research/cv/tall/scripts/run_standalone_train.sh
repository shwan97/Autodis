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

export DEVICE_ID=0
export DEVICE_NUM=1
export RANK_ID=0
export RANK_SIZE=1


if [ $# != 2 ]
then
    echo "Usage: bash run_standalone_train.sh [TRAIN_DATA_DIR] [DEVICE_ID]."
    exit 1
fi

if [ ! -d $1 ]
then
    echo "error: TRAIN_DATA_DIR=$1 is not a directory"
    echo "Usage: bash run_standalone_train.sh [TRAIN_DATA_DIR] [DEVICE_ID]."
exit 1
fi

python train.py --train_data_dir=$1 --device_id=$2 > train.log 2>&1 &
