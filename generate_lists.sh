#!/bin/bash
coingecko_api='https://api.coingecko.com/api/v3/exchanges/binance/tickers?page='
tickers='tickers.txt'
symbols='symbols.txt'

last_page=$(curl --silent -IX GET "${coingecko_api}1" -H 'accept: application/json' | grep 'link:' \
	| sed 's/>.*//g' | sed 's/.*page=//g')

for((i=1;i<=${last_page};i++)); do
  curl --silent -X GET "${coingecko_api}${i}" -H 'accept: application/json' | jq .[] | tail -n +2 \
	  | jq '.[] | select(.is_stale == false and .is_anomaly == false) .trade_url' \
	  | sed 's/.*trade\///g' | sed 's/["_]//g' >> "${symbols}"
done

cat "${symbols}" | xargs -n1 echo 'BINANCE:' | tr -d '[:blank:]' | sort > "${tickers}"
rm "${symbols}"

cat "${tickers}" | grep USDT$ > binance_markets_USDT.txt
cat "${tickers}" | grep BUSD$ > binance_markets_BUSD.txt
cat "${tickers}" | grep BTC$  > binance_markets_BTC.txt

