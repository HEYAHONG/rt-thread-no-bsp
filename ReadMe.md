# 说明

在使用rt-thread写某款芯片的Demo时,经常遇到要引用rt-thread源码的情况.对于某一款芯片来说,rt-thread的源代码过于臃肿(导致占用空间极大,下载极慢)。而各个厂商的BSP一般是独立的,也意味着对于某确定芯片,其它厂商的BSP是不需要的。

rt-thread官方的做法是源代码中包含BSP代码,而我个人的习惯是Demo（也可以包含BSP代码）中包含rt-thread代码。我个人希望有类似FreeRTOS-Kernel那样,内核代码单独一个仓库,于是便有此仓库。

由于删除了bsp目录,可能导致文档不全,具体说明请查看官方源代码:

- https://gitee.com/rtthread/rt-thread.git
- https://github.com/RT-Thread/rt-thread.git

# 脚本说明

## update.sh

从官方源代码更新。支持在Linux或者WSL（WSL1/WSL2）中执行。依赖以下工具:

- git:git工具,用于下载源代码。
- mkdir:用于创建目录
- rsync：用于复制文件

