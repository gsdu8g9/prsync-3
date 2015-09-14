#!/bin/bash
#
# License:      GNU General Public License (GPL)
# Written by:   Homer Li
#
# rsync a lot of subdirectory in one directoy

#######################################################################

usage() { 
	echo "Usage: $0 [-b beginning path] [-d rsync destination path] [-p process number]" ; exit 1; 
}

while getopts ":b:d:p:" o; do
    case "${o}" in
        b)
            bpath=${OPTARG} 
            ;;
        d)
            dpath=${OPTARG} 
            ;;
        p)
            pno=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

checkvar () {
	if [ -z $1 ]
	then
		return 1
	fi
}

if ! checkvar $pno
then
	pno=16
fi

if ! checkvar $TMPATH
then
	TMPATH="/tmp"
fi

if [ ! -d $TMPATH/rsync ]
then
	mkdir $TMPATH/rsync
fi

if checkvar $bpath && checkvar $dpath
then
	tmp_fifofile=$TMPATH"/"$.fifo
	mkfifo $tmp_fifofile
	exec 9<>$tmp_fifofile
	rm $tmp_fifofile
	
	for ((i=0; i<$pno; i++))
	    do
	        echo
	    done >&9
	
	for j in $(ls $bpath)
	    do
	        read -u 9
	        {
		  if [ -d $bpath"/"$j"/" ]
		  then
		    rsync -AHaP $bpath"/"$j"/" $dpath"/"$j"/"  > /dev/zero
		    if [ ! $? -eq 0 ]
		    then
			echo $bpath"-"$i"----->"$dpath"-"$i > $TMPATH"/rsync/"$i
		    fi
                  else
                    rsync -AHaP $bpath"/"$j $dpath"/"$j  > /dev/zero
		    if [ ! $? -eq 0 ]
		    then
			echo $bpath"-"$i"----->"$dpath"-"$i > $TMPATH"/rsync/"$i
		    fi
                  fi
	            echo >&9
	        } &
	    done
	wait
	exec 9>&-
fi
