@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Publication Plan de classe (version protegee + historique propre)

echo ================================================================
echo   PUBLICATION DE PLAN DE CLASSE SUR GITHUB
echo ================================================================
echo.
echo Ce script va REMPLACER tout le depot GitHub par une histoire neuve
echo ne contenant QUE les fichiers proteges et les pages publiques.
echo Toutes les anciennes copies en clair et tout l'ancien historique
echo seront remplaces (push force). Votre Dropbox reste votre sauvegarde.
echo.
echo AVANT DE CONTINUER : le Worker Cloudflare "edt-licence" doit DEJA
echo servir la cle pour plan-de-classe (branche + verrou par origine).
echo Sinon le site affichera "licence non verifiee" pour tout le monde.
echo.
set /p OK=Le Worker est pret et vous voulez publier ? (tapez OUI puis Entree) : 
if /i not "%OK%"=="OUI" (echo Annule. Rien n'a ete fait.& pause & exit /b)

set "SRC=%~dp0"
set "DST=%TEMP%\pdc-publication"
if exist "%DST%" rmdir /s /q "%DST%"
mkdir "%DST%"

echo.
echo Copie des fichiers a publier (liste blanche)...
for %%F in (index.html echanges-heures.html confidentialite.html conditions.html README.md .gitattributes .gitignore) do (
  if exist "%SRC%%%F" copy /y "%SRC%%%F" "%DST%\" >nul
)
copy /y "%SRC%*.png" "%DST%\" >nul 2>nul
copy /y "%SRC%*.pdf" "%DST%\" >nul 2>nul

echo.
echo Fichiers qui seront publies :
dir /b "%DST%"
echo.
set /p OK2=Confirmez la publication de ces fichiers ? (OUI/Entree) : 
if /i not "%OK2%"=="OUI" (echo Annule. Rien n'a ete pousse.& pause & exit /b)

cd /d "%DST%"
git init >nul
git add -A
git -c user.name="gerardhecht-cell" -c user.email="gerard.hecht@college-amiral.com" commit -m "Plan de classe et Echanges d'heures proteges ; historique nettoye" >nul
git branch -M main
git remote add origin https://github.com/gerardhecht-cell/plan-de-classe.git
echo.
echo Envoi sur GitHub (push force)...
git push --force origin main

echo.
echo ================================================================
echo   Termine. Verifiez : https://github.com/gerardhecht-cell/plan-de-classe
echo   et le site : https://gerardhecht-cell.github.io/plan-de-classe/
echo ================================================================
pause
