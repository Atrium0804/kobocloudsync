
#!/bin/sh
while IFS=',' read -ra ADDR; do
  for i in "${ADDR[@]}"; do
     echo "$i"
  done
done <<< "Arg1, Arg2, Arg3"