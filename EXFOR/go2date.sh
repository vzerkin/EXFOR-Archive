#!/bin/bash
#set -x

#----Make snapshot (backup) of EXFOR at given date
# 0) Clone EXFOR-Backup to your file: selected folder (myexfor)
#    $ git clone https://github.com/vzerkin/EXFOR-Backup.git myexfor
#    $ cd myexfor/
# 1) Produce list of EXFOR backups
#    $ bash EXFOR/list_exfor_updates.sh
# 2) Select date and rollback Git state to selected date
#    $ bash EXFOR/go2date.sh 2005-06-16
# 3) Produce EXFOR backup file: EXFOR--20050616.bck
#    $ bash merge_entries.sh
# 4) Return Git to initial state
#    $ git switch -
#

echo "        +--------------------------------------+"
echo "        |  Go to date: rollback Git state      |"
echo "        |  v.zerkin@gmail.com, ver.2024-05-12  |"
echo "        +--------------------------------------+"
#echo ""
echo "Script:$0 `date +%F`,`date +%T` on `uname -n`/`uname -s`"
#echo ""
t00=`date +%s`
dd=$1
y0=${dd:0:4}; y1=$(($y0+1))
d0=${dd//-/}; d0=$(($d0+0))
if [ $d0 -le 0 ]; then
    echo "Wrong parameter [$1]; it must be [yyyy-mm-dd]"
    echo "Example:"
    echo "    $ go2date.sh 2025-06-16"
    exit -1
fi


lst="log.lst"
rm -f $lst
set -x
git log --before="${y1}-01-01 00:00" --pretty="format:%h %as %s" >$lst
set +x

ii=0
while IFS= read -r str0; do
    ii=$(($ii+1))
    hh=`echo $str0|awk '{ print $1 }'`
    dd=`echo $str0|awk '{ print $2 }'`
    d1=${dd//-/}; d1=$(($d1+0))
    printf "%5d %d %d [%s] \r" $ii $d0 $d1 "$str0"
    if [ $d1 -le $d0 ]; then
	echo ""
	echo "Found ${str0}"
	echo "Going to do:  $ git checkout $hh"
#	echo -n Press ENTER to continue ...\ ; read aaa;
	read -p "Press any key to continue..." < /dev/tty
	set -x
	git checkout $hh
	set +x
	rm $lst
	echo "--- Script $0 successfully completed `date +%F,%T`"
	exit
    fi
done < $lst
rm $lst

echo ""
echo "Script:$0 `date +%F,%T` finished."
t11=`date +%s`; dt=$(($t11-t00))
echo "Elapsed time: $(($dt/3600)):$(($dt/60%60)):$(($dt%60))"
