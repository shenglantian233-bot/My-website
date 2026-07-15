# Personal Website Hero Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将个人网站首屏改为已确认的蓝白科技感方案 A：左侧完整求职信息、右侧可替换圆形照片、下方四项核心数据，并完善公开联系方式和手机端导航。

**Architecture:** 保持当前无框架静态网站结构。`scripts/content.js` 继续作为可编辑内容源，`index.html` 提供完整的默认产品经理文案以保证无脚本时仍可阅读，`scripts/app.js` 负责岗位切换和移动导航，CSS 文件分别负责全局视觉与响应式布局。

**Tech Stack:** HTML5、CSS3、原生 JavaScript、PowerShell 静态检查、GitHub Pages

## Global Constraints

- 视觉保持白色至极浅蓝渐变，以深蓝黑为主文字色、清透蓝为强调色。
- 姓名 `田盛兰 / SHENGLAN TIAN` 使用直立无衬线字体，不使用斜体、手写体或商标化处理。
- 默认岗位版本为产品经理，支持切换到内容运营。
- 公开邮箱固定为 `tianshenglan2024@163.com`，公开电话固定为 `19857116023`。
- 实习条件固定为 `2026 年 8–9 月可到岗`、`每周 4 天`、`连续 3–6 个月`、`北京优先 · 可接受远程`。
- 当前不生成真实照片，使用圆形 `ST` 占位图；未来替换照片不得影响布局。
- 核心数据固定为 `约 10 视频内容发布`、`1.6 万单篇最高浏览`、`约 10 原创文章`、`30 单篇最高转发`。
- 不改动 GitHub Pages 部署方式，不虚构粉丝增长、转化或团队成果。
- 保留可见焦点、键盘操作、减少动态效果和打印样式。

---

## File Map

- `tests/site-checks.ps1`：新增首屏结构、公开联系方式、照片占位、手机导航和数据准确性检查。
- `scripts/content.js`：保存姓名、实习状态、两套岗位文案、四项数据和公开联系方式。
- `index.html`：提供可降级的首屏双栏语义结构、移动菜单按钮、圆形照片容器及联系方式。
- `scripts/app.js`：将内容写入页面、生成邮件和电话链接、切换岗位、控制移动菜单。
- `styles/site.css`：实现桌面端蓝白双栏首屏、圆形照片、联系信息和四项数据条。
- `styles/responsive.css`：实现平板和手机端排列、菜单、触控尺寸与打印规则。
- `assets/images/profile-photo.svg`：当前 `ST` 圆形占位图；未来用同名资源替换。

---

### Task 1: Lock the approved hero requirements in tests

**Files:**
- Modify: `tests/site-checks.ps1`

**Interfaces:**
- Consumes: Existing `Read-Utf8` and `Assert-True` helpers.
- Produces: Assertions that define the required HTML hooks, contact fields, metrics, placeholder asset, mobile menu, and progressive-enhancement fallback.

- [ ] **Step 1: Replace the old privacy assertion and add failing hero assertions**

Replace:

```powershell
Assert-True ($content -notmatch 'phone|salary|address') 'private homepage fields must not be present'
```

with:

