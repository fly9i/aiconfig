# my

个人 CLI 工具，用于快速同步 AI Agent 配置文件。

## 安装

从 [GitHub Releases](https://github.com/fly9i/aiconfig/releases) 下载对应平台的二进制文件，放到 `PATH` 中即可。

或手动编译：

```bash
cargo build --release
# 二进制文件在 target/release/my
```

## 使用

```bash
# 在目标目录执行，下载 AGENTS.md 并创建 CLAUDE.md 软链
my agents
```

执行流程：
1. 从 GitHub 下载 `AGENTS.md` 到当前目录
2. 如已存在 `AGENTS.md`，提示是否覆盖（输入 `y` 覆盖，其他键跳过）
3. 创建 `CLAUDE.md -> AGENTS.md` 软链（已存在则重建）

## 多平台编译

```bash
# 编译所有目标平台
make install-targets  # 首次需要安装交叉编译目标
make all
```

产出文件在 `dist/` 目录，命名格式：`my-<版本>-<目标平台>`

支持平台：
| 平台 | Target |
|------|--------|
| macOS ARM64 | `aarch64-apple-darwin` |
| Linux AMD64 | `x86_64-unknown-linux-gnu` |
| Linux ARM64 | `aarch64-unknown-linux-gnu` |
| Linux ARM32 | `armv7-unknown-linux-gnueabihf` |
| Windows AMD64 | `x86_64-pc-windows-msvc` |

## 自动发布

推送 tag 自动触发 GitHub Actions 编译并发布到 Release：

```bash
git tag v0.1.0
git push origin v0.1.0
```

## 开发

```bash
# 编译
cargo build

# 运行
cargo run -- agents

# 发布编译
cargo build --release
```
