# Push и релиз — Vuhdo_Sirus.su

Корень репо: `f:\wow_addons\Vuhdo_Sirus.su`  
Remote: `https://github.com/danilEl2/Vuhdo_Sirus.su`  
Рабочая ветка: **`dev`** (push сюда). `main` — protected; merge только вручную / с approve.

Shell: **PowerShell** (heredoc `<<'EOF'` из bash **не работает**).

---

## 0. Sync из рабочей копии

Правки сначала в `f:\wow_addons\VuhDo` и `VuhDoOptions`, затем зеркало:

```powershell
cd f:\wow_addons
$files = @(
  # перечислить изменённые пути относительно аддона, например:
  # "VuhDo\VuhDoToolbox.lua",
  # "VuhDoOptions\VuhDoOptions.toc"
)
foreach ($f in $files) {
  Copy-Item -LiteralPath $f -Destination (Join-Path "Vuhdo_Sirus.su" $f) -Force
}
```

Не коммитить: `git_token.txt`, `.cursor/`, локальные `*.zip`, `changelog.txt` (в `.gitignore`).

---

## 1. Быстрый push на `dev`

```powershell
cd f:\wow_addons\Vuhdo_Sirus.su
git status
git add -A
# не затягивать zip / токены — проверь git status после add

$msgPath = ".git\COMMIT_EDITMSG_TEMP"
[System.IO.File]::WriteAllText($msgPath, "release: ver. X.Y.Z`n`nКратко: зачем / что вошло.`n")
git commit -F $msgPath
Remove-Item $msgPath -Force

git push -u origin HEAD
```

Однострочный commit без файла (короткое сообщение):

```powershell
git commit -m "fix: short reason"
git push -u origin HEAD
```

---

## 2. Stable / Latest release (тег `vX.Y.Z`)

1. В `.toc` обеих папок: `## Version: X.Y.Z` (без `beta`).
2. Обновить блок в `README.md` (установка + история).
3. Commit + `git push` на `dev` (§1).
4. Собрать zip и создать GitHub Release:

```powershell
cd f:\wow_addons\Vuhdo_Sirus.su
$ver = "v2.23.8"   # ← поменять
$zipName = "Vuhdo_Sirus_$ver.zip"
$stage = Join-Path $env:TEMP "Vuhdo_Sirus_release_$ver"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Path $stage | Out-Null
foreach ($addon in @("VuhDo", "VuhDoOptions")) {
  Copy-Item $addon (Join-Path $stage $addon) -Recurse -Force
  Remove-Item (Join-Path $stage $addon "git_token.txt") -ErrorAction SilentlyContinue
}
if (Test-Path $zipName) { Remove-Item $zipName -Force }
Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $zipName -Force
Remove-Item $stage -Recurse -Force

$notesPath = ".git\RELEASE_NOTES_TEMP.md"
# тело релиза — править под версию
[System.IO.File]::WriteAllText($notesPath, "## VuhDo Sirus $ver`n`n### Что нового`n`n- ...`n`n### Установка`n`nРаспакуйте VuhDo и VuhDoOptions в Interface\AddOns и /reload.`n`nВетка: ``dev`` | Тег: ``$ver``.`n")

gh release create $ver `
  --repo danilEl2/Vuhdo_Sirus.su `
  --target dev `
  --title $ver `
  --notes-file $notesPath `
  --latest `
  $zipName

Remove-Item $notesPath -Force
Remove-Item $zipName -Force   # zip в .gitignore; после upload не нужен
```

`--target` — **имя ветки** (`dev`), не короткий SHA (иначе API 422).

Pre-release (beta):

```powershell
gh release create v2.23.9-beta.1 --repo danilEl2/Vuhdo_Sirus.su --target dev --title "v2.23.9-beta.1" --notes "..." --prerelease $zipName
```

---

## 3. Чеклист перед Latest

- [ ] TOC = финальная версия без `beta`
- [ ] `README` install → тег `vX.Y.Z`
- [ ] Issues по фиксу закрыты с комментарием
- [ ] `gh release list` показывает новый тег как **Latest**
- [ ] Локальный zip удалён / не в `git status`

---

## 4. `main`

Ветка protected. После stable на `dev` — merge `dev → main` вручную в GitHub (PR или approve агенту). Релиз и zip **не** требуют `main`: тег с `--target dev` достаточен.