```powershell
Assert-True ($content -match "email:\s*'tianshenglan2024@163\.com'") 'public email is required'
Assert-True ($content -match "phone:\s*'19857116023'") 'public phone is required'
Assert-True ($content -notmatch 'salary|address') 'salary and address must not be present'
Assert-True ($content -match "value:\s*'约 10',\s*label:\s*'视频内容发布'") 'video output metric is required'
Assert-True ($content -match "value:\s*'1\.6',\s*suffix:\s*'万',\s*label:\s*'单篇最高浏览'") 'peak view metric is required'
Assert-True ($content -match "value:\s*'约 10',\s*label:\s*'原创文章'") 'article output metric is required'
Assert-True ($content -match "value:\s*'30',\s*label:\s*'单篇最高转发'") 'peak repost metric is required'
Assert-True ($index -match 'class="hero__layout"') 'hero must use the approved split layout'
Assert-True ($index -match 'class="hero-portrait') 'hero must contain the portrait module'
Assert-True ($index -match 'assets/images/profile-photo\.svg') 'hero must load the replaceable portrait asset'
Assert-True ($index -match 'data-email-link[^>]+href="mailto:tianshenglan2024@163\.com"') 'email fallback link is required'
Assert-True ($index -match 'data-phone-link[^>]+href="tel:19857116023"') 'phone fallback link is required'
Assert-True ($index -match 'data-nav-toggle') 'mobile navigation toggle is required'
Assert-True ($index -match '从复杂信息中，提炼清晰答案。') 'default hero copy must work without JavaScript'
Assert-True ($app -match 'function\s+initNavigation\s*\(') 'mobile navigation behavior is required'
Assert-True ($app -match 'data-phone-link') 'phone link rendering is required'
```

After `$content` is read, also read the portrait file:

```powershell
$portrait = Read-Utf8 'assets/images/profile-photo.svg'
Assert-True ($portrait -match '>ST<') 'portrait placeholder must identify ST'
```

- [ ] **Step 2: Run the checks and confirm the new requirements fail**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/site-checks.ps1
```

Expected: FAIL messages for the split layout, portrait asset, email, phone, metrics, mobile navigation, and no-script hero copy.

- [ ] **Step 3: Commit the failing specification tests**

```powershell
git add tests/site-checks.ps1
git commit -m "test: define hero redesign requirements"
```

---

### Task 2: Add truthful content data and no-script hero structure

**Files:**
- Create: `assets/images/profile-photo.svg`
- Modify: `scripts/content.js`
- Modify: `index.html`
- Test: `tests/site-checks.ps1`

**Interfaces:**
- Consumes: Existing `window.SITE_CONTENT`, `[data-field]`, `[data-list]`, and `[data-role]` conventions.
- Produces: `identity.heroStatus`, `contact.email`, `contact.phone`, four approved metrics, `.hero__layout`, `.hero-portrait`, `[data-email-link]`, `[data-phone-link]`, and `[data-nav-toggle]`.

- [ ] **Step 1: Replace the identity, metrics, and contact values in `scripts/content.js`**

Use these exact objects while preserving all unrelated projects, experiences, education, and biographies:

```javascript
identity: {
  name: '田盛兰',
  englishName: 'SHENGLAN TIAN',
  status: '北京林业大学硕士在读 · 预计 2028 年毕业',
  heroStatus: '2026 实习求职 · 北京优先 / 可远程'
},
metrics: [
  { value: '约 10', label: '视频内容发布' },
  { value: '1.6', suffix: '万', label: '单篇最高浏览' },
  { value: '约 10', label: '原创文章' },
  { value: '30', label: '单篇最高转发' }
],
contact: {
  email: 'tianshenglan2024@163.com',
  phone: '19857116023',
  note: '北京优先，可接受远程；2026 年 8–9 月可到岗，每周 4 天，可连续实习 3–6 个月。',
  resume: 'assets/resume/田盛兰-个人简历.pdf'
}
```

Set the default product-manager headline to:

```javascript
headline: '从复杂信息中，提炼清晰答案。'
```

- [ ] **Step 2: Create the replaceable `ST` portrait asset**

Create `assets/images/profile-photo.svg` with:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800" role="img" aria-labelledby="title desc">
  <title id="title">田盛兰照片占位图</title>
  <desc id="desc">蓝白渐变圆形背景与姓名缩写 ST，之后可替换为本人照片。</desc>
  <defs>
    <radialGradient id="bg" cx="35%" cy="25%" r="85%">
      <stop offset="0" stop-color="#ffffff"/>
      <stop offset="0.48" stop-color="#dff3ff"/>
      <stop offset="1" stop-color="#8fbaff"/>
    </radialGradient>
  </defs>
  <circle cx="400" cy="400" r="400" fill="url(#bg)"/>
  <circle cx="400" cy="400" r="330" fill="none" stroke="#ffffff" stroke-opacity=".75" stroke-width="2"/>
  <text x="400" y="435" text-anchor="middle" fill="#173a78" font-family="Arial, sans-serif" font-size="150" font-weight="700" letter-spacing="12">ST</text>
</svg>
```

