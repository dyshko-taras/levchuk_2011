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

- [x] **Фаза 3 — Локальне сховище: first_run, налаштування, кеш**
  - [x] Реалізувати `prefs_store.dart` (shared_preferences): `first_run`, default date, toggles нотифікацій.
  - [x] Додати простий кеш (in-memory + persisted за потребою) для:
    - [x] `/teams`, `/seasons` (bootstrap).
    - [x] schedule/standings (offline режим Home/Predictions).
    - [x] favorites (команди/ігри + параметри нотифікацій).
  - [x] Узгодити правила offline з `front/info/technical_spec.md` (показ cached даних + банер “Offline — showing cached scores”).

- [x] **Фаза 3b — Persisted cache у БД (Hive CE)**
  - [x] Замінити persisted кеш (раніше `shared_preferences`) на Hive CE для schedule/standings/teams/seasons.
  - [x] Додати TTL політики: історія `7d`, поточні матчі `15m`, майбутні матчі `1h`.
  - [x] Міграція/очистка старих cache keys (з `shared_preferences`) якщо вони були у користувачів (не потрібно, бо не було прод).

- [x] **Фаза 4 — Навігація та Main Shell**
  - [x] Реалізувати `lib/app.dart` та `MaterialApp` з `initialRoute` і таблицею маршрутів.
  - [x] Реалізувати `SplashPage` → роутинг на `WelcomePage` (first run) або `MainShellPage`.
  - [x] Реалізувати `MainShellPage` з Bottom Navigation (AnimatedBottomNavigationBar) та вкладками:
    - [x] Home
    - [x] Standings
    - [x] Compare
    - [x] Favorites
    - [x] Predictions
    - [x] Settings

- [x] **Фаза 4b — Provider: state management + DI**
  - [x] Додати `MultiProvider` у `lib/app.dart` (top-level providers).
  - [x] Додати `PrefsProvider` (читання/запис `PrefsStore`, draft-стейт для Welcome).
  - [x] Додати `AppStartupProvider` (Splash init: preload `/teams` + `/seasons`, min-delay, nextRoute).
  - [x] Переписати `SplashPage`/`WelcomePage`, щоб UI не створював репозиторії/Prefs напряму (все через providers).

- [x] **Фаза 5 — Splash + Welcome**
  - [x] `SplashPage`: бренд, лоадер, bootstrap teams + seasons, `first_run`.
  - [x] `WelcomePage`: hero image, segmented default date (Today/Yesterday/Tomorrow), toggle push alerts, CTA “Get Started”.
  - [x] Зберігати вибір у локальні налаштування; по CTA встановити `first_run=false` і перейти в `MainShellPage`.

- [x] **Фаза 5b — Providers (усі фічі)**
  - [x] Узгодити єдиний патерн стану для фіч (loading/error/data/empty, retry) на базі `lib/utils/async_state.dart`.
  - [x] Додати провайдер для shell-навігації (tab index + deep links для `/home`, `/standings`, `/compare`, `/favorites`, `/predictions`).
  - [x] Додати `HomeProvider` (schedule/live scores: завантаження на дату, refresh, offline/cached банер, favorite/notification toggles).
  - [x] Додати `StandingsProvider` (wild card/league/division, refresh, derived grouping/sorting згідно tech spec).
  - [x] Додати `GameCenterProvider` (завантаження та агрегація даних для Plays/Goals/Penalties/Stats/Recap + favorite/notifications).
  - [x] Додати `TeamProvider` (roster/schedule/club stats + favorite/notifications).
  - [x] Додати `PlayerProvider` (profile/overview + game log + derived stats для UI).
  - [x] Додати `FavoritesProvider` (Teams/Games списки, per-game notification toggles, синхронізація з Home/GameCenter/Team).
  - [x] Додати `CompareProvider` (порівняння Team A/B, range, derived метрики, CTA “Open Next Game”).
  - [x] Додати `PredictionsProvider` (фільтри, refresh, win%/confidence/expected total, details bottom sheet state).
  - [x] Розширити `PrefsProvider` або додати `SettingsProvider` під Settings (date defaults + notification toggles + app info).

- [x] **Фаза 6 — Home (Live Scores)**
  - [x] API: `GET /schedule/{targetDate}` для Today/Yesterday/Tomorrow (+ custom з календаря).
  - [x] UI: date ribbon (5–7 днів), сегмент Live Now / Upcoming / Final, список матчів згідно tech spec.
  - [x] Game Row: рахунок, chip статусу (period + clock / Final / Scheduled), `Shots: A – B`, quick actions (notifications + favorites).
  - [x] Взаємодія: відкриття `GameCenterPage` з `gamePk`, додавання/видалення favorite, quick toggle нотифікацій, pull-to-refresh.
  - [x] Offline режим: fallback на останні дані + банер `Offline — showing cached scores`.
  - [x] Робота з часом: показ scheduled часу в локальному часовому поясі.

- [ ] **Фаза 7 — Game Center**
  - [x] API: підвантаження play-by-play / landing / boxscore (що потрібно для Plays/Goals/Penalties/Stats/Recap).
  - [x] UI: Header strip + chips + actions (back, favorite, notifications, share).
  - [ ] Tabs:
    - [x] Plays (фільтри + список подій)
    - [x] Goals
    - [x] Penalties
    - [x] Stats (Home/Game/Away сегменти, team stats, player tables)
    - [x] Recap (score by period, special teams, highlights summary, broadcasters, Share)
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
