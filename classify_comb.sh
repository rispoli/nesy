#!/bin/bash

if [ -z $5 ]; then
    echo "Usage: $0 n_rules trace_length observations runs_per_trace file.m"
    exit
fi

Prolog=/usr/bin/swipl
Octave=/usr/bin/octave
C_File=`mktemp /tmp/tmp.XXXXXXXXXX`
O_File=`mktemp /tmp/tmp.XXXXXXXXXX`
rm satisfying unsatisfying

$Prolog -q -t halt -f gen_all_combinations.pl -g "gen_all_combinations($2, $1, $3, '$C_File')"
n_traces=`cat $C_File | wc -l`

for (( i=1; i<=$n_traces; i+=2 ));
do
	Symbolic=`cat $C_File | head -n$i | tail -n1`
	Numeric=`cat $C_File | head -n$(( i + 1 )) | tail -n1`

    cat $5 | sed -e "s/trace = \[\];/$Numeric/" > $O_File
    echo "satisfying_run" >> $O_File

	output=""
    echo "Trying: $Symbolic"
    for (( j=1; j<=$4; j+=1 ));
    do
        toutput=`$Octave -q $O_File`
        echo "Run $j/$4, result: $toutput"
        if [ "$toutput" == "satisfying_run =  1" ]; then
            output=$toutput
        fi
    done

	if [ "$output" == "satisfying_run =  1" ]; then
		echo -e "$Symbolic\n$Numeric" >> satisfying
	else
		echo -e "$Symbolic\n$Numeric" >> unsatisfying
	fi
done

rm $C_File
rm $O_File
