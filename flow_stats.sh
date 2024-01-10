# Note: This code only works on NSX-T version 3.x. I wont work for NSX-T 4.x as the output format changed 
# Number of seconds between samples
DURATION=10
# Number of samples (at least 2 are required since the script does a diff)
ITERATIONS=10
STATS_FILE=stats_flows.txt

lcores=`esxcli network ens lcore list | grep DvsPortset | awk '{print $1}'`
first_lcore=`echo $lcores | awk '{print $1}'`
HEADERS=`nsxdp-cli ens flow-stats get -l $first_lcore | head -1`
echo "$HEADERS" > $STATS_FILE

while [ $ITERATIONS -gt 0 ]
do
        echo "Collecting stats...$ITERATIONS"
	for lcore_id in $lcores
	do
		STAT_LINE=`nsxdp-cli ens flow-stats get -l $lcore_id | tail -1`
		echo "$STAT_LINE"
		echo "$STAT_LINE" >> $STATS_FILE
	done
	ITERATIONS=$(( $ITERATIONS - 1 ))
	if [ $ITERATIONS -ne 0 ]
	then
		echo "Waiting $DURATION"
		sleep $DURATION
	fi
done
echo "------"
echo "Resulting file $STATS_FILE"
cat $STATS_FILE

for l in $lcores 
do 
	awk -v lcore=$l -f lcore_stat.awk $STATS_FILE
done

