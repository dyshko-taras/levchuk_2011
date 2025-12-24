# Implementation Plan — IceLine Tracker

Цей план базується на вимогах з `front/info/prd.md`, `front/info/technical_spec.md`, `front/info/visual_style.md`, `front/info/assets_list.md`, `front/info/guidelines_provider.md`.

> Принцип пріоритетності: **PRD → Implementation Plan → Global Guide** (див. `front/info/guidelines_provider.md`).

---

## Фази (checklist)

- [x] **Фаза 0 — Підготовка проєкту та каркас**
  - [x] Створити Flutter-проєкт (iOS/Android), налаштувати структуру `lib/` згідно `front/info/guidelines_provider.md`.
  - [x] Додати залежності (provider, dio+retrofit, json_serializable, shared_preferences, flutter_svg, fl_chart/percent_indicator тощо за потребою PRD).
  - [x] Налаштувати `build_runner` (скрипти/інструкції для генерації).
  - [x] Налаштувати `analysis_options.yaml` (або прийнятий у репо аналізатор), базові lint правила.
  - [x] Підключити assets у `pubspec.yaml` (`assets/icons/`, `assets/images/`, `assets/fonts/`).

- [x] **Фаза 1 — Дизайн-система: токени, тема, строки, assets**
  - [x] Реалізувати `lib/ui/theme/`: `app_colors.dart`, `app_fonts.dart`, `app_theme.dart` згідно `front/info/visual_style.md`.
  - [x] Реалізувати токени/константи (`lib/constants/`): `app_spacing.dart`, `app_radius.dart`, `app_sizes.dart`, `app_durations.dart`.
  - [x] Реалізувати `lib/constants/app_routes.dart` з маршрутами зі `front/info/prd.md`.
  - [x] Реалізувати `lib/constants/app_strings.dart` (усі тексти з PRD/tech spec; без хардкоду в UI).
  - [x] Додати `lib/constants/app_icons.dart` і `lib/constants/app_images.dart` відповідно до `front/info/assets_list.md` (без raw-рядків шляхів в UI).

- [x] **Фаза 2 — API фундамент + моделі + репозиторії**
  - [x] Додати `lib/core/endpoints.dart` (baseUrl для NHL Web API v1) та узгодити шляхи.
  - [x] Реалізувати `lib/data/api/api_client.dart` (Dio: таймаути, логування в dev, базові заголовки).
  - [x] Описати Retrofit services для ключових фіч:
    - [x] Teams/Seasons bootstrap (`/teams`, `/seasons`) для Splash.
    - [x] Schedule/Daily scores (для Home).
    - [x] Standings (для Standings та Predictions).
    - [x] Game details (landing/boxscore/play-by-play для Game Center).
    - [x] Team details (roster, schedule, club stats).
    - [x] Player profile + game log (для Player).
  - [x] Створити `json_serializable` моделі (мінімально необхідні поля з tech spec, без “зайвого”).
  - [x] Створити репозиторії `lib/data/repositories/` для кожної фічі (API → мапінг → кеш/стор).
  - [x] Додати базову обробку помилок/станів (loading/error/empty) як спільний патерн для UI.

- [ ] **Фаза 3 — Локальне сховище: first_run, налаштування, кеш**
  - [ ] Реалізувати `prefs_store.dart` (shared_preferences): `first_run`, default date, toggles нотифікацій.
  - [ ] Додати простий кеш (in-memory + persisted за потребою) для:
    - [ ] `/teams`, `/seasons` (bootstrap).
    - [ ] schedule/standings (offline режим Home/Predictions).
    - [ ] favorites (команди/ігри + параметри нотифікацій).
  - [ ] Узгодити правила offline з `front/info/technical_spec.md` (показ cached даних + банер “Offline — showing cached scores”).

- [ ] **Фаза 4 — Навігація та Main Shell**
  - [ ] Реалізувати `lib/app.dart` та `MaterialApp` з `initialRoute` і таблицею маршрутів.
  - [ ] Реалізувати `SplashPage` → роутинг на `WelcomePage` (first run) або `MainShellPage`.
  - [ ] Реалізувати `MainShellPage` з Bottom Navigation (AnimatedBottomNavigationBar) та вкладками:
    - [ ] Home
    - [ ] Standings
    - [ ] Compare
    - [ ] Favorites
    - [ ] Predictions
    - [ ] Settings

- [ ] **Фаза 5 — Splash + Welcome**
  - [ ] `SplashPage`: бренд, лоадер, ініціалізація `/teams` + `/seasons`, `first_run`.
  - [ ] `WelcomePage`: hero image, segmented default date (Today/Yesterday/Tomorrow), toggle push alerts, CTA “Get Started”.
  - [ ] Зберігати вибір у локальні налаштування; по CTA встановити `first_run=false` і перейти в `MainShellPage`.

