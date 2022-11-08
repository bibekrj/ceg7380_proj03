#!usr/bin/bash
fryFinished=""
echo $fryFinished
i=0
while [ "$fryFinished" == '' ]
    do
        echo 'got inside the fryfinished loop'
        fryFinished=`ssh w140bxj@fry.cs.wright.edu "ls $HOME/attempt0/ 2> /dev/null | grep "FINISHED" "` 
        echo $fryFinished
        sleep 2
        if [ "$fryFinished" != "FINISHED" ]; then
            echo 'got inside the if statement'
            echo 'going to sleep'
            sleep 5s
            echo 'awake'
            echo 'gonna check again'
            i=$(($i+1))
            if [ "$i" == 3 ]; then
            echo 'counter reached 3'
            fryFinished='FINISHED'
            fi

        fi

    done