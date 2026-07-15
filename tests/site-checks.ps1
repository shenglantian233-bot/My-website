param([string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()

function Assert-True([bool]$Condition, [string]$Message) {
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

function Read-Utf8([string]$RelativePath) {
  $path = Join-Path $ProjectRoot $RelativePath
  Assert-True (Test-Path -LiteralPath $path) "Missing file: $RelativePath"
  if (-not (Test-Path -LiteralPath $path)) {
    return ''
  }
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

$index = Read-Utf8 'index.html'
$case = Read-Utf8 'case-yoo.html'
$content = Read-Utf8 'scripts/content.js'
$app = Read-Utf8 'scripts/app.js'
$css = (Read-Utf8 'styles/tokens.css') + (Read-Utf8 'styles/site.css') + (Read-Utf8 'styles/responsive.css')

Assert-True ($index -match '<html lang="zh-CN">') 'index.html must declare zh-CN'
Assert-True ($index -match 'styles/tokens.css') 'index.html must load tokens.css'
Assert-True ($index -match 'scripts/content.js') 'index.html must load content.js'
Assert-True ($case -match 'YOO') 'case page must identify the YOO review'
Assert-True ($content -match 'productManager') 'content.js must define productManager'
Assert-True ($content -match 'contentOperations') 'content.js must define contentOperations'
Assert-True ($app -match 'initSite') 'app.js must define initSite'
Assert-True ($css -match '--color-accent') 'CSS must define the accent token'
Assert-True ($content -match 'availableFrom') 'availability start date is required'
Assert-True ($content -match 'weeklySchedule') 'weekly availability is required'
Assert-True ($content -match 'duration') 'internship duration is required'
Assert-True ($content -match 'locationPreference') 'location preference is required'
Assert-True ($content -match '20\+') '36Kr output metric is required'
Assert-True ($content -match "'1\.6'") 'peak view metric is required'
Assert-True ($content -match '5700') 'second platform peak view metric is required'
Assert-True ($content -match 'I am a master') 'English bio is required'
Assert-True ($content -notmatch 'phone|salary|address') 'private homepage fields must not be present'
Assert-True ($content -notmatch 'followerGrowth|engagementGrowth') 'unverified growth claims must not be present'
Assert-True ($index -match '<a[^>]+class="skip-link"[^>]+href="#main-content"') 'skip link is required'
Assert-True ($index -match '<header[^>]+class="site-header"') 'semantic header is required'
Assert-True ($index -match '<nav[^>]+aria-label=') 'labelled primary nav is required'
Assert-True ($index -match 'id="experience"') 'experience section is required'
Assert-True ($index -match 'id="projects"') 'projects section is required'
Assert-True ($index -match 'id="about"') 'about section is required'
Assert-True ($index -match 'download[^>]*>') 'resume link must use download'
Assert-True ($index -match '<noscript>') 'no-script guidance is required'
Assert-True ($index -match 'data-role="productManager"') 'product role control is required'
Assert-True ($index -match 'data-role="contentOperations"') 'content role control is required'
Assert-True ($index -notmatch 'PORTFOLIO') 'PORTFOLIO must not appear'
Assert-True ($index -notmatch '®') 'trademark symbol must not appear'
Assert-True ($css -match '--color-ink:\s*#') 'ink token is required'
Assert-True ($css -match '--font-sans:') 'font stack token is required'
Assert-True ($css -match 'linear-gradient|radial-gradient') 'gradient treatment is required'
Assert-True ($css -match 'backdrop-filter') 'glass treatment is required'
Assert-True ($css -match '@media\s*\(max-width:\s*720px\)') 'mobile breakpoint is required'
Assert-True ($css -match 'prefers-reduced-motion:\s*reduce') 'reduced motion support is required'
Assert-True ($css -match ':focus-visible') 'visible keyboard focus is required'
Assert-True ($css -match '@media\s+print') 'print styles are required'
Assert-True ($app -match 'function\s+renderRole\s*\(') 'renderRole is required'
Assert-True ($app -match 'function\s+renderStaticContent\s*\(') 'renderStaticContent is required'
Assert-True ($app -match 'function\s+createProjectCard\s*\(') 'createProjectCard is required'
Assert-True ($app -match 'function\s+createExperienceCard\s*\(') 'createExperienceCard is required'
Assert-True ($app -match 'URLSearchParams') 'role query support is required'
Assert-True ($app -match 'shenglan-preferred-role') 'role preference storage is required'
Assert-True ($app -match 'IntersectionObserver') 'reveal observer is required'
Assert-True ($app -match 'aria-pressed') 'switch accessibility state is required'
Assert-True ($app -notmatch 'innerHTML\s*=') 'dynamic content must avoid innerHTML assignment'
$resumeFiles = @(Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'assets/resume') -Filter '*.pdf' -File -ErrorAction SilentlyContinue)
Assert-True ($resumeFiles.Count -eq 1) 'Exactly one downloadable resume PDF is required'
Assert-True ($content -notmatch 'assets/images/[^'']+\.png') 'content must not reference unavailable image files'
Assert-True ($case -match '3568010593721054') 'case page must link to the public 36Kr article'
Assert-True ($case -match 'id="user-task"') 'case page must explain the user task'
Assert-True ($case -match 'id="evaluation-framework"') 'case page must explain the evaluation framework'
Assert-True ($case -match 'id="findings"') 'case page must state findings'
Assert-True ($case -match 'id="recommendations"') 'case page must state recommendations'
Assert-True ($case -match 'target="_blank"') 'external source must open safely in a new tab'
Assert-True ($case -match 'rel="noopener noreferrer"') 'external source needs noopener noreferrer'
$pages = Read-Utf8 '.github/workflows/pages.yml'
$vercel = Read-Utf8 'vercel.json'
$netlify = Read-Utf8 'netlify.toml'
$readme = Read-Utf8 'README.md'
Assert-True ($pages -match 'actions/deploy-pages@v4') 'GitHub Pages deploy action is required'
Assert-True ($pages -match 'actions/upload-pages-artifact@v3') 'GitHub Pages artifact action is required'
Assert-True ($vercel -match 'cleanUrls') 'Vercel cleanUrls setting is required'
Assert-True ($netlify -match 'publish\s*=\s*"\."') 'Netlify publish directory must be project root'
Assert-True ($readme -match 'index\.html') 'README must explain direct local opening'
Assert-True ($readme -match 'scripts/content\.js') 'README must explain content editing'
Assert-True ($readme -match 'GitHub Pages') 'README must explain GitHub Pages deployment'

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host "FAIL: $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'All site checks passed.' -ForegroundColor Green
