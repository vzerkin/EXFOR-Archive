#!/bin/bash

# Author:  Viktor Zerkin <v.zerkin@gmail.com>
# Created: May 12, 2024
# Updated: July 31, 2026
# License: MIT

outWelcome() {
    cat <<-EOF
	   +------------------------------------------+
	   | Merge Entry files to a single EXFOR file |
	   +------------------------------------------+
	   |  v.zerkin@gmail.com, version 2026-07-31  |
	   +------------------------------------------+
	EOF
}
outPlatform() {
    cat <<-EOF
	   Platform: `uname -s -m -r`
	   Computer: `uname -n`
	   Shell:    `bash --version|head -n 1`
	   Bash-ver: $BASH_VERSION
	   Script:   $0
	   Now Dir:  `pwd`
	EOF
}
outHelp() {
    cat <<-EOF
	
	----------------------Help----------------------
	Run:
	    $ [bash] [scriptdir]merge_entries.sh [-help] ["files"] [output] [format]
	Parameters:
	    -help     display this text
	    files     EXFOR file or files; default: "*/*/*.x4"
	              default: "*/*/*.x4"
	              Note. Use quots for multiple files
	    output    output file name without extension;
	              default: "EXFOR"
	              output files:
	                - EXFOR file:           output.bck
	                - list of EXFOR files:  output.lst
	                - summary of work done: output.log
	    format    output file format; option values:
	              default: "copy"
	              "copy"     filed appended to the output file without any change
	              "cut66"    cutting text after column 66, right-trim
	              "canonic"  reformat booking service text in the output file
	Examples:
	    $ bash merge_entries.sh
	    $ ./merge_entries.sh --help
	    $ ~/bin/merge_entries.sh "entry/*/*.txt" entry cut66
	    $ bash merge_entries.sh "entry/*/*.txt" entry canonic
	    $ bash merge_entries.sh "../mygit/clone1/EXFOR/*/*/*.x4" clone1 canonic
	    $ bash merge_entries.sh "../mygit/clone1/EXFOR/*/*/T*.x4" clone1t canonic
	    $ bash merge_entries.sh "../mygit/clone1/EXFOR/*/*/[2O]*.x4" EXFOR-NEA canonic
	    $ bash merge_entries.sh "G:/projects/tmp1/entry/r/*.txt"
	EOF
}


