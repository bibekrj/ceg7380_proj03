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

#awspemfilepath = '-i ~w140bxj/.ssh/labsuser.pem'

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

function editTemplates {
    #   singularity exec -B /home/w006jwn/proj03data -B /home/w006jwn/proj03data/tspMod.py ~w006jwn/python3.sif python3 /home/w006jwn/proj03data/tspMod.py DISTANCEPICKLENUMBER PICKLEFILENAME $(($task+RANDSEED)) NOOFTRYS &   
    # $1 Batch Job Number
    # $2 distance pickle number 0-9
    # $3 pickle file name -- starts with initial guess
    # $4 random seed provided by the user
    # $5 number of trys provided by the user
    # $6 batch job number 
    # $7 start of the forloop template
    # $8 end of the forloop in template
    # $9 filename to attach to

    sed -e 's/MYATTEMPT/$1/g' -e 's/MYDIR/attempt$1/g' -e 's/DISTANCEPICKLENUMBER/$2/g' -e 's/PICKLEFILENAME/$3/g' -e 's/RANDSEED/$4/g' -e 's/NOOFTRYS/$5/g' -e 's/LOOPSTART/$7/g' -e 's/LOOPEND/$8/g' fryTemplate.sbatch > $9
    sed -e 's/MYATTEMPT/$1/g' -e 's/MYDIR/attempt$1/g' -e 's/DISTANCEPICKLENUMBER/$2/g' -e 's/PICKLEFILENAME/$3/g' -e 's/RANDSEED/$4/g' -e 's/NOOFTRYS/$5/g' -e 's/LOOPSTART/$7/g' -e 's/LOOPEND/$8/g' owensTemplate.sbatch > $9
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

if [ "$#" -gt 5 ]; then
    echo "checking if inputs are more than 5"
    badInput
fi


#===========================main program loop ============
echo "1. Getting best distance"
bestDistance=`ssh ${owens} "source ~nehrbajo/proj03data/update03.sh $1" `
echo "Best Distance is "$bestDistance" "

if [ -f "SAVEDSTATE" ]; then
	#load starting val, ending val for number of batches from the saved state file
    #randomSeed Val
    #nofOf Trys
    #load the values
    
        #for (( i=$StartVal; i<$endVal; i++ ));
        #for ((i=0; i<$5; i++));
         ##  echo 'doing nothing'
            #echo $(( $i+1 ))
            #if [ $(( $i+1 )) -eq 300 ]; then
            #    touch TERMINATE
            #    break
            #fi
            #sleep 1s

            #program loop for when we have saved values
        #done
        echo 'Saved State found, loading values.....'
else
    #sending pickle files
    guessPicklefileSetup $2

    START=0
    END=$5
    PICKLEFILE=$2
    for ((i=${START}; i<${END}; i++));
        do
            echo
            echo "Pickle File is "$PICKLEFILE" "
            echo
            #main program loop if no previous run
            fryFileName=fryJob$i.sbatch 
            owensFileName=owensJob$i.sbatch
            sed -e 's/MYATTEMPT/'$i'/g' -e 's/MYDIR/attempt'$i'/g' -e 's/DISTANCEPICKLENUMBER/'$1'/g' -e 's/PICKLEFILENAME/'$PICKLEFILE'/g' -e 's/RANDSEED/'$3'/g' -e 's/NOOFTRYS/'$4'/g' -e 's/LOOPSTART/0/g' -e 's/LOOPEND/15/g' fryTemplate.sbatch > $fryFileName
            #sed -e 's/MYATTEMPT/'$i'/g' -e 's/MYDIR/attempt'$i'/g' -e 's/DISTANCEPICKLENUMBER/'$1'/g' -e 's/PICKLEFILENAME/'$2'/g' -e 's/RANDSEED/'$3'/g' -e 's/NOOFTRYS/'$4'/g' -e 's/LOOPSTART/16/g' -e 's/LOOPEND/32/g' owensTemplate.sbatch > $owensFileName
            
            echo 'sending Prepared batch template to fry'
            echo
            scp $fryFileName  ${fry}:
            echo
            # scp $owensFileName ${owens}:

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
                scp ${fry}:attempt$i/'best_'$i'_detail.txt' .
                echo
                echo '*********************************'
                echo 'trying to read from the downloaded file'
                bestrunfromFry=`cat 'best_'$i'_detail.txt' | head -n 1`

                echo '*********************************'
                echo "the best distance on fry is "$bestrunfromFry" "
                # echo $bestrunfromFry
                
                

                echo '*********************************'
                echo "the current best distance is "$bestDistance" "

                if [ "$bestrunfromFry" -lt "$bestDistance" ]; then
                    echo 'FOUND'
                    echo '***************************CONGRATULATIONS******************'
                
                else
                    echo '********************'
                    echo 'NOBUENO'
                    echo 'getting current best weight details'
                    echo
                    distance=`ssh ${owens} "cat ~nehrbajo/proj03data/database0"$1".txt | tail -n 5 | head -n 1"`
                    echo
                    path=`ssh ${owens} "cat ~nehrbajo/proj03data/database0"$1".txt | tail -n 5 | head -n 2 | tail -n 1"`
                    echo
                    filename="database0"$1""
                    python3 utils.py 2 "$distance" "$path" "$filename"
                    echo 'bestrun from fry is '$bestrunfromFry''
                    echo 'current best distance is '$bestDistance''
                    PICKLEFILE="$filename".pickle
                    
                    echo 'sending the new best to remote servers'
                    echo
                    scp "$PICKLEFILE" ${fry}:
                    echo
                fi
            fi

        done
        
fi
    


if [ -f "TERMINATE" ]; then
   echo "TERMINATE command found"
   echo "Please remove the file using \"rm TERMINATE\" "
fi
