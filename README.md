# 田盛兰个人求职网站

面向产品经理与内容运营实习岗位的响应式个人网站。网站为纯静态项目，不需要安装 Node.js 或数据库，可以直接打开，也可以发布到 GitHub Pages、Vercel 或 Netlify。

## 本地查看

双击项目根目录中的 `index.html` 即可浏览首页。`case-yoo.html` 是 YOO AI 简历测评的公开案例页。

首页支持两种岗位版本：

- 产品经理：在网址后加入 `?role=product`
- 内容运营：在网址后加入 `?role=content`

例如：`index.html?role=content`。

## 修改内容

主要文字集中在 `scripts/content.js`，不需要进入 HTML 调整岗位文案。

- `roleProfiles`：岗位标题、简介、能力标签、项目顺序、经历顺序和技能。
- `projects`：公开项目和文章。
- `experiences`：经历与成果描述。
- `about`：中英文个人简介。
- `contact.email`：公开联系邮箱；为空时网页不会显示邮件按钮。
- `contact.resume`：下载简历的文件路径。

替换简历时，可以直接覆盖 `assets/resume/田盛兰-个人简历.pdf`；如果修改文件名，需要同步修改 `contact.resume`。

## 自动检查

在项目目录中运行：

```powershell
powershell -ExecutionPolicy Bypass -File tests/site-checks.ps1
```

出现 `All site checks passed.` 表示页面结构、内容配置、隐私规则、案例链接和部署文件通过基础检查。

## 发布到 GitHub Pages

项目已包含 `.github/workflows/pages.yml`。把代码推送至 GitHub 仓库的 `main` 分支后：

1. 打开仓库的 **Settings → Pages**。
2. 在 **Build and deployment** 中把 Source 选择为 **GitHub Actions**。
3. 打开仓库的 **Actions** 页面，等待 `Deploy static site to Pages` 完成。
4. 完成后，Pages 页面会显示公开 HTTPS 地址。

## 发布到 Vercel 或 Netlify

两个平台都可以直接导入同一 GitHub 仓库。

- 不需要 Build Command。
- Vercel 使用项目根目录。
- Netlify 的 Publish Directory 为 `.`。

## 公开素材边界

- 可以公开：本人独立完成的 36氪 AI 测评摘要和链接、公开经历与汇总数据、教育背景、公开简历。
- 不公开：中科闻歌的视频、文章、X 短帖、活动照片、后台截图、内部数据和公司素材。
- 当前微信临时目录中的公开截图已失效，因此首版使用抽象编号视觉，不引用缺失文件；重新获得截图后可补入 `assets/images`。
- 发布前建议补充最终公开联系邮箱。
