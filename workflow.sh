#!/usr/bin/bash
# name: Bibek Raj Joshi
# wNumber: w140bxj
# Project Name: Proj03
# Assigned : Oct 20
# Due Date : Nov 04
# Tested on: fry
fry='w140bxj@fry.cs.wright.edu'
owens='w140bxj@owens.osc.edu'
aws='ubuntu@34.235.48.146'
awspemfilepath = '~w140bxj/.ssh/labsuser.pem'

#params needed for the program to run
# $1 weighttype
# $2 initialGuess.pickle
# $3 randseed
# $4 no of trys
# $5 no of batch jobs
# $6 flag for test mode 

#ssh ${fry} "pwd"
#ssh ${owens} "pwd"
#ssh ${aws} "pwd"

function usage {
    echo
    echo "========================================================================================="
    echo "syntax:"
    echo 
    echo "workflow.sh --help or workflow.sh -help or workflow.sh help : PRINTS THIS MESSAGE"
    echo
    echo "workflow.sh DISTANCEPICKLENUMBER PICKLEFILENAME RANDSEED NOOFTRYS NOOFBATCHES TESTMODE"
    echo
    echo "DISTANCEPICKLENUMBER needs to be an integer"
    echo
    echo "RANDSEED needs to be an integer value defined by the user"
    echo
    echo "PICKLEFILENAME needs to be the name of the input pickle file with total distance and initial route"
    echo
    echo "NOOFTRYS needs to be an integer"
    echo
    echo "NOOFBATCHES needs to be an integer"
    echo
    echo "TESTMODE: IS OPTIONAL. only acceptable value is 1. Setting testmode to 1 will enable the testing mode"
    echo "========================================================================================="
    echo
    echo
    exit 1
}

function help {
    echo "Help Requested"
    usage
}

function fileDNE {
    echo "The file $2 DNE"
    echo "Please enter a valid file name"
    exit 2
}

function nonInteger {
    echo "The value you've entered is not a valid integer"
    echo "You entered $1"
    echo "Please try again"
    exit 3
}


function badInput {
    echo "Following inputs received"
    echo $@
    echo "Please review program usage and try again"
    echo "==========================================================="
    usage
    exit 4
}

function getCurrentBest {
    currentbest=`ssh {owens} "source ~nehrbajo/proj03data/update03.sh $1" `
}

#file setup for fry

function guessPicklefileSetup {
    #initial Guess PickleFIle to fry
    echo "************sending first guess pickle file to fry*****************"
    scp $1  ${fry}:
  
    #scp $1  ${owens}:

    #scp -i ~w140bxj/.ssh/labsuser.pem $2 ${aws}: 

    #scp -i ~w140bxj/.ssh/labsuser.pem ~w006jwn/proj03data/tspMod.py ${aws}:
    #scp -i ~w140bxj/.ssh/labsuser.pem initialGuess.pickle ${aws}:
    #scp -i ~w140bxj/.ssh/labsuser.pem ~w006jwn/proj03data/distance0* ${aws}: 2> /dev/null
    #scp -i ~w140bxj/.ssh/labsuser.pem awsTemplate.sh ${aws}:
}

