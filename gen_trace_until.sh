#!/bin/bash

if [ -z $6 ]; then
    echo "Usage: $0 n_rules trace_length observations runs_per_trace sat|uns file.m [max_try]"
    exit
fi

Prolog=/usr/bin/swipl
Octave=/usr/bin/octave
O_File=`mktemp /tmp/tmp.XXXXXXXXXX`

if [ "$5" == "sat" ]; then
    satuns=" 1"
else
    satuns="0"
fi

if [ -z $7 ]; then
    max_try=314159265
else
    max_try=$7
fi

count=0
output=""
while [ "$output" != "satisfying_run = $satuns" ] && [ $count -lt $max_try ]; do
    Trace=`$Prolog -q -t halt -f gen_traces.pl -g "rule_placeholder($1, Rules_Placeholder), io_layer(Rules_Placeholder, $3, IO_layer, _), gen_trace_of_length($2, $3, Trace), print_trace(Trace, IO_layer, 'trace = [')" 2>&1`
    Symbolic=`echo -e $Trace | sed -e 's/; trace/;\'$'\ntrace/' | head -n1`
    Trace=`echo -e $Trace | sed -e 's/; trace/;\'$'\ntrace/' | tail -n1`
    cat $6 | sed -e "s/trace = \[\];/$Trace/" > $O_File
    echo "satisfying_run" >> $O_File
    echo "Trying: $Symbolic"
    for (( i=1; i<=$4; i+=1 ));
    do
        toutput=`$Octave -q $O_File`
        echo "Run $i/$4, result: $toutput"
        if [ "$5" == "sat" ] && [ "$toutput" == "satisfying_run =  1" ]; then
            output=$toutput
        else
            output=$toutput
        fi
    done
    count=$(( $count + 1 ))
done

if [ "$5" == "sat" ]; then
    echo "Satisfying trace:"
    echo -e "\t$Trace"
    echo -e "which means:\n\t$Symbolic"
elif [ "$5" == "uns" ] && [ "$output" == "satisfying_run = 0" ]; then
    echo "Unsatisfying trace:"
    echo -e "\t$Trace"
    echo -e "which means:\n\t$Symbolic"
fi

rm $O_File
