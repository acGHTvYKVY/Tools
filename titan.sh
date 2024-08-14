#!/bin/bash
function install_node_N() {

# 读取加载身份码信息
read -p "输入你的身份码: " id

# 让用户输入想要创建的容器数量
read -p "请输入你想要创建的节点数量，单IP限制最多5个节点: " container_count

# 让用户输入起始 RPC 端口号
read -p "请输入你想要设置的起始 RPC端口 （端口号请自行设定，开启5个节点端口将会依次数字顺延，建议输入30000即可）: " start_rpc_port

# 让用户输入想要分配的空间大小
read -p "请输入你想要分配每个节点的存储空间大小（GB），单个上限2T, 网页生效较慢，等待20分钟后，网页查询即可: " storage_gb

# 让用户输入存储路径（可选）
read -p "请输入节点存储数据的宿主机路径（直接回车将使用默认路径 titan_storage_$i,依次数字顺延）: " custom_storage_path

apt update

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    echo "未检测到 Docker，正在安装..."
    apt-get install ca-certificates curl gnupg lsb-release -y
    
    # 安装 Docker 最新版本
    apt-get install docker.io -y
else
    echo "Docker 已安装。"
fi

# 拉取Docker镜像
docker pull nezha123/titan-edge

# 创建用户指定数量的容器
for ((i=1; i<=container_count; i++))
do
    current_rpc_port=$((start_rpc_port + i - 1))

    # 判断用户是否输入了自定义存储路径
    if [ -z "$custom_storage_path" ]; then
        # 用户未输入，使用默认路径
        storage_path="$PWD/titan_storage_$i"
    else
        # 用户输入了自定义路径，使用用户提供的路径
        storage_path="$custom_storage_path"
    fi

    # 确保存储路径存在
    mkdir -p "$storage_path"

    # 运行容器，并设置重启策略为always
    container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" --net=host  nezha123/titan-edge)

    echo "节点 titan$i 已经启动 容器ID $container_id"

    sleep 20

    # 修改宿主机上的config.toml文件以设置StorageGB值和端口
    docker exec $container_id bash -c "\
        sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
        sed -i 's/^[[:space:]]*#ListenAddress = \"0.0.0.0:1234\"/ListenAddress = \"0.0.0.0:$current_rpc_port\"/' /root/.titanedge/config.toml && \
        echo '容器 titan'$i' 的存储空间设置为 $storage_gb GB，RPC 端口设置为 $current_rpc_port'"

    # 重启容器以让设置生效
    docker restart $container_id

    sleep 20
    # 进入容器并执行绑定命令
    docker exec $container_id bash -c "\
        titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
    echo "节点 titan$i 已绑定."

done

echo "==============================所有节点均已设置并启动==================================="

}

function install_node_1() {

# 读取加载身份码信息
read -p "输入你的身份码: " id

# 让用户输入想要创建的容器数量
read -p "请输入你想要创建的节点的序号 " container_count

# 让用户输入起始 RPC 端口号
read -p "请输入你想要设置的起始 RPC端口 （端口号请自行设定，开启5个节点端口将会依次数字顺延，建议输入30000即可）: " start_rpc_port

# 让用户输入想要分配的空间大小
read -p "请输入你想要分配每个节点的存储空间大小（GB），单个上限2T, 网页生效较慢，等待20分钟后，网页查询即可: " storage_gb

# 让用户输入存储路径（可选）
read -p "请输入节点存储数据的宿主机路径（直接回车将使用默认路径 titan_storage_$i,依次数字顺延）: " custom_storage_path

apt update

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    echo "未检测到 Docker，正在安装..."
    apt-get install ca-certificates curl gnupg lsb-release -y
    
    # 安装 Docker 最新版本
    apt-get install docker.io -y
else
    echo "Docker 已安装。"
fi

# 拉取Docker镜像
docker pull nezha123/titan-edge

# 创建用户指定数量的容器
storage_path="$PWD/titan_storage_$container_count"
   
current_rpc_port=$start_rpc_port
# 确保存储路径存在
mkdir -p "$storage_path"

# 运行容器，并设置重启策略为always
container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" --net=host  nezha123/titan-edge)

echo "节点 titan$i 已经启动 容器ID $container_id"

sleep 30

# 修改宿主机上的config.toml文件以设置StorageGB值和端口
docker exec $container_id bash -c "\
   sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
   sed -i 's/^[[:space:]]*#ListenAddress = \"0.0.0.0:1234\"/ListenAddress = \"0.0.0.0:$current_rpc_port\"/' /root/.titanedge/config.toml && \
   echo '容器 titan'$i' 的存储空间设置为 $storage_gb GB，RPC 端口设置为 $current_rpc_port'"

# 重启容器以让设置生效
docker restart $container_id

sleep 30
# 进入容器并执行绑定命令
docker exec $container_id bash -c "\
   titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
echo "节点 titan$i 已绑定."

echo "==============================所有节点均已设置并启动==================================="
}
# 卸载节点功能
function uninstall_node() {
    echo "你确定要卸载Titan 节点程序吗？这将会删除所有相关的数据。[Y/N]"
    read -r -p "请确认: " response

    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "开始卸载节点程序..."
            for i in {1..5}; do
                sudo docker stop "titan$i" && sudo docker rm "titan$i"
            done
            for i in {1..5}; do 
                rmName="storage_titan_$i"
                rm -rf "$rmName"
            done
            echo "节点程序卸载完成。"
            ;;
        *)
            echo "取消卸载操作。"
            ;;
    esac
}


# 主菜单
function main_menu() {
    while true; do
        clear
        echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
        echo "================================================================"
        echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
        echo "节点社区 Discord 社群:https://discord.gg/GbMV5EcNWF"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装多个节点"
		echo "2. 安装单个节点"
        echo "3. 卸载节点"
        read -p "请输入选项（1-3）: " OPTION

        case $OPTION in
        1) install_node_N ;;
		2) install_node_1 ;;
        3) uninstall_node ;;
        *) echo "无效选项。" ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
    
}

# 显示主菜单
main_menu
