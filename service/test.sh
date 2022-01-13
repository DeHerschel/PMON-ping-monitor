#!/bin/bash
declare -a array
declare -a array2
declare -a array3

array2=([data1]=1 [data2]=2)
array3=([data1]=1 [data2]=2)

array=([host1]=${array2[@]} [host2]=${array3[@]})

echo ${#array[@]}