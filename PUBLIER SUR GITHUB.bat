@echo off
chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"
for %%I in ("%~dp0.") do set "DOSSIER=%%~nxI"
title %DOSSIER% - mise a jour GitHub + Netlify

echo.
echo  ===== %DOSSIER% : envoi sur GitHub (Netlify se met a jour tout seul) =====
echo.
if not exist "netlify.toml" (
  echo  Ce fichier doit etre place dans le dossier du site
  echo  (celui qui contient netlify.toml, site.config.mjs, agent, content...^).
  goto :fin_erreur
)

rem --- 1) Git ---
where git >nul 2>&1 && goto :git_ok
if exist "%ProgramFiles%\Git\cmd\git.exe" goto :git_path
echo  1/5  Installation de Git (une seule fois, quelques minutes)...
winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
:git_path
set "PATH=%ProgramFiles%\Git\cmd;%PATH%"
where git >nul 2>&1 && goto :git_ok
echo  Git n'a pas pu etre installe. Installez-le depuis https://git-scm.com puis relancez.
start "" https://git-scm.com/download/win
goto :fin_erreur
:git_ok
echo  1/5  Git OK

rem --- 2) GitHub CLI (connexion au compte GitHub) ---
where gh >nul 2>&1 && goto :gh_ok
if exist "%ProgramFiles%\GitHub CLI\gh.exe" goto :gh_path
echo  2/5  Installation de l'outil GitHub (une seule fois)...
winget install -e --id GitHub.cli --accept-source-agreements --accept-package-agreements
:gh_path
set "PATH=%ProgramFiles%\GitHub CLI;%PATH%"
where gh >nul 2>&1 && goto :gh_ok
echo  L'outil GitHub n'a pas pu etre installe. Installez-le depuis https://cli.github.com puis relancez.
start "" https://cli.github.com
goto :fin_erreur
:gh_ok
gh auth status >nul 2>&1 && goto :gh_connecte
echo.
echo  2/5  Connexion a GitHub : une page va s'ouvrir dans le navigateur,
echo       collez-y le code a 8 caracteres affiche ici puis cliquez sur "Authorize".
gh auth login --hostname github.com --git-protocol https --web
if errorlevel 1 (
  echo  La connexion a GitHub a echoue. Relancez ce fichier.
  goto :fin_erreur
)
:gh_connecte
gh auth setup-git >nul 2>&1
echo  2/5  Compte GitHub OK

rem --- 3) fichiers a ne pas envoyer (Netlify refabrique public\ lui-meme) ---
if exist ".gitignore" goto :ignore_ok
> ".gitignore" echo public/
>> ".gitignore" echo node_modules/
>> ".gitignore" echo .netlify/
>> ".gitignore" echo _*.txt
:ignore_ok

rem --- 4) liaison du dossier avec son depot GitHub (une seule fois) ---
if exist ".git\" goto :depot_ok
echo.
echo  3/5  Premiere utilisation pour ce site : quel est le nom de son depot GitHub ?
echo       Vos depots :
gh repo list --limit 50 --json name -q ".[].name"
set "REPO="
set /p "REPO=  Nom du depot pour %DOSSIER% (ex : studio06) : "
if "%REPO%"=="" (
  echo  Aucun nom saisi.
  goto :fin_erreur
)
set "LOGIN="
for /f "delims=" %%L in ('gh api user -q .login') do set "LOGIN=%%L"
git init -q
git config user.name "%LOGIN%"
git config user.email "%LOGIN%@users.noreply.github.com"
git remote add origin "https://github.com/%LOGIN%/%REPO%.git"
gh repo view "%LOGIN%/%REPO%" >nul 2>&1
if not errorlevel 1 goto :depot_existant
echo  Le depot "%REPO%" n'existe pas : creation d'un depot prive.
gh repo create "%REPO%" --private >nul
if errorlevel 1 goto :fin_erreur
git checkout -q -b main
goto :depot_ok
:depot_existant
set "BR="
for /f "delims=" %%B in ('gh repo view "%LOGIN%/%REPO%" --json defaultBranchRef -q .defaultBranchRef.name') do set "BR=%%B"
if not defined BR set "BR=main"
git fetch -q origin
git checkout -q -b main
git reset -q --soft "origin/%BR%" 2>nul
:depot_ok
echo  3/5  Depot GitHub OK

rem --- 5) envoi des modifications ---
echo.
echo  4/5  Preparation des fichiers modifies...
git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo  Aucune modification depuis le dernier envoi : rien a envoyer.
  goto :netlify
)
git commit -q -m "Mise a jour du %DATE% %TIME:~0,5%"
set "BR="
for /f "tokens=3" %%B in ('git remote show origin 2^>nul ^| findstr /c:"HEAD branch"') do set "BR=%%B"
if not defined BR set "BR=main"
if "%BR%"=="(unknown)" set "BR=main"
echo  5/5  Envoi sur GitHub (branche %BR%)...
git push -q origin "HEAD:%BR%"
if errorlevel 1 (
  echo.
  echo  L'envoi sur GitHub a echoue. Verifiez votre connexion Internet et relancez ce fichier.
  goto :fin_erreur
)
echo.
echo  TERMINE : %DOSSIER% est a jour sur GitHub.

:netlify
echo.
echo  Netlify detecte l'envoi et reconstruit le site tout seul en 1 a 2 minutes
echo  (onglet "Deploys" du site sur app.netlify.com).
if not defined TOUS_LES_SITES pause
endlocal & exit /b 0

:fin_erreur
if not defined TOUS_LES_SITES pause
endlocal & exit /b 1