- [ ] **Step 3: Replace the header and hero section in `index.html`**

Use a labelled menu button, a normal navigation container, and the following hero content. Keep the rest of the page unchanged.

```html
<header class="site-header">
  <a class="identity-mark" href="#hero" aria-label="返回首页">
    <span>田盛兰</span>
    <span>SHENGLAN TIAN</span>
  </a>
  <button class="nav-toggle" type="button" data-nav-toggle aria-expanded="false" aria-controls="primary-nav">
    <span class="sr-only">打开导航菜单</span>
    <span aria-hidden="true"></span><span aria-hidden="true"></span>
  </button>
  <nav id="primary-nav" data-primary-nav aria-label="主导航">
    <a href="#experience">经历</a>
    <a href="#projects">项目与内容</a>
    <a href="#about">关于我</a>
  </nav>
  <a class="button button--small header-download" data-resume-link href="assets/resume/田盛兰-个人简历.pdf" download>下载简历</a>
</header>

<section class="hero" id="hero" aria-labelledby="hero-title">
  <div class="hero__light hero__light--one" aria-hidden="true"></div>
  <div class="hero__light hero__light--two" aria-hidden="true"></div>
  <div class="hero__layout">
    <div class="hero__content">
      <p class="hero__status" data-field="heroStatus">2026 实习求职 · 北京优先 / 可远程</p>
      <p class="hero__name">田盛兰 <span>SHENGLAN TIAN</span></p>
      <div class="role-switch" role="group" aria-label="查看岗位版本">
        <button type="button" data-role="productManager" aria-pressed="true">产品经理</button>
        <button type="button" data-role="contentOperations" aria-pressed="false">内容运营</button>
      </div>
      <p class="eyebrow" data-field="eyebrow">PRODUCT THINKING · AI PRACTICE</p>
      <h1 id="hero-title" data-field="headline">从复杂信息中，提炼清晰答案。</h1>
      <p class="hero__summary" data-field="summary">关注 AI 产品与真实用户体验，用结构化分析发现问题，用内容能力清晰表达价值。</p>
      <div class="tag-row" data-list="tags"><span>产品体验</span><span>用户需求</span><span>AI 测评</span></div>
      <ul class="availability" data-list="availability" aria-label="实习条件">
        <li>2026 年 8–9 月可到岗</li><li>每周 4 天</li><li>连续 3–6 个月</li><li>北京优先 · 可接受远程</li>
      </ul>
      <address class="hero-contact">
        <a data-email-link href="mailto:tianshenglan2024@163.com">tianshenglan2024@163.com</a>
        <a data-phone-link href="tel:19857116023">19857116023</a>
      </address>
      <div class="hero__actions">
        <a class="button" href="#projects">查看项目 <span aria-hidden="true">↘</span></a>
        <a class="button button--secondary" data-resume-link href="assets/resume/田盛兰-个人简历.pdf" download>下载简历 <span aria-hidden="true">↓</span></a>
      </div>
    </div>
    <figure class="hero-portrait">
      <div class="hero-portrait__orbit" aria-hidden="true"></div>
      <img src="assets/images/profile-photo.svg" alt="田盛兰照片占位图，当前显示姓名缩写 ST" width="800" height="800">
      <figcaption><span aria-hidden="true"></span> AVAILABLE FOR INTERNSHIP</figcaption>
    </figure>
  </div>
  <a class="scroll-cue" href="#metrics"><span>向下探索</span><span aria-hidden="true">↓</span></a>
</section>
```

