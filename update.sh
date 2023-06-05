#!/bin/bash

#检查工具是否存在,$1为待检查的工具名。
function CheckTool
{
	[  -n "$1"  ] ||
	{
		echo -e  "\033[41;37mCheckTool 参数错误!!\r\n\033[40;37m";
		return 255;
	};
	ToolPath=`which $1`;
	[ -e "$ToolPath" ] ||
	{
		 echo -e "\033[41;37m$1 不存在，请先安装此工具\r\n\033[40;37m";
		 return 255;
	};
	return 0;
}

CheckTool git
[ $? -eq 0 ] || exit;
CheckTool mkdir
[ $? -eq 0 ] || exit;
CheckTool rsync
[ $? -eq 0 ] || exit;

#设置ROOT_PATH变量
self_path=""
# shellcheck disable=SC2128  # ignore array expansion warning
if [ -n "${BASH_SOURCE-}" ]
then
self_path="${BASH_SOURCE}"
elif [ -n "${ZSH_VERSION-}" ]
then
self_path="${(%):-%x}"
else
echo -e "\033[41;37m不能获取工作目录\033[40;37m";
return 1
fi
# shellcheck disable=SC2169,SC2169,SC2039  # unreachable with 'dash'
if [[ "$OSTYPE" == "darwin"* ]]; then
# convert possibly relative path to absolute
script_dir="$(realpath_int "${self_path}")"
# resolve any ../ references to make the path shorter
script_dir="$(cd "${script_dir}" || exit 1; pwd)"
else
# convert to full path and get the directory name of that
script_name="$(readlink -f "${self_path}")"
script_dir="$(dirname "${script_name}")"
fi
export ROOT_PATH="${script_dir}";
echo -e  "\033[44;37m工作目录为${ROOT_PATH}\033[40;37m"

#设置rt-thread URL
if [ -z "${RT_THREAD_URL}" ]
then
	export RT_THREAD_URL=https://gitee.com/rtthread/rt-thread.git
fi
echo -e  "\033[44;37mRT_THREAD_URL为${RT_THREAD_URL}\033[40;37m"

#设置rt-thread git目录
mkdir -p ${ROOT_PATH}/rt-thread
cd ${ROOT_PATH}/rt-thread
if [ -f ${ROOT_PATH}/rt-thread/.git/config ]
then
	git remote set-url origin ${RT_THREAD_URL}
	#禁止autocrlf
	git config core.autocrlf false
else
	git init
	git remote add origin ${RT_THREAD_URL}
	#禁止autocrlf
	git config core.autocrlf false
fi

#出错自动退出
set -e

#获取当前分支
cd ${ROOT_PATH}
export GIT_BRANCH=`git branch --no-color --show-current`
if [ -z "${GIT_BRANCH}" ]
then
	echo -e  "\033[44;37m默认分支为master\033[40;37m"
	export GIT_BRANCH=master
fi
echo -e  "\033[44;37m当前分支为${GIT_BRANCH}\033[40;37m"

#获取rt-thread源码
cd ${ROOT_PATH}/rt-thread
echo -e  "\033[44;37m获取rt-thread源代码\033[40;37m"
git fetch
git checkout --force ${GIT_BRANCH}
git clean -x -f -d
git pull
echo `git rev-parse --verify HEAD` > ${ROOT_PATH}/version

#复制rt-thread源代码(除开bsp目录)
echo -e  "\033[44;37m复制rt-thread源代码(除开bsp目录)\033[40;37m"
mkdir -p  ${ROOT_PATH}/rt-thread-no-bsp
rsync -rlz --exclude=".git/" --exclude="bsp/" --delete --progress  ${ROOT_PATH}/rt-thread/ ${ROOT_PATH}/rt-thread-no-bsp/
echo -e  "\033[44;37m处理完成\033[40;37m"
