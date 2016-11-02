#!/bin/sh

BASE_HOSTS=/etc/hosts.base
BLOCK_AD_HOSTS=/etc/hosts.block_ad
PURE_DNS_HOSTS=/etc/hosts.pure_dns
DEBLOCK_HOSTS=/etc/hosts.deblock

echo "Fetching hosts.block_ad..."
curl -k https://raw.githubusercontent.com/vokins/yhosts/master/hosts > $BLOCK_AD_HOSTS 2>/dev/null

echo "Fetching hosts.pure_dns..."
curl -k https://raw.githubusercontent.com/racaljk/hosts/master/hosts 2>/dev/null | sed '/localhost\|broadcasthost/d' > $PURE_DNS_HOSTS

echo "Generating hosts..."
[ -f $DEBLOCK_HOSTS ] && while read line
do
    sed -i "/$line/d" $BLOCK_AD_HOSTS
done < $DEBLOCK_HOSTS

sed -i '/#Base hosts end/,$d' $BASE_HOSTS
echo "#Base hosts end" >> $BASE_HOSTS

cat $BASE_HOSTS $BLOCK_AD_HOSTS $PURE_DNS_HOSTS > /etc/hosts
