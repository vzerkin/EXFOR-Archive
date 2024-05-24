#!/bin/bash
#set -x

#Set actual timestamps to the files after clone from GitHub:
#  $ git clone https://github.com/vzerkin/EXFOR-Backup.git myexfor
#  $ cd myexfor/
#  $ bash EXFOR/setdates2clone.sh

#set timestamp to directory recursively (using $touch)
setTimestamp2dir()
{
    ftime=$1
    dname=$2
#   echo ""; echo "---setTimestamp2dir::settime:$ftime $dname"
    touch -t "$ftime" "$dname"
    dir1sub="`dirname $dname`"
    while true ; do
#	echo "===setTimestamp2dir::settime:$ftime $$dir1sub"
	touch -t "$ftime" "$dir1sub"
	if echo "$dir1sub" | grep -q -v "\/"; then break; fi
	dir1sub="`dirname $dir1sub`"
    done
}

echo "        +---------------------------------------------+"
echo "        |  Set timestamp to files cloned from GitHub. |"
echo "        |  by v.zerkin@gmail.com, version 2024-05-03. |"
echo "        +---------------------------------------------+"
echo "Set modification times of each FILE to the timestamp from git-log"
echo "Script:$0 `date +%F`,`date +%T` on `uname -n`/`uname -s`"
echo ""
t00=`date +%s`

myos=`uname -s`
ii=0; dir0=""
git ls-tree -r --name-only HEAD | while read filename; do
    ii=$(($ii+1))
#tst if [ $ii -ge 25 ]; then break; fi  #tst
    dat=`git log -1 --format="%ad" --date=iso -- $filename`
    gdat=${dat:0:19}
    if [ "$myos" = "Darwin" ] ; then
	fdat="`ls -l -D '%F %T' $filename|awk '{ print $6" "$7 }'|cut -c 1-19`"
    else
	fdat="`ls -l --time-style=full-iso $filename|awk '{ print $6" "$7 }'|cut -c 1-19`"
    fi

    t1=`date +%s`; dt=$(($t1-$t00))
    printf "%5d) %02d:%02d:%02d git:[%s] file:[%s] %-25s \r" \
    $ii $((dt/3600)) $((dt/60%60)) $((dt%60)) "$gdat" "$fdat" "$filename"

    if [ "$gdat" = "$fdat" ] ; then continue; fi
    if [ $((ii%1000)) -eq 0 ]; then echo ""; fi

    gdat=${gdat//[-|:|,| ]/}       #remove any of [-:, ]: "1999-06-17 01:15:35" -> "19990617011535"
    gdat="${gdat:0:12}.${gdat:12}" #insert "." before seconds: "19990617011535" -> "199906170115.35"

    touch -t $gdat $filename

    #set time to directories (up)
    dirname="`dirname $filename`"
    if [ "$dirname" != "$dir0" ] ; then
	setTimestamp2dir "$gdat" "$dirname"
	tim0=${gdat:0:12}; tim0=$((tim0+0))
	dir0="$dirname"
	continue
    fi
    tim1=${gdat:0:12}; tim1=$((tim1+0))
    if [ $tim1 -gt $tim0 ]; then 
	#set latest time
	setTimestamp2dir "$gdat" "$dirname"
	tim0=$tim1
    fi

done

echo ""
echo ""
echo "Script:$0 `date +%F,%T` finished."
t11=`date +%s`; dt=$(($t11-t00))
echo "Elapsed time: $((dt/3600)):$((dt/60%60)):$((dt%60))"
