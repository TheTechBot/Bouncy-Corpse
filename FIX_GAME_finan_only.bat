@echo off
title Repair Bouncy-Corpse (run on ONE laptop only)
cd /d "%~dp0"
echo ==========================================================
echo  REPAIR BOUNCY-CORPSE  -  run on ONE laptop only (Finan)
echo  Close Godot before continuing.
echo ==========================================================
echo.
if not exist ".git" (
  echo [X] Put this file inside the game folder ^(the one with .git^).
  pause & exit /b
)
pause

echo [1/7] Stopping any half-finished pull...
git rebase --abort >nul 2>nul
git merge --abort  >nul 2>nul

echo [2/7] Making a full backup copy of this folder...
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set TS=%%t
robocopy "%cd%" "%cd%_BACKUP_%TS%" /E /XD .godot /NFL /NDL /NJH /NJS >nul
echo       Backup: %cd%_BACKUP_%TS%
git branch backup-%TS% >nul 2>nul

echo [3/7] Getting latest from GitHub...
git fetch origin || (echo [X] Fetch failed. Check internet. & pause & exit /b)
git reset --hard origin/main

echo [4/7] Restoring project.godot + player script from commit f8cc05e...
git checkout f8cc05e -- project.godot Scense/player.gd Scense/game.tscn || (echo [X] Restore failed. & pause & exit /b)

echo [5/7] Removing broken conflict lines from game.tscn...
powershell -NoProfile -Command "$p='Scense/game.tscn'; $l=Get-Content $p | Where-Object { $_ -notmatch '^(<<<<<<< |=======$|>>>>>>> )' }; [IO.File]::WriteAllLines((Resolve-Path $p), $l, (New-Object Text.UTF8Encoding $false))"
findstr /r /c:"^<<<<<<<" /c:"^>>>>>>>" Scense\game.tscn >nul && (echo [X] Markers still there. Stop and ask Claude. & pause & exit /b)

echo [6/7] Clearing Godot cache...
if exist ".godot" rmdir /s /q ".godot"

echo [7/7] Uploading the repaired game...
git add -A
git commit -m "repair: restore project.godot, fix game.tscn conflict" >nul
git push origin main || (echo [X] Push failed. Run again or ask Claude. & pause & exit /b)

echo.
echo ==========================================================
echo [DONE] Repaired and pushed.
echo Open Godot ^> Import ^> project.godot ^> press F5.
echo NOTE: the moving platform (lift) is missing in this version.
echo       Drag Scense/platform.tscn back into game.tscn.
echo Tell Aflah and Amjad to run GET_FIXED.bat now.
echo ==========================================================
pause