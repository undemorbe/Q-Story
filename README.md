# QStory

[![CI](https://github.com/undemorbe/Q-Story/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/undemorbe/Q-Story/actions/workflows/ci.yml)
[![License: PolyForm Noncommercial](https://img.shields.io/badge/License-PolyForm%20NC%201.0-orange.svg)](LICENSE)
![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-lightgrey)

**QStory** — мобильный путеводитель по историческим местам вокруг вас. Приложение не зависит от собственного сервера: места берутся из открытых баз, которые ведут историки, краеведы и энтузиасты (PastVu, Википедия, Wikidata, OpenStreetMap), а вся личная статистика — шаги, пройденный путь, найденные места — хранится **только на устройстве**.

> English summary: QStory is a Flutter app that shows historical places near you using open community data (PastVu, Wikipedia, Wikidata, OpenStreetMap), tracks your walk and steps while you search for a place, and keeps every statistic on the device. No account, no backend, no analytics.

---

## Возможности

| | |
|---|---|
| 🗺️ **Карта** | Кластеры мест, фильтры по источнику / категории / статусу посещения, поиск, ваша позиция с направлением движения и следом маршрута. |
| 📍 **Непрерывный трекинг** | Режим «следовать за мной», запись маршрута, опционально — в фоне (foreground-service на Android, background location на iOS). |
| 🎯 **Поиск места («охота»)** | Выбираете место — приложение показывает направление, расстояние и примерное время / шаги до цели (по вашей реальной скорости), считает шаги и путь. В радиусе геозоны (по умолчанию 40 м) место засчитывается как найденное. |
| 📋 **Места рядом** | Список ближайших мест с расстоянием и стрелкой направления — от вашей позиции или от центра карты. |
| 🚶 **Маршрут и «поделиться»** | Кнопка «Пешком туда» открывает навигатор (Google/Apple Maps или OSM в браузере); место можно отправить ссылкой. |
| 👣 **Шаги** | Аппаратный шагомер (Android `ACTIVITY_RECOGNITION`, iOS Motion). Если датчика нет — оценка по пройденному расстоянию и длине шага из настроек. |
| 📷 **QR-коды** | Формат `qstory:<источник>:<id>` или ссылки на Википедию / Wikidata / OSM / PastVu. Каждое место можно отдать как QR. |
| 📊 **Статистика** | Шаги за день / неделю / всё время, цель и серии, путь, активное время, макс. скорость, «шагов на находку», средний путь до места, коэффициент петляния, самая быстрая и самая длинная охота, разведанная площадь, активность по часам и дням недели, сравнение с прошлой неделей, источники и категории находок, 16 достижений. Уведомление о достижении цели дня и новых достижениях. Экспорт всех данных в JSON. |
| ⭐ **Избранное, свои места** | Свои метки хранятся локально и участвуют в поиске наравне с внешними. |
| 🌐 **RU / EN**, светлая / тёмная тема | |

## Источники данных

| Источник | Что даёт | Доступ | Лицензия данных |
|---|---|---|---|
| [PastVu](https://pastvu.com) | Исторические фотографии с привязкой к месту и году | `api2` без ключа | условия PastVu, авторство указывается |
| [Википедия](https://www.mediawiki.org/wiki/API:Geosearch) | Статьи о местах рядом (GeoSearch) | MediaWiki API | CC BY-SA 4.0 |
| [Wikidata](https://query.wikidata.org) | Объекты культурного наследия (P1483), даты, изображения | SPARQL | CC0 |
| [OpenStreetMap](https://wiki.openstreetmap.org/wiki/Overpass_API) | Памятники, мемориалы, руины, крепости (`historic=*`) | Overpass, несколько зеркал | ODbL |
| Свои места | Метки пользователя | локально | — |

Каждый источник можно выключить в настройках. Ответы кэшируются на 12 часов; при ошибке сети показывается последний кэш. Сбой одного источника не ломает остальные. Одинаковые объекты из разных баз (одно название в пределах 35 м) сливаются, остаётся самая подробная запись.

Чтобы подключить ещё один сайт, реализуйте `PlaceSourceClient` (`lib/features/places/data/sources/`) и зарегистрируйте его в `service_locator.dart` — интерфейс из двух методов: `nearby(query)` и `fetch(id)`.

## Приватность

- Нет аккаунтов, нет своего сервера, нет аналитики и рекламы.
- Координаты уходят только в запросы к выбранным источникам (чтобы найти места рядом). Маршрут, шаги и журнал не покидают устройство.
- Статистику можно выгрузить в JSON (*Статистика → ⋮ → Экспорт*) или полностью стереть (*Статистика → Сбросить*).
- Шрифты встроены в приложение — никаких запросов к Google Fonts.
- Подробнее — [PRIVACY.md](PRIVACY.md).

## Архитектура

Clean Architecture по фичам, MobX для состояния, `get_it` для DI, `go_router` для навигации.

```
lib/
├── core/            # DI, роутер, тема, l10n, HTTP-клиент, sembast-БД, prefs, сенсоры, утилиты (Result, Geo)
└── features/
    ├── places/      # домен Place, клиенты источников, репозиторий (fan-out + кэш + дедупликация), карта, карточка места
    ├── activity/    # визиты, охоты, дни; MovementAccumulator; TrackingStore, JournalStore
    ├── stats/       # StatsCalculator (чистая функция) → StatsSnapshot; страница с графиками
    ├── scanner/     # QR: QrPayloadParser + ScanResolver
    ├── favorites/ settings/ profile/ about/ onboarding/ history/ reports/
```

- **Домен без Flutter**: `QrPayloadParser`, `MovementAccumulator`, `StatsCalculator`, `Geo` — чистый Dart, покрыты unit-тестами.
- **Хранилище**: [sembast](https://pub.dev/packages/sembast) (кэш мест, визиты, охоты, дни, события, исследованные клетки 250 × 250 м) + `shared_preferences` для настроек.
- **Ошибки**: `Result<T>` / `Failure` вместо исключений на границе data-слоя.

## Сборка

Требуется Flutter **3.47+** (Dart 3.x), Android SDK и/или Xcode 16+.

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter run
```

## Тесты

~290 unit- и widget-тестов: доменная логика (статистика, ETA, QR, геометрия, экспорт), репозитории и стор'ы на in-memory БД, HTTP-клиенты источников на фейковом Dio, виджеты и «дымовой» тест запуска всего приложения.

```bash
flutter test
```

Интеграционный тест на устройстве или эмуляторе:

```bash
flutter test integration_test
```

Проверки, как в CI:

```bash
dart format --set-exit-if-changed lib test
```

```bash
flutter analyze
```

CI ([`ci.yml`](.github/workflows/ci.yml)) на каждый push и PR перегенерирует l10n и MobX-код, проверяет формат, запускает анализатор и тесты и собирает debug-APK.

## Презентация

[Презентация проекта](https://canva.link/7npuh9rsfwmkna5)

## Команда

- **Борис Станьков** — мобильное приложение
- **Андрей Корнев** — история науки и техники, контент

Об идее проекта — [ABOUT.md](ABOUT.md). Как помочь — [CONTRIBUTING.md](CONTRIBUTING.md).

## Лицензия

Код — [PolyForm Noncommercial 1.0.0](LICENSE): можно смотреть, изучать, изменять и использовать в некоммерческих целях (личные, учебные, исследовательские, некоммерческие организации). **Коммерческое использование запрещено** без отдельного письменного разрешения авторов — пишите на stankovb08@gmail.com.

Данные о местах принадлежат своим источникам и распространяются на их условиях (см. таблицу выше); в карточке каждого места указано, откуда оно взято.
