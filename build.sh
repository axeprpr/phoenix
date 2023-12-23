#!/bin/bash
###
 # @Description: 
 # @Date: 2023-12-23 11:36:03
 # @LastEditTime: 2023-12-23 11:39:45
 # @FilePath: \phoenix\build.sh
### 
WORK_DIR=$(cd `dirname $0`; pwd)

VERSION_NO=1.0.0
CODEDIR=phoenix

[ -z $BUILD_NUMBER ] && BUILD_NUMBER=0
[ -z $GIT_COMMIT ] && GIT_COMMIT="null"

cd $WORK_DIR
# clean bins
rm -f $WORK_DIR/*.bin
rm -f $WORK_DIR/*.md5
makeself=$WORK_DIR/makeself/makeself.sh

# make shadowman.bin
chmod +x $makeself
chmod +x $WORK_DIR/installation/setup.sh
$makeself --gzip $WORK_DIR/installation phoenix.$BUILD_NUMBER.bin phoenix  ./setup.sh
chmod +x phoenix.$BUILD_NUMBER.bin
md5sum phoenix.$BUILD_NUMBER.bin > phoenix.$BUILD_NUMBER.bin.md5