# dsh-base — базовая установка DeepSeek Harness (DSH)

Готовая «база» для запуска [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) в один клик:

- файлы конфигурации (`cordis.patch.yml` — MCP-серверы + vision-модель);
- скрипты установки (Windows PowerShell + Bash);
- защищённый лаунчер GitHub (токен читается из хранилища DSH, в конфиг не попадает);
- **без токенов и личных данных** — все секреты вы вводите локально после установки.

## Быстрый старт (Windows, одна команда)

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Pechnik404/dsh-base/main/install.ps1 | iex"
```

Или вручную:

```powershell
git clone https://github.com/Pechnik404/dsh-base.git
cd dsh-base
.\install.ps1
```

Скрипт:

1. проверяет/ставит Node.js (через winget при необходимости);
2. кладёт `cordis.patch.yml` в профиль DSH (`~/.dsh/profiles/web/`);
3. кладёт `github-launcher.js` в рабочую папку (`~/Documents/DSH-work/_dsh_mcp/`);
4. запускает `npx @deepseek-ai/dsh web`.

## Что внутри

| Файл | Назначение |
|---|---|
| `cordis.patch.yml` | Конфиг: 9 MCP-серверов (filesystem, fetch, memory, git, github, context7, playwright, excel, docx) + vision-модель `deepseek-v4-flash-vision-exp`. Пути — через переменные окружения, **без абсолютных путей**. |
| `github-launcher.js` | Безопасный запуск GitHub-MCP: токен читается из `~/.dsh/.credentials.yaml` и передаётся только в окружение процесса. |
| `install.ps1` | Установщик для Windows. |
| `install.sh` | Установщик для Linux/macOS. |
| `check-secrets.ps1` | Сканер чувствительных данных (запускается автоматически перед пушем, можно использовать вручную). |

## После установки (один раз)

1. **DeepSeek API-ключ** — в интерфейсе DSH: Settings → Models (или сам DSH попросит при первом запросе).
2. **GitHub-токен (необязательно)** — добавьте строку в `C:\Users\user\.dsh\.credentials.yaml`:
   ```yaml
   GITHUB_TOKEN: github_pat_ВАШ_ТОКЕН
   ```
   Ни в конфиг, ни в чат токен не передаётся — его читает только `github-launcher.js` при запуске.
3. **Playwright (необязательно)** — браузеры: `npx playwright install chromium`.

## Безопасность

- В репозитории **нет** токенов, ключей, паролей и абсолютных путей к вашим файлам.
- Все секреты хранятся локально: `~/.dsh/.credentials.yaml` (права 0600) и переменные окружения.
- Перед каждым пушем запускается `check-secrets.ps1` — он ищет шаблоны секретов (`sk-`, `github_pat_`, `ghp_`, `AKIA`, приватные ключи и т.п.) и блокирует отправку при находке.
- MCP-серверы excel/docx/playwright работают локально — данные не отправляются в облако.