- [ ] **Фаза 6 — Home (Live Scores)**
  - [ ] API: `GET /schedule?date={targetDate}` для Today/Yesterday/Tomorrow (+ custom з календаря).
  - [ ] UI: списки Live Now / Upcoming / Final згідно tech spec, статуси (Live/Scheduled/Final/Postponed).
  - [ ] Взаємодія: відкриття `GameCenterPage` з `gamePk`, додавання/видалення favorite, quick toggle нотифікацій.
  - [ ] Offline режим: відображення кешу + індикатор offline.
  - [ ] Робота з часом/таймзонами як описано в tech spec.

- [ ] **Фаза 7 — Game Center**
  - [ ] API: підвантаження play-by-play / landing / boxscore (що потрібно для Plays/Goals/Penalties/Stats/Recap).
  - [ ] UI: Header strip + chips + actions (back, favorite, notifications, share).
  - [ ] Tabs:
    - [ ] Plays (фільтри + список подій)
    - [ ] Goals
    - [ ] Penalties
    - [ ] Stats (Home/Game/Away сегменти, team stats, player tables)
    - [ ] Recap (score by period, special teams, highlights summary, broadcasters, Share)
  - [ ] Навігація: перехід на `TeamPage`/`PlayerPage` з відповідних елементів.

- [ ] **Фаза 8 — Standings**
  - [ ] API: `GET /standings/now` (+ режим “by date” якщо потрібно для UI).
  - [ ] UI: scope segmented control (Wild Card / League / Division) + scrollable table (колонки як у tech spec).
  - [ ] Derived/presentation логіка (сортування/групування/лейаути) згідно tech spec.
  - [ ] Навігація: відкриття `TeamPage` зі standings.

- [ ] **Фаза 9 — Team Page**
  - [ ] Header з ключовими даними, favorite/notifications.
  - [ ] Tabs:
    - [ ] Roster (групування, перехід на Player)
    - [ ] Schedule (список ігор, перехід на Game Center)
    - [ ] Team Stats (карточки з метриками, CTA “Highlight upcoming”)
  - [ ] Врахувати кешування/обмеження API з tech spec.

- [ ] **Фаза 10 — Player Page**
  - [ ] API: профіль/overview + game log (для графіка “Points by game”).
  - [ ] UI: Player card header, season stats (skater/goalie), mini chart, actions (Share, Compare).
  - [ ] Навігація: запуск Compare з preselected player/team (за правилами PRD/tech spec).

- [ ] **Фаза 11 — Favorites**
  - [ ] Дві вкладки: Teams та Games.
  - [ ] Teams: список favorite команд + швидкі дії.
  - [ ] Games: список favorite ігор, toggles нотифікацій (Goals/Final), дії Delete/Share, confirm dialog.
  - [ ] Синхронізація favorites між Home/Game Center/Team.

- [ ] **Фаза 12 — Team Compare (H2H Analyzer)**
  - [ ] UI: вибір Team A/Team B, range (Last 5/Last 10/Season), секції метрик (GF/GA, special teams, faceoff/SOG, head-to-head).
  - [ ] Дані: standings + derived stats; кешування згідно tech spec.
  - [ ] CTA: “Open Next Game” → Game Center (якщо є у schedule).

- [ ] **Фаза 13 — Settings**
  - [ ] Date defaults (Today/Yesterday/Tomorrow).
  - [ ] Notifications: goal alerts / final alerts / pre-game reminders (глобальні toggles).
  - [ ] App: “Powered by NHL Stats API v1”, версія, open-source licenses (якщо реалізовано).
  - [ ] Логіка: зміна toggle → перерахунок/перепланування локальних нотифікацій.

- [ ] **Фаза 14 — Predictions (Game Insight Lab)**
  - [ ] UI: фільтри (Today/Tomorrow/Custom, All/My Favorites/Key Matchups, Filter by team), кнопка Refresh.
  - [ ] Дані: schedule + standings (+ кеш boxscore/schedule якщо потрібно).
  - [ ] Розрахунок: реалізувати алгоритм Win%/Confidence/Expected total за спрощеною формулою з tech spec.
  - [ ] Details (bottom sheet): win probability, key factors, дисклеймер, actions “Open Game Center” та “Watch this game”.

- [ ] **Фаза 15 — Нотифікації (локальні)**
  - [ ] Додати сервіс планування локальних нотифікацій (пакет узгодити з поточним стеком проєкту).
  - [ ] Реалізувати правила:
    - [ ] Глобальні toggles (Settings) керують усіма сповіщеннями.
    - [ ] Per-game toggles (Favorites/Game Center) для Goals/Final.
    - [ ] Pre-game reminders за налаштуваннями (якщо активовано).
  - [ ] Обробити відмову в дозволах/відсутність дозволу (graceful UX).

- [ ] **Фаза 16 — Якість: edge cases, продуктивність, готовність до релізу**
  - [ ] Уніфікувати стани: loading/error/empty + retry, skeletons де доречно.
  - [ ] Перевірити відсутність “magic numbers” (spacing/radius/durations) і raw strings/asset paths.
  - [ ] Додати базові unit/widget тести там, де вже є тестова інфраструктура (мінімально, без роздування).
  - [ ] Перевірити UX дрібниці: pull-to-refresh, дебаунс запитів, кеш-інвалідація.
  - [ ] Підготовка збірок: versioning, app icon/launcher, фінальний smoke-test.
