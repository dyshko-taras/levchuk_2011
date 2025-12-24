## Загальний опис застосунку

**Назва застосунку:** IceLine Tracker — NHL Stats & Insights

**Тип:** мобільний застосунок flutter (iOS / Android)

**Опис:**
IceLine Tracker — це мобільний клієнт для вболівальників Національної хокейної ліги (NHL), що надає доступ до актуальної статистики, результатів матчів та аналітики в зручному форматі.

**Джерело даних:**
Усі статистичні та ігрові дані отримуються з публічного **NHL Web API v1** (без авторизації, формат JSON).

---

## 1) Splash Screen

### Призначення екрану

Splash Screen використовується для **запуску застосунку**, відображення бренду IceLine Tracker та виконання **початкової ініціалізації даних і маршруту старту**.

---

### UI / UX опис

* **Тип екрану:** повноекранний (Full Screen)
* **Центральний елемент:**
  Текстовий логотип **IceLine Tracker**, розташований по центру екрана
* **Підзаголовок (Subtitle):**
  `Follow every shift, goal and trend.`

  * мова: англійська
  * розмір шрифту: 16–18 pt
  * вирівнювання: по центру
* **Нижня частина екрану:**
  Індикатор завантаження (progress / loader), що сигналізує про процес ініціалізації

---

### Дані та джерела

На Splash Screen виконуються початкові запити до NHL Web API v1 для підготовки базових довідкових даних:

* `GET /teams` — отримання списку команд NHL
* `GET /seasons` — отримання списку сезонів

Отримані дані кешуються та використовуються в подальших екранах застосунку.

---

### Бізнес-логіка

1. Після запуску застосунку Splash Screen відображається протягом **≈ 1.5–2 секунд** або до завершення ініціалізації.
2. Паралельно:

   * виконуються API-запити (`/teams`, `/seasons`);
   * зчитується локальний прапорець `first_run` з локального сховища.
3. Після завершення ініціалізації виконується умовна навігація:

   * `first_run = true` → перехід на **2) Welcome Screen**
   * `first_run = false` → перехід на **3) Home — Live Scores**

---

## 2) Welcome Screen (перший запуск)

### Призначення екрану

Welcome Screen відображається **лише під час першого запуску застосунку** та виконує дві основні функції:

* пояснює **цінність і можливості IceLine Tracker**;
* дозволяє користувачу задати **базові стартові налаштування** без реєстрації.

---

### Дані

* **Тип даних:** виключно локальні
* **API-запити:** відсутні
* Усі обрані значення зберігаються у локальному сховищі застосунку.

---

### UI / UX опис

#### Заголовок

* **Текст:** `Welcome to IceLine Tracker`
* **Розташування:** верхня частина екрану, по центру

#### Опис

* **Текст:**
  `Track real-time games, standings and player stats in one clean view.`
* **Мова:** англійська
* **Вирівнювання:** по центру
* **Призначення:** коротке пояснення ключової цінності застосунку

#### Default Date Picker

* **Тип елементу:** segmented control
* **Значення:**

  * Today
  * Yesterday
  * Tomorrow
* **Значення за замовчуванням:** `Today`
* Використовується як стартовий фільтр дат для екрану Home (Live Scores)

#### Toggle — Push alerts

* **Label:** `Push alerts for goals & finals`
* **Subtitle:** `You can change this anytime in Settings.`
* **Стан за замовчуванням:** `OFF`
* **Призначення:** попередній вибір дозволу на push-сповіщення (фактичний системний запит може виконуватись пізніше)

#### Primary Action Button

* **Текст кнопки:** `Get Started`
* **Тип:** primary
* **Ширина:** на всю ширину контейнера

---

### Бізнес-логіка

#### Натискання кнопки **[Get Started]**

1. Зберегти в локальних налаштуваннях:

   * обране значення `default_date` (Today / Yesterday / Tomorrow);
   * стан перемикача `push_alerts_enabled` (true / false).
2. Встановити прапорець:

   * `first_run = false`
3. Виконати навігацію на:

   * **3) Home — Live Scores**

---

### Навігація та переходи

* **Вхід на екран:** автоматично після Splash Screen, якщо `first_run = true`
* **Вихід з екрану:** тільки через кнопку **Get Started**
* **Назад:** не передбачено (екран одноразовий)

---

## 3) Home — Live Scores

### Призначення екрану

Екран **Home — Live Scores** є **основним екраном застосунку**, який відображає список матчів NHL для обраної дати з можливістю швидких дій: перегляд деталей гри, підписка на сповіщення та додавання в обране.

