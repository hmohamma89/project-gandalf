#!/bin/bash 

protected_branch='master'
# Check if we actually have commits to push
commits=`git log @{u}..`
if [ -z "$commits" ]; then
    exit 0
fi

current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [[ $current_branch = $protected_branch ]]; then
	echo "Runing unit tests"
    c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -File .\\scripts\\run-tests.ps1 # Command that runs your tests
    RESULT=$?
    echo  "the result is: $RESULT"
    if [ $RESULT -ne 0 ]; then 
        echo "unit tests failed please fix them before you push to the git repository"
        exit 1
    fi
fi
exit 0