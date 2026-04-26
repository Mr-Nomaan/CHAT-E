@echo off
cd /d "%~dp0"
git init
git add .
git commit -m "Initial commit - CHAT-E Multi-Agent Chatbot"
git remote add origin https://github.com/Mr-Nomaan/CHAT-E.git
git branch -M main
git push -u origin main
pause