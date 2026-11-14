@echo off
title First push to GitHub
cd /d "%~dp0"

echo ==================================================
echo   FIRST PUSH TO GITHUB  (run only ONE time)
echo ==================================================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo [X] Git is not installed.
  echo     Install from https://git-scm.com then run this again.
  pause & exit /b
)

if not exist "project.godot" (
  echo [X] This file must be inside the Godot project folder,
  echo     next to project.godot.
  pause & exit /b
)

git config --global user.name "TheTechBot123"
git config --global user.email "callmetechbot123@gmail.com"
git config --global init.defaultBranch main
echo [OK] Name and email set.

if not exist ".gitignore" (
  (echo .godot/& echo /android/& echo export/& echo *.tmp& echo Thumbs.db& echo .DS_Store) > .gitignore
  echo [OK] .gitignore created.
) else (
  echo [OK] .gitignore already exists.
)

if not exist ".git" (
  git init
  echo [OK] Git repo created.
)

echo.
echo Now open https://github.com/new in your browser:
echo   - Repository name: learn   (or any name)
echo   - Do NOT tick README / .gitignore / license
echo   - Click "Create repository"
echo.
set /p REPO=Type the repo name you created (example: learn): 
if "%REPO%"=="" set REPO=learn
set URL=https://github.com/TheTechBot123/%REPO%.git

git add .
git commit -m "first upload of game" >nul 2>nul
git branch -M main
git remote remove origin >nul 2>nul
git remote add origin %URL%

echo.
echo Pushing to %URL% ...
echo (A browser window may open: log in to GitHub and click Authorize.)
git push -u origin main
if errorlevel 1 (
  echo.
  echo [X] Push failed. Check: repo name correct? repo empty? logged in?
  pause & exit /b
)

echo.
echo ==================================================
echo [DONE] Game is on GitHub:
echo   https://github.com/TheTechBot123/%REPO%
echo Next: on GitHub go to Settings - Collaborators - Add people
echo       and add your friends' GitHub usernames.
echo ==================================================
pause