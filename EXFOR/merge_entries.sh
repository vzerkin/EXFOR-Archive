#!/bin/bash
#set -x
echo "        +------------------------------------------+"
echo "        |   Merge Entries to a single EXFOR file   |"
echo "        |  v.zerkin@gmail.com, version 2024-05-12  |"
echo "        +------------------------------------------+"
#echo ""
echo "Create single EXFOR file from X4 files stored in sub-directories"
echo "Script:$0 `date +%F`,`date +%T` on `uname -n`/`uname -s`"
#echo ""
t00=`date +%s`

Area=""

out="all.x4"
lst="all.lst"
tmp="all.lst1"
rm -f $out $tmp $lst

fileHead="REQUEST"
requestID=0
myDate=`date +%Y%m%d`
myTime=`date +%H%M%S`
myArea="3"

nEntry=0
N2max=0
N3max=0
filenames="*/*/*.x4"
printf "%s\n" $filenames >$tmp
sort $tmp > $lst	#all entries

#filter Entries: 2* and O*
#cat $tmp| grep "/[2O]"| sort >$lst
#Area="2"

#filter Entries: M00*
#cat $tmp| grep "/M00"| sort >$lst
#Area="M00"

totEnt=`cat $lst|wc -l`
rm $tmp

ii=0;ia=0;sym0="."
while IFS= read -r name; do
    if [ -f $name ]; then
	ii=$(($ii+1))
	if [ $ii -eq 1 ]; then
	    printf "%-11s%11d%11d%11d%11d%11s" "$fileHead" $requestID $myDate $myTime $myDate $myArea >>$out
	    echo "" >>$out
	fi
	nEntry=$((nEntry+1))
	str1=`head -n 1 ${name}`
	Entry=`echo $str1|awk '{ print $2 }'`
	sym1=${Entry:0:1}
	if [ "$sym1" != "$sym0" ]; then sym0=$sym1; ia=0; echo ""; fi
	ia=$(($ia+1))
	N2=`echo $str1|awk '{ print $3 }'`  #Date of last Entry update
	N2=$((N2+0))
	if [ $N2 -gt $N2max ]; then N2max=$N2; fi
	N3=`echo $str1|awk '{ print $4 }'`  #Date of last update in database
	N3=$((N3+0))
	if [ $N3 -gt $N3max ]; then N3max=$N3; fi
	t1=`date +%s`; dt=$(($t1-$t00))
	printf "%5d/%d) %-14s Entry:%5s N2=%-8d N3=%-8d %02d:%02d #E+%d \r" $ii $totEnt ${name} $Entry $N2 $N3 $((dt/60)) $((dt%60)) $ia
#	if [ $((ii%1000)) -eq 0 ]; then echo ""; fi
	cat ${name} >>$out
#tst	if [ $ii -ge 25 ]; then break; fi  #tst
    fi
done < $lst
printf "%-11s%11d%11d%11d" "END${fileHead}" $nEntry $N2max $N3max>>$out
echo "" >>$out

nSubent=`cat $out|grep "^SUBENT"|wc -l`
nNosubent=`cat $out|grep "^NOSUBENT"|wc -l`
nLines=`cat $out|wc -l`

fout=EXFOR-$Area-${N3max}
mv $out ${fout}.bck
mv $lst ${fout}.lst

echo "";echo ""
sta="${fout}.log"
echo "Script:$0 `date +%F,%T`"	>$sta
echo "Output:"			>>$sta
ls -lah ${fout}.*		>>$sta
echo "#Lines:    $nLines"	>>$sta
echo "#Entry:    $nEntry"	>>$sta
echo "#Subent:   $nSubent"	>>$sta
echo "#NoSubent: $nNosubent"	>>$sta
cat $sta

echo ""
echo "Script:$0 `date +%F,%T` finished."
t11=`date +%s`; dt=$(($t11-t00))
echo "Elapsed time: $((dt/3600)):$((dt/60%60)):$((dt%60))"
