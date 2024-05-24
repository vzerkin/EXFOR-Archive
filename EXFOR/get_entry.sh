#!/bin/bash
#set -x

echo "        +-----------------------------------------+"
echo "        |  Get EXFOR Entry versions as files with |"
echo "        |      timestamps in the file names.      |"
echo "        |  by v.zerkin@gmail.com, ver.2024-05-15  |"
echo "        +-----------------------------------------+"
echo "Script:$0 `date +%F`,`date +%T` on `uname -n`/`uname -s`"
echo ""
Entry="$1"
if [ "$Entry" == "" ] ; then
    echo "Please, define EXFOR Entry, for example:"
    echo "    $ ./get_entry A1495"
    exit
fi

dir0="./"
x4file="$dir0${Entry:0:1}/${Entry:0:3}/${Entry}.x4"
#test
#Entry="A1495"
#x4file="./A/A14/A1495.x4"

echo "Entry:[$Entry] File:[$x4file]"

lst="log.lst"
git log --pretty="format:%h %as %s" -- "${x4file}" >$lst
echo "">>$lst

ii=0
while IFS= read -r str0; do
    ii=$(($ii+1))
    echo "$ii) $str0"
    hh=`echo $str0|awk '{ print $1 }'`
    dd=`echo $str0|awk '{ print $2 }'`
    outfile="$Entry.x4-$dd"
    git show $hh:$x4file >$outfile
    nSubent=`cat $outfile|grep "^SUBENT"|wc -l`
    nLines=`cat $outfile|wc -l`
    echo "---Saved as file:$outfile  #Subent:$nSubent  #Lines:$nLines"
    echo ""

    ts=${dd//-/}	#remove [-]: "1999-06-17" -> "19990617"
    ts="${ts}0000.00"	#format to timestamp for touch
    touch -t $ts $outfile

done < $lst
rm $lst
ls -la ${Entry}*

echo ""
echo "Script:$0 `date +%F,%T` finished."
