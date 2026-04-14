#!/usr/bin/env bash
set -euo pipefail

REPO="fly9i/aiconfig"
BINARY="my"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

detect_target() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Darwin)
            case "$arch" in
                arm64|aarch64) echo "aarch64-apple-darwin" ;;
                *) echo "unsupported: macOS $arch" >&2; exit 1 ;;
            esac
            ;;
        Linux)
            case "$arch" in
                x86_64|amd64)  echo "x86_64-unknown-linux-gnu" ;;
                aarch64|arm64) echo "aarch64-unknown-linux-gnu" ;;
                armv7l|armv7)  echo "armv7-unknown-linux-gnueabihf" ;;
                *) echo "unsupported: Linux $arch" >&2; exit 1 ;;
            esac
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "x86_64-pc-windows-msvc"
            ;;
        *)
            echo "unsupported OS: $os" >&2; exit 1
            ;;
    esac
}

latest_tag() {
    curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
        | grep -m1 '"tag_name"' \
        | sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/'
}

TMP_FILE=""
cleanup() { [[ -n "$TMP_FILE" ]] && rm -f "$TMP_FILE"; }
trap cleanup EXIT

main() {
    local target tag suffix asset url dest
    target="$(detect_target)"
    tag="$(latest_tag)"
    [[ -n "$tag" ]] || { echo "无法获取最新版本" >&2; exit 1; }

    suffix=""
    [[ "$target" == *windows* ]] && suffix=".exe"

    asset="${BINARY}-${tag}-${target}${suffix}"
    url="https://github.com/${REPO}/releases/download/${tag}/${asset}"

    echo "==> 目标架构: ${target}"
    echo "==> 最新版本: ${tag}"
    echo "==> 下载: ${url}"

    TMP_FILE="$(mktemp -t "${BINARY}.XXXXXX")"
    curl -fsSL "$url" -o "$TMP_FILE"

    mkdir -p "$INSTALL_DIR"
    dest="${INSTALL_DIR}/${BINARY}${suffix}"
    install -m 755 "$TMP_FILE" "$dest"

    echo "==> 已安装: ${dest}"
    case ":$PATH:" in
        *":${INSTALL_DIR}:"*) ;;
        *) echo "提示: ${INSTALL_DIR} 不在 PATH 中，请将其加入 shell 配置" ;;
    esac
}

main "$@"
