@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Publication Plan de classe (version protegee + historique propre)

echo ================================================================
echo   PUBLICATION DE PLAN DE CLASSE SUR GITHUB
echo ================================================================
echo.
echo Ce script va cloner le depot GitHub, y mettre la version PROTEGEE,
echo retirer les copies en clair, et republier avec une histoire NEUVE
echo (push force). Votre Dropbox reste votre sauvegarde.
echo.
echo AVANT : le Worker Cloudflare "edt-licence" doit DEJA servir la cle
echo pour plan-de-classe. Sinon le site affichera "licence non verifiee".
echo.

rem --- Trouver git : PATH, sinon GitHub Desktop, sinon Git pour Windows ---
set "GIT="
for /f "delims=" %%G in ('where git 2^>nul') do if not defined GIT set "GIT=%%G"
if not defined GIT for /f "delims=" %%G in ('dir /b /s "%LocalAppData%\GitHubDesktop\app-*\resources\app\git\cmd\git.exe" 2^>nul') do set "GIT=%%G"
if not defined GIT for /f "delims=" %%G in ('dir /b /s "%LocalAppData%\GitHubDesktop\app-*\resources\app\git\mingw64\bin\git.exe" 2^>nul') do set "GIT=%%G"
if not defined GIT if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT=%ProgramFiles%\Git\cmd\git.exe"
if not defined GIT if exist "%ProgramFiles(x86)%\Git\cmd\git.exe" set "GIT=%ProgramFiles(x86)%\Git\cmd\git.exe"
if not defined GIT (
  echo git est introuvable sur ce PC. Installez "Git pour Windows" ^(git-scm.com^),
  echo ou dites-le moi : on trouvera une autre voie. 
  pause & exit /b
)
echo git trouve : "%GIT%"
echo.

set /p OK=Le Worker est pret et vous voulez publier ? (tapez OUI puis Entree) : 
if /i not "%OK%"=="OUI" (echo Annule. Rien n'a ete fait.& pause & exit /b)

set "SRC=%~dp0"
set "DST=%TEMP%\pdc-publication"
set "REPO=https://github.com/gerardhecht-cell/plan-de-classe.git"

if not exist "%SRC%index.html" (echo ERREUR : index.html introuvable dans ce dossier.& pause & exit /b)
findstr /m /c:"pdc-chiffre" "%SRC%index.html" >nul || (echo ERREUR : le index.html a cote n'est PAS la version protegee.& pause & exit /b)

echo.
echo Clonage du depot actuel...
if exist "%DST%" rmdir /s /q "%DST%"
"%GIT%" clone "%REPO%" "%DST%"
if errorlevel 1 (echo ERREUR : clonage impossible (reseau ou acces GitHub).& pause & exit /b)

cd /d "%DST%"

echo Remplacement de index.html par la version protegee...
copy /y "%SRC%index.html" "%DST%\index.html" >nul
if exist "%SRC%confidentialite.html" copy /y "%SRC%confidentialite.html" "%DST%\confidentialite.html" >nul
if exist "%SRC%.gitignore" copy /y "%SRC%.gitignore" "%DST%\.gitignore" >nul

echo Retrait des copies en clair...
for %%F in (index_1.html index_2.html index_6.html index_7.html index_8.html index_9.html index_16.html index_18.html index_20.html index_21.html index19.html plan-de-classe_7.html sauv-2026-10-04.html) do (
  if exist "%DST%\%%F" del /f /q "%DST%\%%F"
)

echo.
echo Verification : reste-t-il du code EN CLAIR ?
findstr /m /c:"exclureNomsColles" "%DST%\index*.html" "%DST%\plan-de-classe*.html" 2>nul
if not errorlevel 1 (echo. & echo ATTENTION : un fichier en clair subsiste. Publication ANNULEE.& pause & exit /b)
echo   Aucun code en clair detecte. OK.

echo.
echo Fichiers qui seront publies :
dir /b "%DST%"
echo.
set /p OK2=Confirmez la publication (tapez OUI puis Entree) : 
if /i not "%OK2%"=="OUI" (echo Annule. Rien n'a ete pousse.& pause & exit /b)

echo.
echo Creation d'une histoire neuve...
"%GIT%" checkout --orphan nouvelle-base >nul 2>nul
"%GIT%" add -A
"%GIT%" -c user.name="gerardhecht-cell" -c user.email="gerard.hecht@college-amiral.com" commit -m "Plan de classe et Echanges d'heures proteges ; historique nettoye" >nul
"%GIT%" branch -M main

echo Envoi sur GitHub (push force)...
"%GIT%" push --force origin main
if errorlevel 1 (echo. & echo ERREUR au push. Verifiez votre connexion GitHub ^(identifiants^).& pause & exit /b)

echo.
echo ================================================================
echo   Termine. Verifiez :
echo   https://github.com/gerardhecht-cell/plan-de-classe
echo   https://gerardhecht-cell.github.io/plan-de-classe/
echo ================================================================
pause