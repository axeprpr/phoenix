#!/bin/bash -x
###
 # @Description: 
 # @Date: 2023-03-31 17:35:54
 # @LastEditTime: 2023-12-23 01:24:58
 # @FilePath: \phoenix\installation\setup.sh
### 
WORK_DIR=$(cd `dirname $0`; pwd)
MODULE_DIR=/opt/astute_phoenix
MODULE_COMMAND=/usr/bin/ph

if [ `whoami` != "root" ];then  
    echo "Need root."
    exit -1  
fi

if [ -d $MODULE_DIR ];then
    rm -rf $MODULE_DIR
fi

if [ -L $MODULE_COMMAND ];then
    rm -f $MODULE_COMMAND
fi

mkdir $MODULE_DIR
cp -rf scripts utils ./phoenix.sh $MODULE_DIR
chmod 755 $MODULE_DIR -R

ln -s ${MODULE_DIR}/phoenix.sh $MODULE_COMMAND