- [ ] **Step 4: Run the checks and record the remaining expected failures**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/site-checks.ps1
```

Expected: Contact, metrics, split layout, portrait, and fallback-copy assertions pass; only `initNavigation` and any new CSS-specific assertions remain failing.

- [ ] **Step 5: Commit the content and semantic structure**

```powershell
git add index.html scripts/content.js assets/images/profile-photo.svg tests/site-checks.ps1
git commit -m "feat: add split hero content and portrait"
```

---

### Task 3: Render contact data and mobile navigation behavior

**Files:**
- Modify: `scripts/app.js`
- Test: `tests/site-checks.ps1`

**Interfaces:**
- Consumes: `content.identity.heroStatus`, `content.contact.email`, `content.contact.phone`, `[data-nav-toggle]`, and `[data-primary-nav]`.
- Produces: `renderStaticContent()` contact binding and `initNavigation(): void`.

- [ ] **Step 1: Extend `renderStaticContent()` with identity and contact binding**

Add after the existing about fields:

```javascript
document.querySelector('[data-field="heroStatus"]').textContent = content.identity.heroStatus;

document.querySelectorAll('[data-email-link]').forEach(link => {
  link.href = `mailto:${content.contact.email}`;
  if (link.matches('.text-link')) link.hidden = false;
});

document.querySelectorAll('[data-phone-link]').forEach(link => {
  link.href = `tel:${content.contact.phone}`;
  link.textContent = content.contact.phone;
});
```

Remove the old single-email conditional block so all email links use the same source.

- [ ] **Step 2: Add `initNavigation()` before `initSite()`**

```javascript
function initNavigation() {
  const toggle = document.querySelector('[data-nav-toggle]');
  const nav = document.querySelector('[data-primary-nav]');
  if (!toggle || !nav) return;

  const closeMenu = () => {
    toggle.setAttribute('aria-expanded', 'false');
    document.body.classList.remove('nav-open');
  };

  toggle.addEventListener('click', () => {
    const willOpen = toggle.getAttribute('aria-expanded') !== 'true';
    toggle.setAttribute('aria-expanded', String(willOpen));
    document.body.classList.toggle('nav-open', willOpen);
  });

  nav.querySelectorAll('a').forEach(link => link.addEventListener('click', closeMenu));
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape') {
      closeMenu();
      toggle.focus();
    }
  });
}
```

Call it at the beginning of `initSite()`:

```javascript
function initSite() {
  initNavigation();
  renderStaticContent();
  // keep the existing role initialization below
}
```

- [ ] **Step 3: Run checks and confirm JavaScript requirements pass**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/site-checks.ps1
```

Expected: `initNavigation`, email, and phone assertions pass. Any remaining failures should be CSS-specific only.

- [ ] **Step 4: Commit the interaction behavior**

```powershell
git add scripts/app.js tests/site-checks.ps1
git commit -m "feat: add contact links and mobile navigation"
```

---

### Task 4: Build the approved desktop and mobile visual layout

**Files:**
- Modify: `styles/site.css`
- Modify: `styles/responsive.css`
- Test: `tests/site-checks.ps1`

**Interfaces:**
- Consumes: `.hero__layout`, `.hero__content`, `.hero-portrait`, `.hero-contact`, `.nav-toggle`, `.metrics__grid`.
- Produces: 60/40 desktop composition, circular portrait treatment, two-column mobile stack, mobile menu, touch-safe links, and reduced-motion behavior.

- [ ] **Step 1: Add CSS contract assertions**

Append to `tests/site-checks.ps1`:

```powershell
Assert-True ($css -match '\.hero__layout\s*\{[^}]*grid-template-columns') 'desktop hero grid is required'
Assert-True ($css -match '\.hero-portrait\s+img\s*\{[^}]*border-radius:\s*50%') 'portrait must be circular'
Assert-True ($css -match '\.hero-contact') 'hero contact styling is required'
Assert-True ($css -match '\.nav-toggle') 'mobile menu styling is required'
Assert-True ($css -match 'body\.nav-open') 'open navigation state is required'
Assert-True ($css -match '@media\s*\(max-width:\s*720px\)[\s\S]*\.hero__layout\s*\{[^}]*grid-template-columns:\s*1fr') 'mobile hero must stack'
Assert-True ($css -match '@media\s*\(max-width:\s*720px\)[\s\S]*\.metrics__grid\s*\{[^}]*repeat\(2,\s*1fr\)') 'mobile metrics must use two columns'
```

