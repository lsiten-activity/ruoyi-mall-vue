#!/bin/sh

# 设置默认值为 "test" 的仓库名
DRONE_REPO_NAME="${DRONE_REPO_NAME:-test}"
LOG_PATH="${LOG_PATH:-/volume2/docker/drone/server-01/drone-runner-docker/log-cache/${DRONE_REPO_NAME}}"

# 定义应用组名
group_name="drone-${DRONE_REPO_NAME}"

# 定义应用名称
app_name="drone-node-service-${DRONE_REPO_NAME}"

# 定义应用版本
app_version="latest"

# 停止并删除同名容器
docker rm -f "${app_name}" &>/dev/null

# 删除同名镜像
docker rmi "${group_name}/${app_name}:${app_version}" &>/dev/null

# 构建 Docker 镜像
docker build -t "${group_name}/${app_name}:${app_version}" .

# 获取端口号，默认为 8000
port="${APP_PORT:-8000}"

# 运行容器
docker run -d \
  --name "${app_name}" \
  -p "${port}:8000" \
  -e TZ="Asia/Shanghai" \
  -v "${LOG_PATH}:/var/log/nginx" \
  -v /etc/localtime:/etc/localtime:ro \
  "${group_name}/${app_name}:${app_version}"

# 输出应用启动信息
echo "Started ${app_name} on port ${port}"