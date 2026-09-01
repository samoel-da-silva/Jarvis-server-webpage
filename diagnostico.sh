#!/bin/bash
# diagnostico.sh — descobre quais apps/serviços web estão rodando no servidor
# e em quais portas, pra te ajudar a preencher o SERVICES do portal.
#
# Uso:
#   chmod +x diagnostico.sh
#   ./diagnostico.sh
#
# Se algum comando pedir senha (sudo), é normal — é preciso pra ver
# o dono de cada porta.

echo "=================================================="
echo " DIAGNÓSTICO — $(hostname)"
echo "=================================================="
echo

echo "--- IP local (use este endereço nos links do portal) ---"
hostname -I 2>/dev/null | tr ' ' '\n' | grep -v '^$'
echo

echo "--- Containers Docker rodando (se houver) ---"
if command -v docker &> /dev/null; then
    if sudo docker ps &> /dev/null; then
        sudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"
    else
        echo "Docker instalado, mas sem permissão (rode com sudo ou adicione seu usuário ao grupo docker)."
    fi
else
    echo "Docker não encontrado neste servidor."
fi
echo

echo "--- Portas TCP abertas e escutando (o que realmente responde na rede) ---"
if command -v ss &> /dev/null; then
    sudo ss -tulpn 2>/dev/null | grep LISTEN
elif command -v netstat &> /dev/null; then
    sudo netstat -tulpn 2>/dev/null | grep LISTEN
else
    echo "Nem 'ss' nem 'netstat' disponíveis. Tente: sudo apt install iproute2"
fi
echo

echo "--- Serviços systemd ativos (apps instalados direto no sistema) ---"
systemctl list-units --type=service --state=running --no-pager 2>/dev/null | grep -iE "nginx|apache|jellyfin|qbittorrent|portainer|paperless|nextcloud|samba|smbd|transmission|sonarr|radarr|plex|home.?assistant" 
echo "(se a lista acima veio vazia, não achou nenhum nome comum de app de servidor)"
echo

echo "--- Snaps instalados (ex: nextcloud costuma vir como snap) ---"
if command -v snap &> /dev/null; then
    snap list 2>/dev/null
else
    echo "snap não encontrado."
fi
echo

echo "=================================================="
echo " Como ler o resultado:"
echo " - Em 'Portas TCP', a última coluna mostra o programa"
echo "   e o PID responsável por cada porta."
echo " - Pra cada porta 'estranha' que apareceu, tenta abrir"
echo "   http://<IP-DE-CIMA>:<PORTA> no navegador pra ver"
echo "   qual app é, e depois anota no SERVICES do portal."
echo "=================================================="
