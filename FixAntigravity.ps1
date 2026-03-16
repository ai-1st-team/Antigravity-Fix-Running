---

# 🛠 Antigravity IDE Terminal Fixer

Скрипт для автоматического исправления бага с зависанием терминала (статус `Running...`) в Antigravity IDE и VS Code.

## 📝 Описание проблемы

Иногда ИИ-агент в среде разработки перестает понимать, что команда в терминале завершена. Это происходит из-за конфликта функции `shellIntegration`. Данный скрипт отключает проблемный функционал и сбрасывает настройки терминала до стабильных.

---

## 🚀 Инструкция по запуску

### Шаг 1: Подготовка файла

1. Создайте в любой папке текстовый файл.
2. Назовите его `FixAntigravity.ps1`.
> **Важно:** убедитесь, что расширение файла именно `.ps1`, а не `.ps1.txt`.



### Шаг 2: Добавление кода

Откройте файл через Блокнот или любой редактор и вставьте следующий код:

```powershell
# Скрипт для исправления настроек терминала
Write-Host "🔧 Начинаю исправление настроек Antigravity..." -ForegroundColor Cyan

# 1. Закрываем запущенные экземпляры IDE
Write-Host "🛑 Закрываю IDE для применения настроек..." -ForegroundColor Yellow
$processes = "antigravity", "Code"
Get-Process -Name $processes -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# 2. Поиск и обновление settings.json
$paths = @(
    "$env:APPDATA\Antigravity\User\settings.json", 
    "$env:APPDATA\Code\User\settings.json"
)
$file = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($file) {
    $json = Get-Content $file -Raw | ConvertFrom-Json
    
    # Принудительное применение стабильных параметров
    $json | Add-Member -MemberType NoteProperty -Name "terminal.integrated.shellIntegration.enabled" -Value $false -Force
    $json | Add-Member -MemberType NoteProperty -Name "terminal.integrated.defaultProfile.windows" -Value "PowerShell" -Force
    
    $json | ConvertTo-Json -Depth 20 | Set-Content $file
    Write-Host "✅ Настройки успешно обновлены: $file" -ForegroundColor Green
} else {
    Write-Host "❌ Файл settings.json не найден. Проверьте путь установки." -ForegroundColor Red
}

# 3. Перезапуск IDE
Write-Host "🚀 Запускаю Antigravity IDE..." -ForegroundColor Cyan
try {
    Start-Process "antigravity" -ErrorAction Stop
} catch {
    try { Start-Process "code" -ErrorAction Stop } catch { 
        Write-Host "⚠️ Не удалось запустить IDE автоматически. Откройте её вручную." -ForegroundColor Yellow
    }
}

Write-Host "🎉 Готово! Окно закроется через 5 секунд..." -ForegroundColor Green
Start-Sleep -Seconds 5

```

### Шаг 3: Запуск

Правой кнопкой мыши по файлу — **Выполнить с помощью PowerShell** (Run with PowerShell).

---

## 🔍 Что именно делает этот скрипт?

Скрипт работает как «быстрая ремонтная кнопка» и выполняет три простых действия:

1. **Завершает процессы:** Принудительно закрывает IDE, чтобы файл настроек не был заблокирован.
2. **Редактирует конфигурацию:** Находит файл `settings.json` и программно вносит изменения:
* `shellIntegration.enabled: false` — отключает сложную интеграцию, которая часто вызывает «фризы».
* `defaultProfile.windows: PowerShell` — устанавливает стандартную оболочку.


3. **Перезагружает среду:** Снова запускает программу, чтобы изменения вступили в силу.

---

## ⚠️ Требования

* **ОС:** Windows 10/11
* **Права:** Возможно, потребуется разрешение на запуск скриптов PowerShell (если заблокировано системой).

---

*Разработано для сообщества Antigravity IDE.*

---