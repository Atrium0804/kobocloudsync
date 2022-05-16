#!/bin/sh

# while IFS=',' read -ra ADDR; do
#   for i in "${ADDR[@]}"; do
#      echo "$i"
#   done
# done <<< "Arg1, Arg2, Arg3"

theString="Arg1, Arg2, Arg3" 

# str='string1-string2-string3-string4-etc'
# a=$(echo "$str" | cut -d- -f1)
# b=$(echo "$str" | cut -d- -f2)
# c=$(echo "$str" | cut -d- -f3-)
# echo "strinb b: $b"

IFS=,
set $theString
read var1 var2 var3  <<EOF
echo "var1: $var1"
echo "var2: $var2"
echo "var3: $var3"