main() {

#---starting main program: Welcome, Help+exit
    outWelcome
    if [ "$1" = "--help" ] ; then outHelp; exit; fi
    if [ "$1" = "-help"  ] ; then outHelp; exit; fi
    if [ "$1" = "-h"     ] ; then outHelp; exit; fi
    outPlatform

#---default parameters
    filenames="*/*/*.x4"
    outName="EXFOR"
    #fmt="canonic"
    #fmt="cut66"
    fmt="copy"
    fileHead="REQUEST"
    requestID=0

#---parameters from command-line arguments
    if [ "$1" != "" ]; then filenames="$1"; fi
    if [ "$2" != "" ]; then outName="$2";   fi
    if [ "$3" != "" ]; then fmt="$3";       fi
    if [ "$fmt" != "canonic" ]; then
	if [ "$fmt" != "cut66" ]; then
	    fmt="copy"
	fi
    fi

#---working files
    out="all.x4"
    lst="all.lst"
    tmp="all.lst1"
    rm -f $out $tmp $lst
#---working variables
    myDate=`date +%Y%m%d`
    myTime=`date +%H%M%S`
    myArea="3"
    nEntry=0
    N2max=0
    N3max=0

    printf "%s\n" $filenames >$tmp
    sort $tmp > $lst	#all entries

#---additional filtering
    #cat $tmp| grep -i "/[2O]"| sort >$lst	#filter Entries: 2* and O*
    #cat $tmp| grep -i "/M00"| sort >$lst	#filter Entries: M00*

    t00=`date +%s`

    totEnt=`cat $lst|wc -l`
    rm $tmp

    echo ""
    echo "Running: `date +%F`,`date +%T`"
    echo "Input:   $filenames $totEnt"
    echo "Output:  $outName  format:[$fmt]"

    totSize=0
    ii=0; ia=0; sym0="."
    while IFS= read -r name; do
	if [ ! -f $name ] ; then continue; exit; fi
	ii=$(($ii+1))
	if [ $ii -eq 1 ]; then
	    #---output header
	    printf "%-11s%11d%11d%11s%11d%11s" "$fileHead" $requestID $myDate "$myTime" $myDate "$myArea" >>$out
	    echo "" >>$out
	fi
	nEntry=$((nEntry+1))
	str1=`head -n 1 ${name}`
	str1=${str1:0:66}
	kw=`echo $str1|awk '{ print $1 }'`	#ENTRY
	if [ "$kw" != "ENTRY" ]; then continue; fi
	size=`ls -l "$name" | cut -d " " -f5`
	totSize=$(($totSize+$size))
	Entry=`echo $str1|awk '{ print $2 }'`
	sym1=${Entry:0:1}
	if [ "$sym1" != "$sym0" ]; then sym0=$sym1; ia=0; echo ""; fi
	ia=$(($ia+1))
	N2=`echo $str1|awk '{ print $3 }'`  #Date of last Entry update
	N2=$((N2+0))
	if [ $N2 -gt $N2max ]; then N2max=$N2; fi
	N3=`echo ${str1:33:11}|awk '{ print $1 }'`  #Date of last update in database
	N3=$((N3+0))
	if [ $N3 -gt $N3max ]; then N3max=$N3; fi
	N5=${str1:62:4}
	t1=`date +%s`; dt=$(($t1-$t00))
	printf "%5d/%d) %-14s Entry:%5s N2=%-8d N3=%-8d Trans:%-4s %02d:%02d #E+%d \r" $ii $totEnt ${name} $Entry $N2 $N3 "$N5" $((dt/60)) $((dt%60)) $ia
#	if [ $((ii%1000)) -eq 0 ]; then echo ""; fi
#	cat ${name} >>$out
#	cat ${name}|cut -c -66|sed 's/[[:space:]]*$//' >>$out
	if [ "$fmt" = "canonic" ]; then
	    cat ${name}								\
		| cut -c -66 							\
		| awk '{if ((index($0,"NOCOMMON")==1)				\
			  ||(index($0,"NODATA")==1) 				\
			   ) printf "%-11s%11d%11d\n",$1,0,0;   else print $0}'	\
		| awk '{if ((index($0,"NOSUBENT")==1)				\
			  ||(index($0,"COMMON")==1)				\
			  ||(index($0,"BIB")==1)				\
			  ||((index($0,"DATA       ")==1) && ($2+0 == $2))	\
			   ) printf "%-33s\n",substr($0,1,33);  else print $0}'	\
		| awk '{if ((index($0,"ENDBIB")==1)				\
			  ||(index($0,"ENDDATA")==1)				\
			  ||(index($0,"ENDCOMMON")==1)				\
			  ||(index($0,"ENDSUBENT")==1)				\
			  ||(index($0,"ENDENTRY")==1)				\
			   ) printf "%-11s%11s%11d\n",$1,$2,0;  else print $0}' \
		| awk '{if ((index($0,"ENTRY")==1)				\
			  ||(index($0,"SUBENT")==1)				\
			   ) printf "%-11s%11s%11s\n",$1,$2,$3; else print $0}'	\
		| awk '{if ((length($3)==6)					\
			    &&((index($0,"ENTRY")==1)				\
			     ||(index($0,"SUBENT")==1)				\
			     ||(index($0,"NOSUBENT")==1))			\
			) printf "%-11s%11s   19%6s\n",$1,$2,$3; else print $0}'\
		| sed 's/[[:space:]]*$//'					\
		>>$out
	else
	    if [ "$fmt" = "cut66" ]; then
		cat ${name}|cut -c -66|sed 's/[[:space:]]*$//' >>$out
	    else
		cat ${name} >>$out
	    fi
	fi
#tst	if [ $ii -ge 25 ]; then break; fi  #tst
    done < $lst

#---output footer
    dbDate=${N3max}
    if [ $dbDate -le 0 ]; then dbDate=${N2max}; fi
    printf "%-11s%11d%11d%11d" "END${fileHead}" $nEntry $N2max $dbDate>>$out
    echo "" >>$out

#---prepare EXFOR statistics
    nSubent=`cat $out|grep "^SUBENT"|wc -l`
    nNosubent=`cat $out|grep "^NOSUBENT"|wc -l`
    DataTbl=`cat  $out|grep "^DATA"|cut -c -33|awk '{if ((index($0,"DATA       ")==1)&&($2+0==$2)) printf "%-33s\n",substr($0,1,33)}'|wc -l`
    DataRows=`cat $out|grep "^DATA"|cut -c -33|awk '{if ((index($0,"DATA       ")==1)&&($2+0==$2)) sum+=substr($0,23,11)} END{print sum;}'`

#---prepare file statistics
    nfiles=`cat "$lst"|wc -l`
    nLines=`cat $out|wc -l`
    totSizeMB=$((totSize/1048576))
    bsize=`ls -l  "$out" | cut -d " " -f5`
    hsize=`ls -lh "$out" | cut -d " " -f5`
    msize=$((bsize/1048576))

#---rename output: backup and list
    fout=$outName-${dbDate}
    mv $out ${fout}.bck
    mv $lst ${fout}.lst

#---save statistics
    echo "";echo ""
    sta="${fout}.log"
    echo "Script:        $0"		>$sta
    echo "Finished:      `date +%F,%T`"	>>$sta
    echo "Input files:   $filenames ($nfiles, ${totSizeMB}MiB)">>$sta
    echo "Output file:   ${fout}.bck"	>>$sta
    echo "Output format: ${fmt}"	>>$sta
    #ls -lah ${fout}.*			>>$sta
    echo "Size:          $bsize bytes (${msize}MiB)" >>$sta
    echo "Lines:         $nLines"	>>$sta
    echo "Entry:         $nEntry"	>>$sta
    echo "Subent:        $nSubent"	>>$sta
    echo "NoSubent:      $nNosubent"	>>$sta
    echo "DataTables:    $DataTbl"	>>$sta
    echo "DataRows:      $DataRows"	>>$sta
#---display statistics
    cat $sta | sed 's/^/   /'

#---finish
    echo ""
    echo "Script:$0 `date +%F,%T` finished."
    t11=`date +%s`; dt=$(($t11-t00))
    hhmmss=`printf "%02d:%02d:%02d" $((dt/3600)) $((dt/60%60)) $((dt%60))`
    echo "Elapsed time: ${hhmmss} = ${dt} sec"
}

main "$@"
