#!/bin/sh

BASE_HOSTS=/etc/hosts.base
BLOCK_AD_HOSTS=/etc/hosts.block_ad
PURE_DNS_HOSTS=/etc/hosts.pure_dns
DEBLOCK_HOSTS=/etc/hosts.deblock
CRONFILE=/etc/crontab

if [ "$1" = "clean" ]; then
    echo "Unistalling..."
    sed -i '/#Base hosts end/,$d' $BASE_HOSTS
    cp $BASE_HOSTS /etc/hosts
    sed -i "/Update\ ad-block\ and\ google\ hosts\|\/usr\/bin\/update-hosts\.sh/d" $CRONFILE
    rm -f /usr/bin/update-hosts.sh
    rm -f $BASE_HOSTS
    rm -f $BLOCK_AD_HOSTS
    rm -f $PURE_DNS_HOSTS
    rm -f $DEBLOCK_HOSTS
    exit 0
fi

echo "Installing updater..."
cp update-hosts.sh /usr/bin

echo "Installing hosts.deblock..."
cp hosts.deblock $DEBLOCK_HOSTS

echo "Moving original hosts to hosts.base..."
sed '/#Base hosts end/,$d' /etc/hosts > $BASE_HOSTS
echo "#Base hosts end" >> $BASE_HOSTS

echo "Fetching hosts.block_ad..."
curl -k https://raw.githubusercontent.com/vokins/yhosts/master/hosts > $BLOCK_AD_HOSTS 2>/dev/null

echo "Fetching hosts.pure_dns..."
curl -k https://raw.githubusercontent.com/racaljk/hosts/master/hosts 2>/dev/null | sed '/localhost\|broadcasthost/d' > $PURE_DNS_HOSTS

echo "Generating hosts..."
while read line
do
    sed -i "/$line/d" $BLOCK_AD_HOSTS
done < $DEBLOCK_HOSTS

cat $BASE_HOSTS $BLOCK_AD_HOSTS $PURE_DNS_HOSTS > /etc/hosts

echo "Adding to crontab..."
if [ -f /etc/crontab/root ]; then # for openwrt
    CRONFILE=/etc/crontab/root
fi
sed -i "/Update\ ad-block\ and\ google\ hosts\|\/usr\/bin\/update-hosts\.sh/d" $CRONFILE
echo '# Update ad-block and google hosts' >> $CRONFILE
echo '5 3     * * *   root    /usr/bin/update-hosts.sh' >> $CRONFILE
/etc/init.d/cron restart

echo "done"
