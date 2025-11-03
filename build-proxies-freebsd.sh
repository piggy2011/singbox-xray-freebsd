#!/usr/bin/env bash
# ===============================================================
# build-proxies-freebsd.sh
# FreeBSD 14.1 amd64 交叉编译版 sing-box 与 Xray-core 构建脚本
# - 运行环境：GitHub Actions (Ubuntu)
# - 输出：FreeBSD 可执行二进制（无依赖）
# - 作者：Connie 定制版 (2025)
# ===============================================================

set -euo pipefail

# ======== 配置区 ========
WORKDIR="${HOME}/build-proxies-freebsd"
OUTPUT_DIR="${WORKDIR}/output"
SINGBOX_REPO="https://github.com/SagerNet/sing-box.git"
XRAY_REPO="https://github.com/XTLS/Xray-core.git"
SINGBOX_TAG="${SINGBOX_TAG:-v1.12.12}"
XRAY_TAG="${XRAY_TAG:-v25.10.15}"
GO_VERSION="${GO_VERSION:-1.23.1}"
# ========================

echo "🚀 Start building sing-box & xray for FreeBSD 14.1 amd64"
mkdir -p "${WORKDIR}" "${OUTPUT_DIR}"
cd "${WORKDIR}"

# ---------- 安装 Go ----------
echo "⬇️ Installing Go ${GO_VERSION} ..."
wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go${GO_VERSION}.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.tar.gz
export PATH="/usr/local/go/bin:${PATH}"
echo "✅ Current Go version: $(go version)"
rm /tmp/go${GO_VERSION}.tar.gz

# ===============================================================
# 1️⃣ 编译 sing-box
# ===============================================================
echo "🏗️  Building sing-box (${SINGBOX_TAG}) ..."
cd "${WORKDIR}"
if [[ -d sing-box ]]; then
  cd sing-box
  git fetch --all --tags
else
  git clone --depth=1 --branch "${SINGBOX_TAG}" "${SINGBOX_REPO}" sing-box
  cd sing-box
fi

# FreeBSD amd64 构建
GOOS=freebsd GOARCH=amd64 CGO_ENABLED=0 go build -trimpath \
  -tags  "with_quic with_utls with_dhcp with_clash_api with_gvisor" \
  -ldflags="-s -w -buildid= -X github.com/sagernet/sing-box/constant.Version=${SINGBOX_TAG}" \
  -o "${OUTPUT_DIR}/sing-box-freebsd-amd64" ./cmd/sing-box

echo "✅ sing-box build complete: ${OUTPUT_DIR}/sing-box-freebsd-amd64"

# ===============================================================
# 2️⃣ 编译 Xray-core
# ===============================================================
echo "🏗️  Building Xray-core (${XRAY_TAG}) ..."
cd "${WORKDIR}"
if [[ -d Xray-core ]]; then
  cd Xray-core
  git fetch --all --tags
else
  git clone --depth=1 --branch "${XRAY_TAG}" "${XRAY_REPO}" Xray-core
  cd Xray-core
fi

GOOS=freebsd GOARCH=amd64 CGO_ENABLED=0 go build -trimpath \
  -ldflags="-X github.com/xtls/xray-core/core.build=manual -s -w -buildid=" \
  -o "${OUTPUT_DIR}/xray-freebsd-amd64" ./main

echo "✅ xray-core build complete: ${OUTPUT_DIR}/xray-freebsd-amd64"

# ===============================================================
# 3️⃣ 打印结果信息
# ===============================================================
echo "🎉 Build finished. Output files:"
ls -lh "${OUTPUT_DIR}"

echo "---------------------------------------------------------------"
echo "✅ sing-box (FreeBSD): ${OUTPUT_DIR}/sing-box-freebsd-amd64"
echo "✅ xray-core (FreeBSD): ${OUTPUT_DIR}/xray-freebsd-amd64"
echo "---------------------------------------------------------------"
echo "🎯 Ready for upload to artifact or release."
