---
name: create-pr-mr
description: 根据当前仓库的远程地址，自动判断是 GitHub 还是 GitLab，并通过命令行创建 Pull Request 或 Merge Request。
---

# 创建 PR / MR

title 和 description 根据提交内容自动生成，使用中文。

## 第一步：判断托管平台

```bash
git remote -v
```

- 地址包含 `github.com` → **GitHub**
- 否则 → **GitLab**

## 第二步：收集变更信息

确定目标分支（用户指定 > 上游跟踪分支 > 默认分支），然后：

```bash
git log --oneline <目标分支>..HEAD
git diff <目标分支>...HEAD --stat
```

根据这些信息生成 title 和 description。

## 第三步：创建 PR 或 MR

### GitHub

```bash
gh pr create --base <目标分支> --title "<标题>" --body "<描述>"
```

### GitLab
```
git push origin dev -o merge_request.create \
  -o merge_request.target=main \
  -o merge_request.title="<标题>" \
  -o "merge_request.description=<描述>"
```
* 务必使用 git push 命令创建 merge request
* git push -o merge_request.description 的值必须为单行，不能包含换行符

## 注意事项

- 创建成功后，将返回的链接展示给用户
- GitLab 通过 git push 选项创建 MR，不依赖 glab CLI
