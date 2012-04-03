#!/bin/bash

if [ -z $4 ]; then
    echo "Usage: $0 n_rules trace_length observations file.m"
    exit
fi

Prolog=/usr/bin/swipl
Octave=/usr/bin/octave
O_File=`mktemp /tmp/tmp.XXXXXXXXXX`

output=""
while [ "$output" != "satisfying_run =  1" ]; do
    Trace=`$Prolog -q -t halt -f gen_traces.pl -g "rule_placeholder($1, Rules_Placeholder), io_layer(Rules_Placeholder, $3, IO_layer, _), gen_trace_of_length($2, $3, Trace), print_trace(Trace, IO_layer, 'trace = [')" 2>&1`
    Symbolic=`echo -e $Trace | sed -e "s/; trace/;\ntrace/" | head -n1`
    Trace=`echo -e $Trace | sed -e "s/; trace/;\ntrace/" | tail -n1`
    cat $4 | sed -e "s/trace = \[\];/$Trace/" > $O_File
    echo "satisfying_run" >> $O_File
    echo "Trying: $Symbolic"
    output=`$Octave -q $O_File`
done

echo "Satisfying trace:"
echo -e "\t$Trace"
echo -e "which means:\n\t$Symbolic"

rm $O_File
