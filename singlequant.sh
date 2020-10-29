#!/bin/bash

cd rawdata

for read in $(ls) 
do
    salmon quant -i ../salmon_sa_index_hg19 -l A --gcBias --seqBias -r $read -p 8 --validateMappings -o ../${read}.salmon_quant
done

cd ..

