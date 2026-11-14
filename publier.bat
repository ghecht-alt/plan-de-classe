@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Publication Plan de classe (version protegee + historique propre)

echo ================================================================
echo   PUBLICATION DE PLAN DE CLASSE SUR GITHUB
echo ================================================================
echo.
echo Ce script va :
echo   - cloner le depot GitHub actuel,
echo   - y remplacer index.html par la version PROTEGEE (de ce dossier),
echo   - retirer les anciennes copies EN CLAIR,
echo   - republier avec une histoire NEUVE (push force).
echo Toutes les anciennes copies en clair et tout l'ancien historique
echo disparaissent du depot. Votre Dropbox reste votre sauvegarde.
echo.
echo IMPORTANT : placez ce fichier dans le dossier qui contient le
echo index.html PROTEGE (votre dossier plan-de-classe), puis lancez-le
echo depuis la. Il utilise le index.html situe a cote de lui.
echo.
echo AVANT DE CONTINUER : le Worker Cloudflare "edt-licence" doit DEJA
echo servir la cle pour plan-de-classe (branche + verrou par origine).
echo Sinon le site affichera "licence non verifiee" pour tout le monde.
echo.
set /p OK=Le Worker est pret et vous voulez publier ? (tapez OUI puis Entree) : 
if /i not "%OK%"=="OUI" (echo Annule. Rien n'a ete fait.& pause & exit /b)

set "SRC=%~dp0"
set "DST=%TEMP%\pdc-publication"
set "REPO=https://github.com/gerardhecht-cell/plan-de-classe.git"

if not exist "%SRC%index.html" (echo ERREUR : index.html protege introuvable dans ce dossier.& pause & exit /b)
findstr /m /c:"pdc-chiffre" "%SRC%index.html" >nul || (echo ERREUR : le index.html a cote n'est PAS la version protegee.& pause & exit /b)

echo.
echo Clonage du depot actuel...
if exist "%DST%" rmdir /s /q "%DST%"
git clone "%REPO%" "%DST%"
if errorlevel 1 (echo ERREUR : clonage impossible (reseau ou git absent).& pause & exit /b)

cd /d "%DST%"

echo.
echo Remplacement de index.html par la version protegee...
copy /y "%SRC%index.html" "%DST%\index.html" >nul
if exist "%SRC%confidentialite.html" copy /y "%SRC%confidentialite.html" "%DST%\confidentialite.html" >nul
if exist "%SRC%.gitignore" copy /y "%SRC%.gitignore" "%DST%\.gitignore" >nul

echo Retrait des copies en clair...
for %%F in (index_1.html index_2.html index_6.html index_7.html index_8.html index_9.html index_16.html index_18.html index_20.html index_21.html index19.html plan-de-classe_7.html sauv-2026-10-04.html) do (
  if exist "%DST%\%%F" del /f /q "%DST%\%%F"
)

echo.
echo Verification : reste-t-il du code EN CLAIR dans un index*.html ?
findstr /m /c:"exclureNomsColles" "%DST%\index*.html" "%DST%\plan-de-classe*.html" 2>nul
if not errorlevel 1 (
  echo.
  echo ATTENTION : un fichier en clair est encore present ci-dessus. Publication ANNULEE par securite.
  pause & exit /b
)
echo   Aucun code en clair detecte. OK.

echo.
echo Fichiers qui seront publies :
dir /b "%DST%"
echo.
set /p OK2=Confirmez la publication (tapez OUI puis Entree) : 
if /i not "%OK2%"=="OUI" (echo Annule. Rien n'a ete pousse.& pause & exit /b)

echo.
echo Creation d'une histoire neuve...
git checkout --orphan nouvelle-base >nul 2>nul
git add -A
git -c user.name="gerardhecht-cell" -c user.email="gerard.hecht@college-amiral.com" commit -m "Plan de classe et Echanges d'heures proteges ; historique nettoye" >nul
git branch -M main

echo Envoi sur GitHub (push force)...
git push --force origin main
if errorlevel 1 (echo.& echo ERREUR au push. Rien n'a peut-etre ete publie. Verifiez vos identifiants GitHub.& pause & exit /b)

echo.
echo ================================================================
echo   Termine. Verifiez :
echo   https://github.com/gerardhecht-cell/plan-de-classe
echo   https://gerardhecht-cell.github.io/plan-de-classe/
echo.
echo   Pensez a realigner vos dossiers locaux (Dropbox et Drive) :
echo     git fetch origin
echo     git reset --hard origin/main
echo ================================================================
pause