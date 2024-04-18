#!/bin/bash
# 使用bash作为脚本解释器

version=ics2019
# 设置变量version，用于指定要克隆的代码版本

log=""
# 初始化一个空字符串log，用于记录初始化日志

function init() {
  # 定义名为init的函数，用于初始化项目

  if [ -d $1 ]; then
    # 如果参数$1指定的目录存在
    echo "$1 is already initialized, exiting..."
    # 输出提示信息，表示该目录已经初始化，然后退出函数
    return
  fi

  while [ ! -d $1 ]; do
    # 当参数$1指定的目录不存在时，执行以下操作
    git clone -b $version https://github.com/NJU-ProjectN/$1.git
    # 从GitHub上克隆指定分支的代码到指定目录
  done

  log="$log$1 `cd $1 && git log --oneline --no-abbrev-commit -n1`"$'\n'
  # 记录克隆的项目及其最新提交的简短日志信息，并添加到log变量中

  rm -rf $1/.git
  # 移除克隆下来的项目中的.git目录，以避免冲突

  if [ $2 ] ; then
    # 如果提供了第二个参数
    sed -i -e "/^export $2=.*/d" ~/.bashrc
    # 使用sed命令删除~/.bashrc文件中已经存在的以"export $2="开头的行
    echo "export $2=`readlink -e $1`" >> ~/.bashrc
    # 在~/.bashrc文件末尾添加一行，设置环境变量$2为参数$1指定目录的绝对路径
  fi
}

read -r -p "Are you sure to initialize everything? [y/n] " input
# 提示用户是否确定初始化所有内容，并将用户输入保存到变量input中

case $input in
  [yY])
    # 如果用户输入为y或Y，则执行以下操作
    init nemu NEMU_HOME
    # 初始化名为nemu的项目，并将其路径设置为NEMU_HOME环境变量
    init nexus-am AM_HOME
    # 初始化名为nexus-am的项目，并将其路径设置为AM_HOME环境变量
    init nanos-lite
    # 初始化名为nanos-lite的项目
    init navy-apps NAVY_HOME
    # 初始化名为navy-apps的项目，并将其路径设置为NAVY_HOME环境变量

    git add -A
    # 添加所有修改的文件到Git暂存区
    git commit -am "$version initialized"$'\n\n'"$log"
    # 提交修改，并添加初始化版本信息和日志信息作为提交信息

    echo "Initialization finishes!"
    echo "By default this script will add environment variables into ~/.bashrc."
    echo "After that, please run 'source ~/.bashrc' to let these variables take effect."
    echo "If you use shell other than bash, please add these environment variables manually."
    # 输出初始化完成的提示信息，并说明脚本默认会将环境变量添加到~/.bashrc文件中
    # 提示用户需要执行source ~/.bashrc命令使环境变量生效
    # 如果用户使用的是除bash之外的shell，则需要手动添加环境变量
    ;;

  [nN])
    # 如果用户输入为n或N，则什么都不做
    ;;

  *)
    # 如果用户输入不是y/Y也不是n/N，则执行以下操作
    echo "Invalid input..."
    # 输出无效输入的提示信息
    ;;
esac

