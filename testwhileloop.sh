#!usr/bin/bash
distance=`ssh w140bxj@owens.osc.edu "cat ~nehrbajo/proj03data/database04.txt | tail -n 5 | head -n 1"`
path=`ssh w140bxj@owens.osc.edu "cat ~nehrbajo/proj03data/database04.txt | tail -n 5 | head -n 2 | tail -n 1"`
filename='database04'
python3 utils.py 2 "$distance" "$path" "$filename"
PICKLEFILENAME="$filename".pickle
echo $PICKLEFILENAME