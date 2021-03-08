./reload.sh
sleep 2
curl -v http://localhost:8000/route/42 | jq
