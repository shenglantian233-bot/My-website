const content = window.SITE_CONTENT;
const roleAliases = { product: 'productManager', content: 'contentOperations' };

function mapById(items) {
  return new Map(items.map(item => [item.id, item]));
}

function makeElement(tagName, className, text) {
  const node = document.createElement(tagName);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function getStoredRole() {
  try {
    return localStorage.getItem('shenglan-preferred-role');
  } catch (_) {
    return null;
  }
}

function storeRole(roleKey) {
  try {
    localStorage.setItem('shenglan-preferred-role', roleKey);
  } catch (_) {
    // The page still works if a browser blocks storage for local files.
  }
}

function createProjectCard(project) {
  const article = makeElement('article', 'project-card reveal');
  const visual = makeElement('div', project.image ? 'project-card__visual' : 'project-card__visual project-card__visual--abstract');

  if (project.image) {
    const image = document.createElement('img');
    image.src = project.image;
    image.alt = `${project.title}公开页面截图`;
    image.loading = 'lazy';
    image.decoding = 'async';
    image.width = 1600;
    image.height = 900;
    image.style.objectPosition = project.imagePosition || 'center';
    visual.append(image);
  } else {
    visual.append(makeElement('span', '', project.accent || '01'));
  }

  const body = makeElement('div', 'project-card__body');
  const kind = makeElement('p', 'eyebrow', project.kind);
  const title = makeElement('h3', '', project.title);
  const summary = makeElement('p', '', project.summary);
  const proof = makeElement('p', 'project-card__proof', project.proof);
  const link = makeElement('a', 'text-link', project.external ? '查看公开原文 ↗' : '查看案例 →');
  link.href = project.href;

  if (project.external) {
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
  }

  body.append(kind, title, summary, proof, link);
  article.append(visual, body);
  return article;
}

function createExperienceCard(item) {
  const article = makeElement('article', 'timeline__item reveal');
  const period = makeElement('p', 'timeline__period', item.period);
  const body = document.createElement('div');
  const title = makeElement('h3', '', item.role);
  const company = makeElement('p', 'timeline__company', item.company);
  const list = document.createElement('ul');

  item.bullets.forEach(text => list.append(makeElement('li', '', text)));
  body.append(title, company, list);
  article.append(period, body);
  return article;
}

function renderStaticContent() {
  const metricRoot = document.querySelector('[data-list="metrics"]');
  metricRoot.replaceChildren(...content.metrics.map(item => {
    const article = makeElement('article', 'metric-card reveal');
    const value = makeElement('strong', '', item.value);
    if (item.suffix) value.append(makeElement('small', '', item.suffix));
    article.append(value, makeElement('span', '', item.label));
    return article;
  }));

  const availabilityRoot = document.querySelector('[data-list="availability"]');
  availabilityRoot.replaceChildren(...Object.values(content.availability).map(text => makeElement('li', '', text)));

  const educationRoot = document.querySelector('[data-list="education"]');
  educationRoot.replaceChildren(...content.education.map((item, index) => {
    const article = makeElement('article', 'education-card reveal');
    article.dataset.index = String(index + 1).padStart(2, '0');
    const detail = `${item.degree} · ${item.period}${item.note ? ` · ${item.note}` : ''}`;
    article.append(makeElement('p', 'eyebrow', `EDUCATION 0${index + 1}`), makeElement('h3', '', item.school), makeElement('p', '', detail));
    return article;
  }));

  document.querySelector('[data-field="aboutZh"]').textContent = content.about.zh;
  document.querySelector('[data-field="aboutEn"]').textContent = content.about.en;
  document.querySelector('[data-field="contactNote"]').textContent = content.contact.note;
  document.querySelectorAll('[data-resume-link]').forEach(link => { link.href = content.contact.resume; });

  if (content.contact.email) {
    const link = document.querySelector('[data-email-link]');
    link.hidden = false;
    link.href = `mailto:${content.contact.email}`;
  }
}

function renderRole(roleKey) {
  const profile = content.roleProfiles[roleKey];
  if (!profile) return;

  ['eyebrow', 'headline', 'summary'].forEach(key => {
    document.querySelector(`[data-field="${key}"]`).textContent = profile[key];
  });

  document.querySelector('[data-list="tags"]').replaceChildren(...profile.tags.map(text => makeElement('span', '', text)));
  document.querySelector('[data-list="skills"]').replaceChildren(...profile.skills.map(text => makeElement('span', '', text)));

  const projects = mapById(content.projects);
  const experiences = mapById(content.experiences);
  document.querySelector('[data-project-grid]').replaceChildren(...profile.projectOrder.map(id => createProjectCard(projects.get(id))));
  document.querySelector('[data-experience-list]').replaceChildren(...profile.experienceOrder.map(id => createExperienceCard(experiences.get(id))));

  document.querySelectorAll('[data-role]').forEach(button => {
    button.setAttribute('aria-pressed', String(button.dataset.role === roleKey));
  });

  document.title = `田盛兰｜${profile.label}`;
  storeRole(roleKey);
  initRevealAnimations();
}

function initRevealAnimations() {
  const nodes = document.querySelectorAll('.reveal:not(.is-observed)');

  if (!('IntersectionObserver' in window) || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    nodes.forEach(node => node.classList.add('is-visible'));
    return;
  }

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -40px' });

  nodes.forEach((node, index) => {
    node.classList.add('is-observed');
    node.style.transitionDelay = `${Math.min(index % 4, 3) * 70}ms`;
    observer.observe(node);
  });
}

function initSite() {
  renderStaticContent();

  const queryValue = new URLSearchParams(location.search).get('role');
  const queryRole = roleAliases[queryValue];
  const storedRole = getStoredRole();
  const initialRole = queryRole || (content.roleProfiles[storedRole] ? storedRole : 'productManager');

  document.querySelectorAll('[data-role]').forEach(button => {
    button.addEventListener('click', () => renderRole(button.dataset.role));
  });

  renderRole(initialRole);
}

document.addEventListener('DOMContentLoaded', initSite);