- [ ] **Step 2: Run checks and confirm CSS contract fails**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/site-checks.ps1
```

Expected: FAIL for desktop hero grid, circular portrait, contact styling, nav menu state, stacked mobile hero, and two-column mobile metrics.

- [ ] **Step 3: Replace the existing header and hero rules in `styles/site.css`**

Use the following selectors and values, retaining unrelated project, experience, education, about, contact, case-page, focus, and print styles:

```css
.site-header { position: sticky; top: 0; z-index: 20; display: grid; grid-template-columns: 1fr auto auto; align-items: center; gap: 2rem; width: 100%; min-height: 76px; padding: 0 clamp(1.25rem, 4vw, 4.5rem); border-bottom: 1px solid rgba(114, 151, 207, 0.16); background: rgba(248, 252, 255, 0.82); backdrop-filter: blur(18px); }
.site-header nav { display: flex; gap: clamp(1.25rem, 3vw, 2.75rem); color: var(--color-ink-soft); font-size: 0.9rem; }
.nav-toggle { display: none; width: 44px; height: 44px; padding: 11px; border: 1px solid var(--color-line); border-radius: 50%; background: rgba(255,255,255,.72); }
.nav-toggle > span:not(.sr-only) { display: block; width: 100%; height: 1px; margin: 6px 0; background: var(--color-ink); transition: transform .25s var(--ease); }
.sr-only { position: absolute; width: 1px; height: 1px; padding: 0; overflow: hidden; clip: rect(0,0,0,0); white-space: nowrap; border: 0; }

