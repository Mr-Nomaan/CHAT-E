@echo off
cd "E:\Tools\OPENCODE PROJECTS\AI"
git add .github/workflows/build.yml
git commit -m "Use VERBOSE=YES"
git push origin main
pause