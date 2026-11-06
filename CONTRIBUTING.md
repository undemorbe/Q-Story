# Как помочь QStory

1. Откройте [issue](https://github.com/undemorbe/Q-Story/issues) с описанием бага или идеи.
2. Форкните репозиторий, создайте ветку от `main`.
3. После изменений в MobX-сторах выполните `dart run build_runner build --delete-conflicting-outputs`, после изменений в `lib/core/l10n/*.arb` — `flutter gen-l10n`. Сгенерированные файлы коммитятся.
4. Перед PR: `dart format lib test` (форматирует и сгенерированные файлы — CI сверяет их побайтно), `flutter analyze` без замечаний, `flutter test` зелёный.
5. Новая логика в domain-слое — с unit-тестом.

## Новый источник мест

1. Класс в `lib/features/places/data/sources/`, реализующий `PlaceSourceClient` (`nearby`, `fetch`).
2. Значение в `PlaceSource` (название, сайт, лицензия).
3. Регистрация в `lib/core/di/service_locator.dart`.
4. Тест разбора ответа с `test/helpers/fake_http.dart`.

Источник должен быть открытым, без ключа (или с ключом, который пользователь вводит сам) и с лицензией, разрешающей показ данных в приложении.

## Стиль

- Длина строки — 120 (`analysis_options.yaml`).
- Сообщения коммитов — [Conventional Commits](https://www.conventionalcommits.org/ru/): `feat:`, `fix:`, `docs:`, `test:`, `chore:`.

## Лицензия

Отправляя PR, вы соглашаетесь, что ваш вклад распространяется на условиях [PolyForm Noncommercial 1.0.0](LICENSE), а авторы проекта могут использовать его и в собственных сборках приложения (включая публикацию в магазинах).
