#!/bin/bash
coingecko_api='https://api.coingecko.com/api/v3/exchanges/binance/tickers?page='

max_page=$(curl --silent -IX GET "${coingecko_api}1" -H "accept: application/json" | grep 'link:' \
	| sed -e 's/>; rel="last".*//g' | sed -e 's/.*page=//g')

for((i=1;i<=${max_page};i++));do
  curl --silent -X GET "${coingecko_api}${i}" -H "accept: application/json" | jq .[] | tail -n +2 > $i
  cat $i | jq '.[] | select( .is_stale == false and .is_anomaly == false) .trade_url' \
	  | sed -e 's/.*trade\///g' | sed -e 's/"//g' | sed -e 's/_//g' >> tickers
  rm ${i}
done

cat tickers | xargs -n1 echo -e 'BINANCE:' | tr -d '[:blank:]' | sort > binance_tickers.txt
rm tickers

cat binance_tickers.txt | grep USDT$ > binance_tickers_USDT.txt
cat binance_tickers.txt | grep BUSD$ > binance_tickers_BUSD.txt
cat binance_tickers.txt | grep BTC$ > binance_tickers_BTC.txt
