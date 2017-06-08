#! /bin/bash

### script to calculate 

## 
usage () {
    echo -e "\n Usage:\n ./`basename $0` <subnet> <number of subdivisions>\n"
    echo -e " example:\n ./`basename $0` 192.168.0.0/24 3 \n" 
    exit 1
}
# find the log base 2 
function log2 {
    local n=0
    for (( m=$1-1 ; $m > 0; m>>=1 )) ; do
        let n=$n+1
    done
    echo $n
}

subnet=$1
divisions=$2

if [ -z "$subnet" ] || [ -z "$divisions" ]
then
  usage
fi

IFS=. read -r i1 i2 i3 i4 <<<$subnet
last_octect=`echo $i4 | awk -F "/" '{ print $1 }'`
mask_bits=`echo $i4 | awk -F "/" '{ print $2 }'`
count=$divisions
echo -e "\n"
## run the loop for number of divisions
for ((  i=0 ; i<$count ; i=$i+1 )); do
  
	size=$(( (256-last_octect)/$divisions ))
	t=$((8-$(log2 $size)))
	new_maskbits=$(($t+$mask_bits))
	bits_remain=$(( 32-new_maskbits ))
	block=$((2**$bits_remain))
	echo -e "subnet=$i1.$i2.$i3.$last_octect/$new_maskbits\
	     network=$i1.$i2.$i3.$last_octect\
             broadcast=$i1.$i2.$i3.$(( $last_octect + ( 2**(32-$new_maskbits)-1 ) ))\
	     network=$i1.$i2.$i3.$(( $last_octect + 1 ))\
             hosts=$(( ( 2**(32-$new_maskbits) )-3 ))"

        last_octect=$(( $last_octect + $block )) 
	divisions=$(( $divisions-1 ))

done
echo -e "\n"  