---

### Дані та API

**Основний запит:**

* `GET /schedule?date={selected}`

**Параметри:**

* `date` — обрана дата у форматі `YYYY-MM-DD`

**Дані використовуються для:**

* формування списку матчів;
* розподілу матчів за статусами: Live / Upcoming / Final;
* відображення рахунку, часу, періоду та кидків (SOG).

---

### UI / UX структура

#### Top AppBar

* **Title:** `Live Scores`
* **Right action:** іконка **Calendar**

  * відкриває date picker для вибору довільної дати

---

#### Date Ribbon

* Горизонтальний список з **5–7 днів** навколо поточної опорної дати
* Поточний активний день **візуально підсвічений**
* Tap по даті:

  * оновлює `selected_date`;
  * тригерить повторний запит `/schedule`.

---

#### Сегментований фільтр списку

* **Live Now**
* **Upcoming**
* **Final**

Фільтр працює **локально**, на основі `gameState` з відповіді API.

---

### Game Row (рядок матчу)

#### Ліва колонка

* Логотип команди (24 px)
* Аббревіатура команди
* Назва команди:

  * Home — зверху
  * Away — знизу

#### Центральна частина

* Великий рахунок: `3 – 2`
* Chip зі статусом:

  * Live: `2nd • 11:08`
  * Final: `Final`
  * Scheduled: `Scheduled 7:30 PM`
* Нижче:
  `Shots: 22 – 19`

#### Права колонка

* **[Bell]** — підписка на сповіщення по конкретній грі
* **[Star]** — додати / прибрати матч з Favorites
* Мінімальна зона натискання: **≥44 pt**

---

#### Додатковий рядок під матчем

Короткий статус або хінт, наприклад:

* `PP` (Power Play)
* `EN` (Empty Net)
* TV network
* `Tied since early 3rd period`

Формується на основі live-feed або локальної логіки.

---

### Логіка та взаємодія

* **Tap по рядку матчу:**
  → перехід на **4) Game Center** з передачею `gamePk`

* **Bell (notifications):**

  * вмикає / вимикає локальні push-сповіщення типу:

    * Goal
    * Final
  * прив’язка до `gamePk`

* **Star (favorites):**

  * додає / прибирає матч зі списку обраних
  * використовується на екрані Favorites

* **Pull-to-refresh:**

  * повторний виклик `/schedule` для активної дати

* **Calendar:**

  * відкриває системний або кастомний date picker
  * після вибору:

    * оновлює `selected_date`;
    * перезавантажує список матчів

---

### Offline режим

* За відсутності інтернету:

  * показується **кеш останнього успішного запиту**;
  * відображається банер:

    ```
    Offline — showing cached scores
    ```
* Онлайн-стан відновлюється автоматично.

---

### Робота з часом

* Усі дати та час матчів:

  * нормалізуються до **локального часового поясу користувача**
  * зберігаються в UTC у даних

---

### Bottom Navigation Bar - AnimatedBottomNavigationBar 

**Bottom Navigation Bar** використовується для швидкого перемикання між **п’ятьма основними розділами застосунку** та завжди відображається у нижній частині екрана.

#### Склад кнопок:

1. **Standings** — турнірні таблиці
2. **Compare** — порівняння команд
3. **Favorites** — обрані матчі / команди
4. **Predictions** — прогнози та аналітичні інсайти
Right FAB **Home** — Live Scores

---

# 4) Game Center

## Призначення екрану

**Game Center** — детальний екран конкретного матчу NHL з вкладками подій, голів, штрафів, статистики та підсумкового огляду. Екран використовується як під час live-матчу, так і після його завершення.

Екран відкривається з **Home — Live Scores** при натисканні на матч.

---

## Дані та API

### Основне джерело даних

```
GET /gamecenter/{gameId}/play-by-play
```

### Параметри

* `gameId` — ідентифікатор матчу (int)

### Дані використовуються для:

* header (команди, рахунок, SOG);
* визначення статусу матчу;
* побудови вкладок Plays / Goals / Penalties;
* часткового наповнення Stats та Recap (derived).

---

## Структура даних API (використання)

### Загальні поля

* `id`
* `gameState`
* `gameScheduleState`
* `startTimeUTC`

---

### Команди

**homeTeam / awayTeam**

* `id`
* `placeName.default`
* `abbrev`
* `score`
* `sog`
* `logo`
* `darkLogo`

---

### Склад команд

**rosterSpots[]**

