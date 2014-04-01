#!/bin/bash
# Script: prsync.sh
# Author: Liush
# Date: 2014/03/20
# For STUDY

# 定义并发数量
PARALLEL=4

# 定义临时管理文件名
TEMPFILE=$$.fifo

# 定义导出配置文件全路径名
CMD_CFG=$HOME/cfg/prsync.cfg

# 定义失败标识文件
FAILURE_FLAG=failure.log

# 中断时kill子进程
functions trap_exit
{
    kill -9 0
}

# 通用执行函数
exec_cmd() {
    # 此处为实际需要执行的命令
    # rsync -av 219.239.94.111:/bank/bank10/img14/uploadimg/$1 /bank/bank10/uploadimg/ &
    sleep 2
    if [ $? -ne 0 ]; then
        echo "command execute failure"
        return 1
    fi
}

##########################主程序######################
trap 'trap_exit; exit 2' 1 2 3 15

# 清理失败标识文件
rm -f ${FAILURE_FLAG}

# 为并发进程创建相应个数的占位(创建命名管道)
mkfifo $TEMPFILE

# 为命名管道定义文件标识符为4, <>分别为输入和输出,即绑定了该管道的输入输出都在4这个文件标识符上!
exec 4<>$TEMPFILE

# 删除管道文件
rm -f $TEMPFILE

{
    count=$PARALLEL
    while [ $count -gt 0 ]
    do
        echo
        let count=$count-1
    done
} >&4

# 从任务列表seq中按次序获取每一个任务(从家目录下那个cfg文件中读取)
while read SEC
do
    read <&4
    # 从后台执行主程序命令或者输出错误日志,完成后清空标识符
    ( exec_cmd ${SEC} ||echo ${SEC}>>${FAILURE_FLAG}; echo >&4 )&
done <$CMD_CFG

#等待子进程结果返回值
wait

# 关闭文件标识符4
exec 4>&-

# 并发进程结束后判断是否全部成功
if [ -f ${FAILURE_FLAG} ]; then
    exit 1
else
    exit 0
fi