.hero { position: relative; min-height: calc(100svh - 76px); padding: clamp(4.5rem, 8vw, 7.5rem) max(4vw, calc((100vw - var(--content)) / 2)) 5rem; overflow: hidden; }
.hero__layout { position: relative; z-index: 3; display: grid; grid-template-columns: minmax(0, 3fr) minmax(280px, 2fr); align-items: center; gap: clamp(2.5rem, 7vw, 7rem); max-width: var(--content); margin: 0 auto; }
.hero__content { width: 100%; }
.hero__status { display: inline-flex; margin: 0 0 1rem; padding: .48rem .8rem; border: 1px solid rgba(36,107,254,.18); border-radius: var(--radius-pill); background: rgba(255,255,255,.62); color: var(--color-accent-deep); font-size: .76rem; font-weight: 700; letter-spacing: .04em; }
.hero__name { margin: 0 0 1.2rem; color: var(--color-ink); font-size: clamp(1.45rem, 2.2vw, 2.15rem); font-weight: 760; letter-spacing: -.035em; }
.hero__name span { display: block; margin-top: .22rem; color: var(--color-muted); font-size: .68em; font-weight: 620; letter-spacing: .12em; }
.hero h1 { max-width: 12ch; margin: 0 0 1.35rem; font-size: clamp(3.1rem, 5.5vw, 5.8rem); font-weight: 780; letter-spacing: -.07em; line-height: .98; }
.hero__summary { max-width: 640px; margin-bottom: 1.35rem; color: var(--color-ink-soft); font-size: clamp(1rem, 1.35vw, 1.2rem); line-height: 1.75; }
.role-switch { margin-bottom: 1.25rem; }
.hero-contact { display: flex; flex-wrap: wrap; gap: .7rem 1.4rem; margin-top: 1.2rem; font-style: normal; }
.hero-contact a { color: var(--color-ink-soft); font-size: .88rem; text-decoration: underline; text-decoration-color: rgba(36,107,254,.28); text-underline-offset: .3rem; overflow-wrap: anywhere; }
.hero-contact a:hover { color: var(--color-accent-deep); }
.button--secondary { border: 1px solid rgba(36,107,254,.22); background: rgba(255,255,255,.7); box-shadow: none; color: var(--color-ink); }
.button--secondary:hover { background: #fff; color: var(--color-accent-deep); }

.hero-portrait { position: relative; display: grid; place-items: center; width: min(100%, 460px); margin: 0 auto; aspect-ratio: 1; }
.hero-portrait img { position: relative; z-index: 2; width: 82%; height: 82%; border: 10px solid rgba(255,255,255,.68); border-radius: 50%; box-shadow: 0 30px 90px rgba(38,92,180,.2); object-fit: cover; }
.hero-portrait__orbit { position: absolute; inset: 2%; border: 1px solid rgba(36,107,254,.22); border-radius: 50%; animation: portrait-orbit 18s linear infinite; }
.hero-portrait__orbit::before, .hero-portrait__orbit::after { position: absolute; width: 12px; height: 12px; border-radius: 50%; content: ""; background: var(--color-accent); box-shadow: 0 0 24px rgba(36,107,254,.55); }
.hero-portrait__orbit::before { top: 10%; left: 18%; }
.hero-portrait__orbit::after { right: 7%; bottom: 25%; width: 8px; height: 8px; background: #6bd7ff; }
.hero-portrait figcaption { position: absolute; right: 0; bottom: 12%; z-index: 3; display: flex; align-items: center; gap: .5rem; padding: .55rem .8rem; border: 1px solid rgba(36,107,254,.14); border-radius: var(--radius-pill); background: rgba(255,255,255,.82); box-shadow: 0 14px 35px rgba(38,92,180,.12); backdrop-filter: blur(12px); color: var(--color-ink-soft); font-size: .67rem; font-weight: 700; letter-spacing: .08em; }
.hero-portrait figcaption span { width: 7px; height: 7px; border-radius: 50%; background: #30b877; box-shadow: 0 0 0 5px rgba(48,184,119,.12); }
@keyframes portrait-orbit { to { transform: rotate(360deg); } }

.metrics { padding-top: 0; padding-bottom: 4rem; }
.metrics__grid { display: grid; grid-template-columns: repeat(4, 1fr); border-top: 1px solid var(--color-line); border-bottom: 1px solid var(--color-line); }
```

- [ ] **Step 4: Replace responsive hero rules in `styles/responsive.css`**

```css
@media (max-width: 960px) {
  .site-header { grid-template-columns: 1fr auto auto; gap: 1rem; }
  .hero__layout { grid-template-columns: minmax(0, 1.2fr) minmax(240px, .8fr); gap: 2rem; }
  .hero-portrait { max-width: 360px; }
  .metrics__grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 720px) {
  .site-header { grid-template-columns: 1fr auto auto; min-height: 66px; padding: 0 1rem; }
  .nav-toggle { display: block; }
  .site-header nav { position: absolute; top: calc(100% + 1px); right: 1rem; left: 1rem; display: grid; gap: 0; padding: .5rem; border: 1px solid var(--color-line); border-radius: 18px; background: rgba(255,255,255,.96); box-shadow: 0 18px 50px rgba(34,69,126,.15); opacity: 0; pointer-events: none; transform: translateY(-8px); transition: .22s var(--ease); }
  .site-header nav a { min-height: 44px; padding: .8rem 1rem; }
  body.nav-open .site-header nav { opacity: 1; pointer-events: auto; transform: translateY(0); }
  body.nav-open .nav-toggle > span:not(.sr-only):nth-child(2) { transform: translateY(3.5px) rotate(45deg); }
  body.nav-open .nav-toggle > span:not(.sr-only):nth-child(3) { transform: translateY(-3.5px) rotate(-45deg); }
  .header-download { padding-inline: .8rem; }
  .hero { min-height: auto; padding: 4.5rem 1.25rem 4rem; }
  .hero__layout { grid-template-columns: 1fr; gap: 2.5rem; }
  .hero__content { display: contents; }
  .hero__status { grid-row: 1; }
  .hero__name { grid-row: 2; }
  .role-switch { grid-row: 3; }
  .hero .eyebrow { grid-row: 4; }
  .hero h1 { grid-row: 5; }
  .hero__summary { grid-row: 6; }
  .tag-row { grid-row: 7; }
  .hero-portrait { grid-row: 8; width: min(86vw, 360px); }
  .availability { grid-row: 9; }
  .hero-contact { grid-row: 10; }
  .hero__actions { grid-row: 11; align-items: stretch; flex-direction: column; gap: .7rem; }
  .hero__status, .hero__name, .role-switch, .hero .eyebrow, .hero h1, .hero__summary, .tag-row, .hero-portrait, .availability, .hero-contact, .hero__actions { grid-column: 1; }
  .hero__actions .button { width: 100%; }
  .hero h1 { font-size: clamp(2.9rem, 13vw, 4.65rem); }
  .hero-contact { flex-direction: column; }
  .metrics__grid { grid-template-columns: repeat(2, 1fr); }
}

@media (prefers-reduced-motion: reduce) {
  .hero-portrait__orbit { animation: none; }
}

@media print {
  .nav-toggle, .role-switch, .hero__actions, .scroll-cue, .contact__actions { display: none !important; }
}
```

- [ ] **Step 5: Run checks and confirm the full automated suite passes**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/site-checks.ps1
```

Expected: `All site checks passed.`

- [ ] **Step 6: Commit the approved visual layout**

```powershell
git add styles/site.css styles/responsive.css tests/site-checks.ps1
git commit -m "feat: style responsive split hero"
```

---

### Task 5: Visual QA, regression check, and repository handoff

**Files:**
- Modify only if a verified defect is found: `index.html`, `scripts/content.js`, `scripts/app.js`, `styles/site.css`, `styles/responsive.css`

**Interfaces:**
- Consumes: Completed static site and Git history from Tasks 1–4.
- Produces: A clean repository whose local `main` contains the verified hero redesign and is ready for GitHub Desktop push.

- [ ] **Step 1: Run the automated suite from the repository root**

```powershell
powershell -ExecutionPolicy Bypass -File tests/site-checks.ps1
```

Expected: `All site checks passed.`

- [ ] **Step 2: Open `index.html` locally and inspect desktop width**

Verify all of the following at approximately 1440 px width:

```text
姓名、双岗位切换、标题、简介、实习标签、邮箱、电话和两个按钮完整可见。
圆形 ST 占位图位于右侧，不压住文字。
四项数据在首屏下方横向排列。
岗位切换后项目和经历排序仍正常。
下载简历、邮箱和电话链接目标正确。
```

- [ ] **Step 3: Inspect tablet and mobile widths**

Verify at approximately 768 px and 390 px:

```text
720 px 以下首屏变为单列，照片位于介绍之后、实习与联系方式之前。
导航按钮可以打开菜单，点击链接或按 Escape 可以关闭菜单。
四项数据为两列，没有横向滚动。
邮箱不会溢出，电话可点击，两个主操作按钮容易触控。
```

- [ ] **Step 4: Verify reduced motion and keyboard use**

```text
Tab 键可依次聚焦导航、岗位按钮、邮箱、电话和首屏按钮。
焦点轮廓清晰可见。
开启系统减少动态效果后，照片圆环停止旋转，内容仍然可见。
```

- [ ] **Step 5: Confirm repository status and commit any verified QA fix**

```powershell
git status --short
git log -5 --oneline
```

Expected: no uncommitted changes. If QA required a fix, rerun the full test suite and commit only the verified files with:

```powershell
git add index.html scripts/content.js scripts/app.js styles/site.css styles/responsive.css tests/site-checks.ps1
git commit -m "fix: polish hero responsive layout"
```

- [ ] **Step 6: Push through GitHub Desktop and verify deployment**

```text
在 GitHub Desktop 中确认 Current repository 为 My-website、Current branch 为 main。
点击 Push origin。
等待 GitHub Pages 自动部署后，打开 https://shenglantian233-bot.github.io/My-website/。
确认线上首屏与本地版本一致。
```