# Check for  keywords (help, -help, --help)
if [ "$1" == "help" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
    # echo "got in the help section"
    help
fi

if ! ([  "$#" == 5 ] || [ "$#" == 6 ]); then
    echo "checking if input equal 5 or 6"
    usage
fi

if [ "$#" -gt 6 ]; then
    echo "checking if inputs are more than 6"
    badInput
fi


#===========================main program loop ============
# if [ -f "TERMINATE" ]; then
#    echo "TERMINATE command found"
#    echo "Please remove the file using \"rm TERMINATE\" "
    # exit
# fi

echo "Getting best distance"
bestDistance=`ssh ${owens} "source ~nehrbajo/proj03data/update03.sh $1" `
echo "The Best Distance is "$bestDistance" "

if [ -f "SAVEDSTATE" ]; then
	echo 'Saved State found, loading values.....'
    WEIGHT=`grep "WEIGHT" SAVEDSTATE | cut -d ":" -f2`
    START=`grep "ITERNATION_STATE" SAVEDSTATE | cut -d ":" -f2`
    END=`grep "BATCH_END" SAVEDSTATE | cut -d ":" -f2`
    RANDSEED=`grep "RAND_SEED" SAVEDSTATE | cut -d ":" -f2`
    PICKLEFILE=`grep "PICKLE_FILE_NAME" SAVEDSTATE | cut -d ":" -f2`
    NOOFTRYS=`grep "NO_OF_TRYS" SAVEDSTATE | cut -d ":" -f2`

else
    #sending initial pickle files
    guessPicklefileSetup $2
    WEIGHT=$1
    START=0
    END=$5
    PICKLEFILE=$2
    RANDSEED=$3
    NOOFTRYS=$4
fi
for ((i=${START}; i<${END}; i++));
    do
        echo
        echo "Pickle File is "$PICKLEFILE" "
        echo
        #main program loop if no previous run
        fryFileName=fryJob$i.sbatch 
        owensFileName=owensJob$i.sbatch
        awsFileName=awsJob$i.sh
        sed -e 's/MYATTEMPT/'$i'/g' -e 's/MYDIR/attempt'$i'/g' -e 's/DISTANCEPICKLENUMBER/'$WEIGHT'/g' -e 's/PICKLEFILENAME/'$PICKLEFILE'/g' -e 's/RANDSEED/'$RANDSEED'/g' -e 's/NOOFTRYS/'$NOOFTRYS'/g' -e 's/LOOPSTART/0/g' -e 's/LOOPEND/15/g' fryTemplate.sbatch > $fryFileName
        sed -e 's/MYATTEMPT/'$i'/g' -e 's/MYDIR/attempt'$i'/g' -e 's/DISTANCEPICKLENUMBER/'$WEIGHT'/g' -e 's/PICKLEFILENAME/'$PICKLEFILE'/g' -e 's/RANDSEED/'$RANDSEED'/g' -e 's/NOOFTRYS/'$NOOFTRYS'/g' -e 's/LOOPSTART/16/g' -e 's/LOOPEND/32/g' owensTemplate.sbatch > $owensFileName
        sed -e 's/MYATTEMPT/'$i'/g' -e 's/MYDIR/attempt'$i'/g' -e 's/DISTANCEPICKLENUMBER/'$WEIGHT'/g' -e 's/PICKLEFILENAME/'$PICKLEFILE'/g' -e 's/RANDSEED/'$RANDSEED'/g' -e 's/NOOFTRYS/'$NOOFTRYS'/g' -e 's/LOOPSTART/16/g' -e 's/LOOPEND/32/g' aws.sh > $awsFileName
        
        echo 'sending Prepared batch template to fry'
        echo
        scp $fryFileName  ${fry}:
        echo
        scp $owensFileName ${owens}:
        echo
        scp

        echo 'running the prepared batch template in fry'
        echo
        ssh ${fry} "sbatch $fryFileName"
        echo
        # ssh ${owens} "sbatch $owensFileName"
        echo 'Putting Script to Sleep for the '$i' batch to run'
        # sleep 30s
        jobFinished=""
        while [ "$jobFinished" == '' ]
                do
                    echo 'got inside the fryfinished loop'                            
                    echo 'sleeping'
                    echo '*******************'
                    echo '****************'
                    echo '************'
                    sleep 10s
                    echo 'awake'
                    echo
                    fryFinished=`ssh ${fry} "ls attempt$i/ 2> /dev/null | grep "FINISHED" "` 
                    echo
                    # owensFinished=`ssh ${owens} "ls attempt$i/ 2> /dev/null | grep "FINISHED" "` 
                    # awsFinished=`ssh ${owens} "ls attempt$i/ 2> /dev/null | grep "FINISHED" "` 
                    echo '********************'
                    if [ "$fryFinished" == "FINISHED" ]; then
                        jobFinished="FINISHED"
                    fi
                done
        echo "JOBS FINISHED $i"
        if [ "$jobFinished" == "FINISHED" ]; then
            echo '********************************'
            echo 'about to copy file from remote to local for comparuing'
            echo
            scp ${fry}:attempt$i/'job_'$i'_detail.txt' .
            echo
            echo '*********************************'
            echo 'trying to read from the downloaded file'
            bestrunfromFry=`cat 'job_'$i'_detail.txt' | head -n 1`

            echo '*********************************'
            echo "the best distance on fry is "$bestrunfromFry" "
            # echo $bestrunfromFry
            
            

            echo '*********************************'
            echo "the current best distance is "$bestDistance" "

            if [ "$bestrunfromFry" -lt "$bestDistance" ]; then
                echo 'FOUND'
                echo '***************************CONGRATULATIONS******************'
                echo "updating the database"
                bestFileName=`cat "job_"$i"_detail.txt" | tail -n 1`
                destFileName="bestIFoundSoFar_$1_$i.txt"
                echo
                python3 utils.py 3 "$HOME/attempt$i/$bestFileName" "$destFileName"
                echo
                echo 'copying new best distaance to owens for submission'
                echo $destFileName
                scp "$destFileName" ${owens}:
                echo
                echo "copying relevant database file to home directory"
                echo
                ssh ${owens} "ln -s ~nehrbajo/proj03data/distance0"$1".pickle . 2> /dev/null"
                ssh ${owens} "ln -s ~nehrbajo/proj03data/database0"$1".txt . 2> /dev/null"
                echo 
                echo "running the update03.sh"
                echo
                echo 'removing saved state'
                if [ -f "SAVEDSTATE" ]; then
                    rm "SAVEDSTATE"
                fi
                echo
                
                if [ "$6" == 1 ]; then
                    distance=`ssh ${owens} "cat ~nehrbajo/proj03data/database0"$WEIGHT".txt | tail -n 5 | head -n 1"`
                    echo
                    path=`ssh ${owens} "cat ~nehrbajo/proj03data/database0"$WEIGHT".txt | tail -n 5 | head -n 2 | tail -n 1"`
                    echo
                    filename="database0"$i""
                    python3 utils.py 2 "$distance" "$path" "$filename"
                    echo 'bestrun from fry is '$bestrunfromFry''
                    echo 'current best distance is '$bestDistance''
                    PICKLEFILE="$filename".pickle
                    
                    echo 'sending the new best to remote servers'
                    echo
                    scp "$PICKLEFILE" ${fry}:
                    echo
                else
                    ssh ${owens} "source /users/PWSU0471/nehrbajo/proj03data/update03.sh "$WEIGHT" "$destFileName" "
                    exit
                fi
                echo
               
                                
            else
                echo '********************'
                echo 'NOBUENO'
                echo 'getting current best weight details'
                echo
                distance=`ssh ${owens} "cat ~nehrbajo/proj03data/database0"$WEIGHT".txt | tail -n 5 | head -n 1"`
                echo
                path=`ssh ${owens} "cat ~nehrbajo/proj03data/database0"$WEIGHT".txt | tail -n 5 | head -n 2 | tail -n 1"`
                echo
                filename="database0"$i""
                python3 utils.py 2 "$distance" "$path" "$filename"
                echo 'bestrun from fry is '$bestrunfromFry''
                echo 'current best distance is '$bestDistance''
                PICKLEFILE="$filename".pickle
                
                echo 'sending the new best to remote servers'
                echo
                scp "$PICKLEFILE" ${fry}:
                echo
            fi
            if [ -f "TERMINATE" ]; then
                echo 'ITERNATION_STATE':$(($i+1)) >> SAVEDSTATE
                echo 'WEIGHT':$1 >> SAVEDSTATE
                echo 'BATCH_END':$5 >> SAVEDSTATE
                echo 'RAND_SEED':$3 >> SAVEDSTATE
                echo 'PICKLE_FILE_NAME':$PICKLEFILE >> SAVEDSTATE
                echo 'NO_OF_TRYS':$4 >> SAVEDSTATE
                rm "TERMINATE"
                exit 

            fi
        fi

    done