* `playerId`
* `teamId`
* `firstName.default`
* `lastName.default`

Використовується для відображення імен гравців у подіях, голах та штрафах.

---

### Події гри

**plays[]**

* `typeDescKey`
* `timeInPeriod`
* `periodDescriptor.number`
* `details`:

  * `eventOwnerTeamId`
  * `descKey`
  * `scoringPlayerId`
  * `assist1PlayerId`
  * `assist2PlayerId`
  * `committedByPlayerId`
  * `duration`

---

## UI / UX

---

## Header strip

* Ліва сторона:

  * логотип Home команди
  * абревіатура
* Центр:

  * поточний рахунок:
    `homeTeam.score – awayTeam.score`
* Права сторона:

  * логотип Away команди
  * абревіатура

### Чипи під Header

* Поточний період і час:

  ```
  {periodDescriptor.number} • {timeInPeriod}
  ```

  (береться з останньої релевантної події)
* SOG:

  ```
  SOG {homeTeam.sog} – {awayTeam.sog}
  ```

### AppBar actions

* **[Bell]** — підписка / відписка від локальних нотифікацій Goal та Final для `gameId`
* **[Star]** — додати / прибрати матч з Favorites

---

## Tabs

```
Plays | Goals | Penalties | Stats | Recap
```

Вкладки завантажують дані **ліниво** — при першому відкритті.

---

## Tab: Plays

### Горизонтальні фільтри

* Goals
* Shots
* Hits
* Penalties
* Faceoffs

Фільтрація виконується **локально** по `plays[].typeDescKey`.

### Список подій

Для кожної події:

* час у періоді:
  `2nd • 05:32`
* команда події (через `eventOwnerTeamId`)
* тип події (`typeDescKey`)
* допоміжний статус рахунку:
  `3–2 NYR` *(derived)*

---

## Tab: Goals

### Джерело

`plays[] where typeDescKey == "goal"`

Для кожного гола:

* тип: `EV / PP / SH`
  → з `details.descKey`
* scorer (G):

  * `details.scoringPlayerId` → `rosterSpots`
* assists:

  * `assist1PlayerId` (A1)
  * `assist2PlayerId` (A2)
* час:
  `1st • 14:03`
* новий рахунок після гола:
  *(derived на основі порядку подій)*

---

## Tab: Penalties

### Джерело

`plays[] where typeDescKey == "penalty"`

Для кожного штрафу:

* тип: Tripping, Hooking тощо (`details.descKey`)
* команда: `eventOwnerTeamId`
* гравець: `committedByPlayerId`
* тривалість:

  * `details.duration` → хвилини (2 / 5 / 10)
* час періоду
* загальний статус (наприклад, збіг з голом) — *derived*

---

## Tab: Stats

> ⚠️ Обмеження API: повноцінний boxscore **відсутній**

### Toggle

```
HOME | GAME | AWAY
```

### Team stats

* SOG — **з API**
* FO%, PP%, PK% — *not available → derived / placeholder*
* Hits, Blocks — *not available*
* Giveaways / Takeaways — *not available*

### Player tables

* Горизонтальний скрол колонок

**Skaters:**

* TOI — *not available*
* G, A — *derived з Goals*
* +/- — *not available*

**Goalies:**

* TOI, SV%, SA, GA — *not available*

---

## Tab: Recap

### Score by period

Таблиця:

```
1 | 2 | 3 | OT | SO
```

→ *derived з play-by-play*

### Special teams

* PP opportunities, реалізація — *derived частково / placeholder*

### Highlights summary

* Текстове резюме — *not available в API*

### First goal / Game-winning goal

* *derived з послідовності Goals*

### Broadcasters

* TV / Radio — *not available*

### Button: [Share]

* Системний share:

  * рахунок
  * статус матчу
  * опційно — посилання на офіційний NHL Game Center

---

## Бізнес-логіка

* **[Bell]** — керування нотифікаціями по `gameId`
* **[Star]** — додавання / видалення з Favorites
* Дані оновлюються, поки:

  ```
  gameState != FINAL
  ```

---

## Навігація

* Back → **Home — Live Scores**
* Bottom Navigation Bar не показуємо

---
---

# 5) Standings

## Призначення екрану

**Standings** — екран відображення **поточного турнірного становища NHL**.
Показує позиції команд з можливістю перегляду у трьох зрізах: **Wild Card**, **League** та **Division**.

Екран використовується для швидкого аналізу положення команд у сезоні.

---

## Дані та API

### Основний запит

```
GET /standings/now
```

### Приклад

```
https://api-web.nhle.com/v1/standings/now
```

### Джерело в коді

* `front/lib/data/api/standings_service.dart`

---

## Структура відповіді API

**standings[]**

* `teamName.default`
* `teamCommonName.default`
* `teamAbbrev.default`
* `divisionName`
* `conferenceName`
* `wildcardSequence`
* `gamesPlayed`
* `wins`
* `losses`
* `otLosses`
* `points`
* `goalFor`
* `goalAgainst`
* `goalDifferential`
* `l10Wins`
* `l10Losses`
* `l10OtLosses`
* `streakCode`
* `streakCount`
* `regulationPlusOtWins`

---

## UI / UX

### Header

* **Title:** `Standings`
* **Action:** іконка **[Refresh]**

  * примусовий повторний запит `/standings/now`

---

### Scope control (segmented control)

```
Wild Card | League | Division
```

* **Wild Card** — активний за замовчуванням
* Перемикання **не виконує новий API-запит**
* Уся логіка групування та сортування виконується **локально**

---

## Основна таблиця (scrollable)

### Загальні властивості

* Вертикальний скрол
* **Sticky subheaders** для:

  * конференцій (League / Wild Card)
  * дивізіонів (Division)

---

### Колонки таблиці

| UI колонка | Дані з API                                 |
| ---------- | ------------------------------------------ |
| **Pos**    | derived (позиція у відсортованому списку)  |
| **Team**   | `teamCommonName.default` + crest (derived) |
| **GP**     | `gamesPlayed`                              |
| **W**      | `wins`                                     |
| **L**      | `losses`                                   |
| **OTL**    | `otLosses`                                 |
| **PTS**    | `points`                                   |
| **GF**     | `goalFor`                                  |
| **GA**     | `goalAgainst`                              |
| **Diff**   | `goalDifferential`                         |
| **L10**    | `l10Wins–l10Losses–l10OtLosses` (derived)  |
| **Streak** | `streakCode + streakCount`                 |

---

## Логіка відображення за режимами

### Wild Card

* Групування:

  * за `conferenceName`
* Сортування:

  1. `wildcardSequence`
  2. `points`
  3. `regulationPlusOtWins`
* Команди з `wildcardSequence != null` візуально виділяються

---

### League

* Групування:

  * за `conferenceName`
* Сортування:

  1. `points`
  2. `regulationPlusOtWins`
  3. `goalDifferential`

---

### Division

* Групування:

  * за `divisionName`
* Сортування:

  1. `points`
  2. `regulationPlusOtWins`

---

## Взаємодія

* **Tap по рядку команди**
  → перехід на **6) Team Page**
* **[Refresh]**
  → повторний виклик `/standings/now`
* Позиція (Pos) перераховується **динамічно** після кожного сортування

---

## Derived / presentation logic

* **Pos** — індекс у відсортованому списку
* **L10** — формується з:

  ```
  l10Wins – l10Losses – l10OtLosses
  ```
* **Streak**

  * `W3`, `L2`, тощо
* **Team crest**

  * derived по `teamAbbrev.default`

---

## Обмеження API

* Дані є **snapshot** (поточний стан)
* Історичних standings немає
* Календар сезону не потрібен — сезон визначається API автоматично

---

## Навігація

* Екран відкривається з Bottom Navigation Bar
* Back navigation не використовується
* Bottom Navigation Bar залишається активним

---

# 6) Team Page

## Призначення екрану

**Team Page** — профіль команди NHL. Екран надає загальний огляд команди, її поточний склад, розклад матчів та агреговані командні метрики. Також дозволяє додати команду в обране та підсвітити її майбутні матчі на Home.

Екран відкривається:

* з **Standings** (tap по команді),
* з інших екранів, де є посилання на команду.

---

## Дані та API

### Основні запити

#### 1. Склад команди (поточний)

```
GET /roster/{team}/current
```

**Параметри**

* `team` — triCode команди (наприклад: `TOR`, `BOS`)

**Джерело в коді**

* `front/lib/data/api/team_service.dart` (умовно)

**Поля відповіді**

**forwards[]**

* `id`
* `firstName.default`
* `lastName.default`
* `positionCode`

**defensemen[]**

* `id`
* `firstName.default`
* `lastName.default`
* `positionCode`

**goalies[]**

* `id`
* `firstName.default`
* `lastName.default`
* `positionCode`

---

### Додаткові джерела (derived / shared)

* Назва команди, дивізіон, конференція — *передаються з попереднього екрану або кешу `/standings/now`*
* Арена — *не надається цим API, derived / placeholder*
* Розклад і результати — *загальний schedule API (як у Home)*

---

## UI / UX

---

## Header

### Вміст

* Team crest (логотип команди)
* **Full team name**
* Підпис:

  * `{Division} / {Conference}`
* Venue name (наприклад: *Scotiabank Arena*) — *not available в API*
* **[Star] icon**

  * додати / прибрати команду з **Favorites / Teams**

### Навігація

* Back arrow → повернення на попередній екран

---

## Tabs

```
Roster | Schedule | Team Stats
```

Активна вкладка підсвічується.

---

## Tab: Roster

### Джерело даних

```
GET /roster/{team}/current
```

### Структура списку

Табличний список з колонками:

* `#` — порядковий номер (derived)
* `Pos` — `positionCode`
* `Name` — `firstName.default + lastName.default`
* Коротка позиційна мітка:

  * `C`, `LW`, `RW`, `D`, `G`

### Групування

* Forwards
* Defensemen
* Goalies
  (візуально або логічно)

### Взаємодія

* **Tap по гравцю**
  → перехід на **7) Player Page**

---

## Tab: Schedule

### Джерело даних

```
GET /schedule?teamId={id}&expand=schedule.linescore
```

(аналогічно Home — Live Scores)

### Список ігор

Для кожного матчу:

* **Date**

  * локалізована дата (local timezone)
* **Opponent**

  * назва команди
  * префікс:

    * `vs` — домашній матч
    * `@` — виїзний матч
* **Status**

  * якщо матч завершено:

    * фінальний рахунок (derived з linescore)
  * якщо майбутній:

    * час початку (наприклад: `7:00 PM`)

### Взаємодія

* **Tap по грі**
  → перехід на **4) Game Center**

---

## Tab: Team Stats

> ⚠️ Обмеження: повноцінного team stats API немає, частина даних — derived або placeholder

### Карточки з метриками

#### Last 10

* **GF / GA** — *derived*
* **W–L–OTL** — *derived*

#### Special Teams

* **PP% / PK%** — *not available → placeholder*

#### Average SOG

* **For / Against** — *not available → placeholder*

---

### Button: [Highlight upcoming]

* Розташований внизу екрану
* Primary button

**Опис**

> “Highlight this team’s upcoming games on Home”

### Логіка

* При натисканні:

  * зберігається локальна настройка
  * у **3) Home — Live Scores**:

    * найближчі матчі цієї команди
    * візуально виділяються (іконка / інший колір)
    * протягом заданого періоду (наприклад, 7 днів)

---

## Бізнес-логіка

### Favorites

* **[Star] у Header**

  * додає / видаляє команду з Favorites/Teams
  * використовується для швидкого доступу та підсвітки

### Дані

* Roster завжди запитується **окремо**
* Schedule може кешуватися
* Team Stats — без додаткових запитів

---

## Обмеження API

* Арена (Venue) — відсутня
* Розширені командні метрики — відсутні
* Last 10, Averages — обчислюються або показуються як placeholder

---

## Навігація

* Back → попередній екран
* Bottom Navigation Bar не показуємо

---

## 7) Player Page

### Роль

Екран профілю гравця з базовою біографією, сезонною статистикою та динамікою виступів по матчах. Використовується для аналізу гравця та переходу до порівняння.

---

## Дані (API)

### Основний запит — профіль + overview

```
GET /player/{playerId}/landing
```

**Де в коді**
`front/lib/data/api/players_service.dart`

**Поля відповіді (JSON paths):**

* `playerId`
* `firstName.default`
* `lastName.default`
* `sweaterNumber`
* `position`
* `shootsCatches`
* `fullTeamName.default`
* `birthDate`
* `headshot`
* `featuredStats.regularSeason.subSeason`:

  * `gamesPlayed`
  * `goals`
  * `assists`
  * `points`
  * `plusMinus`
  * `pim`
* `careerTotals.regularSeason.avgToi`
* `careerTotals.regularSeason.faceoffWinningPctg`

---

### Додатковий запит — game log (для графіка)

```
GET /player/{playerId}/game-log/now
```

**Поля відповіді (JSON paths):**

* `gameLog[]`:

  * `gameId`
  * `gameDate`
  * `goals`
  * `assists`
  * `points`
  * `shots`
  * `toi`
  * `opponentCommonName.default`
  * `opponentAbbrev`

---

## UI

### Header (Player Card)
* AppBar (Player Page):
	- Back (←) — повернення на попередній екран без перезавантаження даних.
	- Title: Player.
	- Share — відкриває системний share з короткою інформацією про гравця (ім’я, номер, позиція, базова сезонна статистика).
* Avatar:

  * `headshot`
  * fallback: placeholder-силует
* Player name:

  * `firstName.default + lastName.default`
* Jersey number:

  * `sweaterNumber`
* Position:

  * `position` (F / D / G)
* Shoots / Catches:

  * `shootsCatches` (L / R)
* Country + Date of Birth:

  * `birthDate`
  * країна — **не повертається API**, поле UI дозволене, але відображається лише якщо з’явиться в майбутньому
* Action icons:

  * Share

---

## Season stats

### Для польових гравців (F / D)

Джерело: `featuredStats.regularSeason.subSeason`

Таблиця:

* GP → `gamesPlayed`
* G → `goals`
* A → `assists`
* P → `points`
* +/- → `plusMinus`
* PIM → `pim`
* SOG → **немає в landing API**
  → **derived**: сума `shots` з `gameLog[]`
* TOI / GP →

  * `careerTotals.regularSeason.avgToi`

Додатково (якщо потрібно в UI):

* PP Points, SHG, GWG
  → **відсутні в поточному API**, поле UI допускається як placeholder / future enhancement

---

### Для воротарів (G)

Відповідно до UI зі скріну:

* GS
* W
* L
* OTL
* SV%
* GAA
* SO

⚠️ **Примітка**:
Ці показники **не повертаються** у `player/{id}/landing` або `game-log/now`.
У technical_spec фіксуються як:

> *“Stats available only if NHL API adds goalie extended stats endpoint”*

UI відображає placeholder `–` при відсутності даних.

---

## Mini chart

### Тип:

* Line chart: **“Points by game”**

### Джерело:

`GET /player/{playerId}/game-log/now`

### Логіка побудови:

* X-axis: `gameDate`
* Y-axis: `points`
* Tooltip:

  * дата матчу
  * `points`, `goals`, `assists`
  * суперник: `opponentAbbrev`

Fallback:

* якщо `gameLog[]` порожній → показуємо заглушку графіка

---

## Action row

### Share

* Системний share
* Контент:

  * ім’я гравця
  * команда (`fullTeamName.default`)
  * сезонні очки (`points`)
  * посилання на офіційний профіль NHL (опційно)

### Compare

* Переходить до **9) Team Compare**
* Team A:

  * команда гравця → `fullTeamName.default`
* Player контекст зберігається локально

---

## Логіка

* Дані профілю та stats завантажуються **одним запитом** `/player/{id}/landing`
* Game log:

  * вантажиться **ліниво**, після відкриття екрана
  * використовується **лише** для графіка
* Всі числові значення:

  * форматуються згідно локалі користувача
* Якщо частина полів недоступна в API:

  * UI не ламається

---

Добре, роблю **чітко і структуровано**, в тому ж стилі, як попередні екрани.

---

## 8) Favorites

**Роль:**
Центр керування обраними командами та матчами з швидким доступом до нотифікацій і дій.

---

### Дані

Зберігаються **локально на пристрої**:

* `favoriteTeams` — список обраних команд (teamId / teamAbbrev).
* `favoriteGames` — список обраних матчів (gameId) + налаштування нотифікацій:

  * goal notifications
  * final notifications

---

### UI

#### AppBar

* **Title:** `Favorites`.

---

### Top Tabs

* **Teams**
* **Games**

---

## Tab: Teams

### Cards (список команд)

Для кожної команди:

* **Team crest**
* **Team name**
* **Division / Conference**
* **Venue (arena name)**

### Actions

* **Tap по картці** → перехід на **6) Team Page**.
* **Long press** → діалог підтвердження:

  * Title: *Remove from favorites?*
  * Buttons: **Yes / No**

---

## Tab: Games

### Game Row

Для кожного матчу:

* **Matchup:** `TEAM A @ TEAM B`
* **Date / time** (локальний час)
* **Status badge:**

  * `Live`
  * `Final`
  * `Scheduled`
  * `Postponed`

### Notification toggles

* **Bell Goals**

  * Вмикає / вимикає локальні нотифікації на голи в матчі.
* **Bell Final**

  * Вмикає / вимикає нотифікацію на фінальний результат.

### Actions

* **Remove (trash icon)** — видалити матч з обраного.
* **Share** — системний share інформації про матч.

---

### Логіка

* Усі обрані команди та матчі **зберігаються локально**.
* Перемикачі **Bell Goals / Bell Final**:

  * створюють або видаляють локальні нотифікації для конкретного `gameId`.
* Статус матчу (*Live / Final / Scheduled / Postponed*) оновлюється при синхронізації з API.
* Після видалення:

  * команда або матч одразу зникають зі списку Favorites.

---

Ок, робимо **чіткий technical_spec**, у тому ж стилі, що й інші екрани, **українською**, з урахуванням **нашого API** та локальних обчислень.

---

## 9) Team Compare — H2H Analyzer

### Роль

Екран порівняння двох команд за поточною формою, результативністю, special teams та очними зустрічами (head-to-head) за вибраний період.

---

### Дані

**API (джерела для кешу):**

> [!warning]
> ПОТРІБНО РОЗІБРАТИСЯ ЩО ТУТ ПОВИННО БУТИ


**Примітка:**
Екран **не викликає окремий endpoint “compare”**. Усі метрики обчислюються **локально** на основі кешованих ігор команд.

---

### UI (EN)

#### Header

* Title: **Team Compare**
* AppBar:

  * Back (←) — повернення на попередній екран

---

#### Pickers row

* **Dropdown: Team A**
* **Dropdown: Team B**

  * список команд (triCode + назва)
  * за замовчуванням:

    * Team A — команда, з якої здійснено перехід (якщо є)
    * Team B — порожньо

---

#### Period selector (segmented control)

* **Last 5**
* **Last 10** (default)
* **Season**

Визначає період агрегації матчів для обох команд.

---

### Cards / Sections

#### Form

* **Team A:** W-L-OTL
* **Team B:** W-L-OTL

**Розрахунок:**

* на основі результатів матчів за вибраний період
* W / L / OTL визначаються з фінального рахунку матчів

---

#### Goals For / Against per game

* Лінійний графік або числові значення:

  * **GF/game**
  * **GA/game**
* Для Team A та Team B

**Розрахунок:**

* середнє значення забитих / пропущених шайб за матч у вибраному періоді

---

#### Special teams

* **PP%**
* **PK%**

Для кожної команди окремо.

---

#### Faceoff% and SOG avg

* **FO%** — середній відсоток виграних вкидань
* **SOG avg (For / Against)** — середні кидки у створ та допущені

---

#### Head-to-head

* Результат очних зустрічей за вибраний період:

  * формат: `3–2 Team A`

**Розрахунок:**

* враховуються лише матчі, де **Team A vs Team B**
* підрахунок перемог кожної сторони

---

### CTA

#### Primary button

**[Open Next Game]**

---

### Логіка

#### Зміна Team A / Team B / Period

* очищення локальних агрегатів
* повторний підрахунок метрик на основі кешованих ігор
* повторний рендер усіх секцій

---

#### Open Next Game

1. Пошук найближчого **future game** між Team A та Team B у:

   * `GET /club-schedule-season/{team}/now`
2. Якщо матч знайдено:

   * перехід у **4) Game Center** з `gamePk`
3. Якщо матч не знайдено:

   * toast / alert:
     **“No upcoming head-to-head game found.”**

---

### Кешування

* Агреговані дані:

  * ключ: `teamA + teamB + period`
  * TTL: ~15 хвилин
* При зміні періоду або команд — кеш інвалідується

---

### Вимоги доступності

* Усі інтерактивні елементи ≥ 44 pt
* Dropdown та segmented control підтримують системний scale text
* Графіки мають текстові альтернативи (числові значення)

---

Добре, розписую **екран 10) Settings** у тому ж стилі, що й інші — чітко, структуровано, для `technical_spec`, **українською**.

---

## 10) Settings

**Роль:**
Екран налаштувань клієнта: початкова дата, поведінка сповіщень та довідкова інформація про застосунок.

---

### Дані

* Усі налаштування зберігаються **локально на пристрої** (SharedPreferences / Local Storage).
* Запити до NHL API не виконуються.

---

### UI

#### AppBar

* **Title:** `Settings`
* Активна вкладка в Bottom Navigation: **Settings**

---

### Section: Date defaults

**Default Date (segmented control):**

* **Today**
* **Yesterday**
* **Tomorrow**

Визначає дату, яка використовується за замовчуванням при відкритті екрану **3) Home — Live Scores**.

---

### Section: Notifications

**Toggles:**

* **Goal alerts** — глобальний перемикач сповіщень про голи.
* **Final alerts** — глобальний перемикач сповіщень про фінальний результат.
* **Pre-game reminders** — нагадування перед початком матчу (опціонально).

> (Опційно) для Pre-game reminders може бути вибір lead-time:

* 15 хв
* 30 хв
* 60 хв

---

### Section: App

**Static info card:**

* Text: `Powered by NHL Stats API v1`

**Navigation rows:**

* **App version**

  * відкриває системний екран або діалог з номером версії.
* **Open source licenses**

  * відкриває список open-source бібліотек (якщо реалізовано).

---

### Логіка

* Усі зміни застосовуються **миттєво**, без кнопки Save.

**Date defaults:**

* впливає на початкову дату при відкритті екрану **Home**.

**Notification toggles:**

* при зміні:

  * перераховується та пересоздається планувальник локальних сповіщень;
  * застосовується до:

    * ігор з **Favorites**;
    * (за потреби) прогнозів у **Predictions**.

* Якщо глобальний toggle вимкнено — локальні сповіщення по іграх ігноруються.

---

### Навігація

* Bottom Navigation завжди доступний.
* Tab **Settings** підсвічений як активний.
* Перехід на будь-який інший розділ не скидає налаштування.

---

Ось **чітко і в тому ж форматі**, як інші екрани — без зайвого, структуровано.

---

## 11) Predictions — Game Insight Lab

**Роль:**
Аналітичний модуль прогнозів матчів на основі статистики команд, поточної форми та очних зустрічей.
Не ставки — лише **prediction index**.

---

### Дані

Розрахунок виконується локально на базі:

* `GET /schedule?date={targetDate}` — список матчів на дату
* `GET /standings/now` — очки, форма, позиції команд
* Закешовані дані:

  * результати ігор з `/schedule`
  * boxscore з `/game/{gamePk}/boxscore` (якщо доступно)

---

### UI (EN)

#### Header

* Title: **“Game Insight Lab”**
* Action:

  * **[Refresh]** — примусовий перерахунок прогнозів

---

#### Filters row

* Date selector (segmented):

  * Today | Tomorrow | Custom
* Scope selector (segmented):

  * All | My Favorites | Key Matchups
* Optional dropdown:

  * **Filter by team**

---

#### Prediction list (per game)

**Line 1**

* `{Date} · {AWAY} @ {HOME}`
* Confidence chip:

  * High confidence / Moderate / Low

**Line 2 — summary**

* `Projected winner: HOME (64%)`
* `Expected total: 5.8 goals`

**Inline hints**

* Form: `4–1 vs 2–3 (last 5)`
* PP vs PK: `26% PP vs 76% PK`

**Right side**

* Circular win probability indicator (donut)
* Chevron `>` — відкриття деталей

---

### Game Insight (bottom sheet / details)

**Title**

* `{AWAY} @ {HOME}`

**Win probability**

* Home: 64%
* Away: 36%

**Key factors**

* Last 10 games record (home/away split)
* Goal differential trend
* Special teams difference (PP / PK)
* Head-to-head in last X meetings

**Note**

* “This is an analytics-based projection, not betting advice.”

**Actions**

* **[Open Game Center]** → 4) Game Center
* **[Watch this game]**

  * додає матч у Favorites
  * вмикає Final alert

---

### Логіка розрахунку (спрощено)

```
Base rating = normalized points % (standings)
Recent form = last N games (W / L / OTL)
Goal diff factor = normalized (GF - GA)
Special teams = PP% + PK% delta vs league avg
Home advantage = constant bonus

Home score = base + form + goal diff + special + home advantage
Away score = base + form + goal diff + special

Win% = softmax(Home score, Away score)
Confidence = |Home score - Away score|
Expected total goals = league base + f(GF, GA)
```

---

### Логіка екрану

* При вході:

  * завантажується `/schedule` для обраної дати
  * підтягуються дані команд зі `/standings/now`
  * розраховуються Win% та Expected total для кожного матчу
* **My Favorites**

  * показує матчі, де команда або гра є у Favorites
* **Key Matchups**

  * матчі з високим сумарним рейтингом команд
* **[Refresh]**

  * оновлює standings + schedule
  * перераховує всі інсайти
* Дублікати по одному `gamePk` не допускаються

---

### Обмеження та принципи

* ❌ Ніяких ставок, odds, O/U, first goal тощо
* ✅ Лише аналітика та підсвічування цікавих матчів
* Екран прив’язаний до нижньої вкладки **Predictions**

---

Якщо хочеш — далі можемо:

* прив’язати **конкретні поля standings/boxscore** до кожного фактору
* або описати **алгоритм confidence** ще формальніше (для dev-доки)
