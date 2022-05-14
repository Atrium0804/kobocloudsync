#!/bin/sh

sentence="https://cloud.famstieltjes.nl/s/yjCPQpa5m6HaTpN      password"
# sentence="https://cloud.famstieltjes.nl/s/yjCPQpa5m6HaTpN"
  
IFS=' ' #setting comma as delimiter  
read -a strarr <<<"$sentence"
  
echo "URL:     ${strarr[0]} "  
echo "Passwd : ${strarr[1]} " 