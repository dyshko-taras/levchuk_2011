---
create: 23.12.2025
tags:
overview:
---

# NHL Web API v1 — quick reference

Базова адреса: `https://api-web.nhle.com/v1`
Авторизація: не потрібна (публічний API)
Формат: JSON (`GET`)

---

## 1) Розклад ліги на дату

**Запит**

* `GET /schedule/{date}`
* Path params: `date` у форматі `YYYY-MM-DD`
* Приклад: `https://api-web.nhle.com/v1/schedule/2023-11-10`

**Де в коді**

* `front/lib/data/repositories/home_repository.dart` (мапінг Web API → наші `Schedule*` моделі)

**Поля відповіді (JSON paths)**

* `gameWeek[]`

  * `date`
  * `games[]`

    * `id`
    * `startTimeUTC`
    * `gameState`
    * `gameScheduleState`
    * `homeTeam`

      * `id`
      * `abbrev`
      * `commonName.default`
      * `placeName.default`
      * `score`
      * `logo`
      * `darkLogo`
    * `awayTeam`

      * `id`
      * `abbrev`
      * `commonName.default`
      * `placeName.default`
      * `score`
      * `logo`
      * `darkLogo`
---

## 2) Game Center — play-by-play

**Запит**

* `GET /gamecenter/{gameId}/play-by-play`
* Параметри: `gameId` (int)
* Приклад: `https://api-web.nhle.com/v1/gamecenter/2023020204/play-by-play`

**Де в коді**

* `front/lib/data/api/game_service.dart`
* `front/lib/data/repositories/home_repository.dart` (`GameRepository.getGamePlayByPlay`)

**Поля відповіді (JSON paths)**

* `id`
* `gameState`
* `gameScheduleState`
* `startTimeUTC`
* `homeTeam`

  * `id`
  * `placeName.default`
  * `abbrev`
  * `score`
  * `sog`
  * `logo`
  * `darkLogo`
* `awayTeam`

  * `id`
  * `placeName.default`
  * `abbrev`
  * `score`
  * `sog`
  * `logo`
  * `darkLogo`
* `rosterSpots[]`

  * `playerId`
  * `teamId`
  * `firstName.default`
  * `lastName.default`
* `plays[]`

  * `typeDescKey`
  * `timeInPeriod`
  * `periodDescriptor.number`
  * `details`

    * `eventOwnerTeamId`
    * `descKey`
    * `scoringPlayerId`
    * `assist1PlayerId`
    * `assist2PlayerId`
    * `committedByPlayerId`
    * `duration`
---

## 3) Standings — поточний знімок

**Запит**

* `GET /standings/now`
* Приклад: `https://api-web.nhle.com/v1/standings/now`

**Де в коді**
* `front/lib/data/api/standings_service.dart`

**Поля відповіді (JSON paths)**

* `standings[]`

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

## 4) Player — landing (профіль + overview stats)

**Запит**

* `GET /player/{playerId}/landing`
* Параметри: `playerId` (int)
* Приклад: `https://api-web.nhle.com/v1/player/8478402/landing`

**Де в коді**
* `front/lib/data/api/players_service.dart`

**Поля відповіді (JSON paths)**

* `playerId`
* `firstName.default`
* `lastName.default`
* `sweaterNumber`
* `position`
* `shootsCatches`
* `fullTeamName.default`
* `birthDate`
* `headshot`
* `featuredStats.regularSeason.subSeason`

  * `gamesPlayed`
  * `goals`
  * `assists`
  * `points`
  * `plusMinus`
  * `pim`
* `careerTotals.regularSeason`

  * `avgToi`
  * `faceoffWinningPctg`
---

## 5) Player — game log (as of now)

**Запит**

* `GET /player/{playerId}/game-log/now`
* Параметри: `playerId` (int)
* Приклад: `https://api-web.nhle.com/v1/player/8478402/game-log/now`

**Поля відповіді (JSON paths)**

* `gameLog[]`

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

## 6) Team — roster (current)

**Запит**

* `GET /roster/{team}/current`
* Параметри: `team` — triCode (`BOS`, `TOR`, …)

**Поля відповіді (JSON paths)**

* `forwards[]`

  * `id`
  * `firstName.default`
  * `lastName.default`
  * `positionCode`
* `defensemen[]`

  * `id`
  * `firstName.default`
  * `lastName.default`
  * `positionCode`
* `goalies[]`

  * `id`
  * `firstName.default`
  * `lastName.default`
  * `positionCode`

---

## 7) Team — сезонний розклад (as of now)

**Запит**

* `GET /club-schedule-season/{team}/now`

**Поля відповіді (JSON paths)**

* `games[]`

  * `id`
  * `startTimeUTC`
  * `gameDate`
  * `venue.default`
  * `homeTeam`

    * `abbrev`
    * `placeName.default`
    * `commonName.default`
  * `awayTeam`

    * `abbrev`
    * `placeName.default`
    * `commonName.default`

---

### 📚 References
- [GitHub - Zmalski/NHL-API-Reference: Unofficial reference for the NHL API endpoints.](https://github.com/Zmalski/NHL-API-Reference)