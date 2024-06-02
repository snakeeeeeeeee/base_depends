#!/bin/bash


function install_base() {
	echo "正在升级安装基础依赖..."
	# 升级所有已安装的包
	sudo apt update && sudo apt upgrade -y
	# 安装基本组件
	sudo apt install pkg-config curl build-essential libssl-dev libclang-dev ufw docker-compose-plugin git wget htop tmux jq make lz4 gcc unzip liblz4-tool -y
}


function install_docker() {
    # 检查 Docker 是否已安装
    if ! command -v docker &> /dev/null; then
        # 如果 Docker 未安装，则进行安装
        echo "未检测到 Docker，正在安装..."
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release

        # 添加 Docker 官方 GPG 密钥
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # 设置 Docker 仓库
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # 授权 Docker 文件
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # 更新 apt 包索引
        sudo apt-get update

        # 安装 Docker Engine，CLI 和 Containerd
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    else
        echo "Docker 已安装。"
    fi

    # 检查 docker-compose 是否已安装
    if ! command -v docker-compose &> /dev/null; then
        echo "未检测到 docker-compose，正在安装..."

        # 安装 docker-compose
        sudo apt-get install -y docker-compose
    else
        echo "docker-compose 已安装。"
    fi
}


# 检查并安装 Node.js 和 npm
function install_nodejs_and_npm() {
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装"
    else
        echo "npm 未安装，正在安装..."
        sudo apt-get install -y npm
    fi
}

# 检查并安装 PM2
function install_pm2() {
    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}

# 检查Go环境
function check_go_installation() {
    if command -v go > /dev/null 2>&1; then
        echo "Go 环境已安装"
        return 0 
    else
        echo "Go 环境未安装，正在安装..."
        return 1 
    fi
}



function install_go() {
	# 安装 Go
    if ! check_go_installation; then
        sudo rm -rf /usr/local/go
        curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
        source $HOME/.bash_profile
        go version
    fi
}





function install_all_depends() {
	# 基础升级
	install_base
	# docker
	install_docker
	# node和npm
	install_nodejs_and_npm
	# pm2
	install_pm2
	# go
	install_go
}


# 主菜单
function main_menu() {
    clear
    echo "=====================安装及常规修改功能========================="
    echo "请选择要执行的操作:"
    echo "1. 安装全部依赖"
    read -p "请输入选项: " OPTION

    case $OPTION in
    1) install_all_depends ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu