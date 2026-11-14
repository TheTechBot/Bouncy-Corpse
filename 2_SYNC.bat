@echo off
title Sync with GitHub
cd /d "%~dp0"

where git >nul 2>nul
if errorlevel 1 ( echo [X] Git not installed. & pause & exit /b )
if not exist ".git" ( echo [X] Not a git folder. Run 1_FIRST_PUSH.bat or clone first. & pause & exit /b )

echo === Getting friends' latest work ===
git add .
set MSG=update
set /p MSG=What did you change? (short message, Enter to skip): 
git commit -m "%MSG%" >nul 2>nul

git pull --rebase origin main
if errorlevel 1 (
  echo.
  echo [X] CONFLICT: you and a friend changed the same file.
  echo     Do NOT panic. Run:  git rebase --abort
  echo     Then tell the team which file, and fix it together.
  pause & exit /b
)

echo === Sending your work ===
git push origin main
if errorlevel 1 ( echo [X] Push failed. Run this file again. & pause & exit /b )

echo.
echo [DONE] You are up to date with GitHub.
git log --oneline -5
pause