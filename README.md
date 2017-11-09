# Project Title

We all strive to achieve great quality code. Every language allows us to run some quality checks or automatic unit tests. But even best tests won't help, if they aren't run often.
Remember! If something takes too much time or effort, people will avoid it!
Solution?
Automate all the things
We can reverse that! Let's make automatic tests effortless, and add additional overhead for avoiding them.
Not everyone knows that, but git allows us to inject many helpful hooks into our workflow.
Each hook is a single executable script, preferably with a shebang line. Git looks for hooks inside .git/hooks directory. Besides having right name, script have to be executable to be run.
I have chosen the pre-push hook to intercept and prevents push to remote server when unit tests are failing.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.


### Prerequisites

What things you need to install or have on oyur local machine 

```
git
gitbash
powershell
mstest
visual studio
```
You need to have a .Net solution that includes unitTest project/projects which were build with mstest and that follows this naming convention (Ends-with"Tests") for test project name.
### Installing

steps to install this git hook:

1. Copy the script folder to your solution folder so it lays in the root folder for the solution, besides the .git folder
```
Files to Acknowledge:
install-hook.sh -> its the script that installs the pre-push hook for your local git
pre-push.sh -> its the script that defines what needs to happen before your code gets pushed to remote git
run-tests.ps1 -> its the script that gathers the unit test and runs with mstest and then reports back the result to the pre-push.sh script 
```

2. Create a testSetting file by right-clicking on the solution item in VS, choose add -> New item -> search for  "Test Settings".
This will open a test setting creation wizard, in there you just need click apply and then close the wizard
```
Files to Acknowledge:
TestSettings1.testsettings -> its testsettings file that tells mstest what kind configuration we will run the unittests with
```

3. Modifiy the setup parameters in pre-push.sh script to match your setup
```
Example:
SOLUTIONPATH="D:\git-hooks-tests" # required:true type:string, name of result file to save test results to
TESTFILESTOEXCLUDE="Unit2Tests,Unit3Tests" # required:true type:string("comma seperated"), test projects to exclude from the hook
MSTEST="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe"  # required:true type:string, path to the mstest.exe
TESTSETTINGFILEPATH="D:\git-hooks-tests\TestSolution\TestSettings1.testsettings" #required:true type:string, path to the testSettingFile, usually lays in ".\*Solution*\TestSettings1.testsettings"  
```

4. Feel free to install our hook (everyone in your team has to do that, but only once). Write the following i a gitbash window and press enter:
```
./scripts/install-hooks.sh  
```

5. Build your solution

6. Now, every time when someone will try to push a commit/commits, all tests must pass to allow that.

Passing result output:
```
Pushing to https://github.com/XXXX/git-hooks-tests.git
-----------------------------------------------
Solutions path: D:\git-hooks-tests
Test .dll Files to exclude: Unit2Tests,Unit3Tests
Mstest path: C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe
TestSettingFile path: D:\git-hooks-tests\TestSolution\TestSettings1.testsettings
-----------------------------------------------
Running unit tests

Loading D:\git-hooks-tests\TestSolution\TestSettings1.testsettings...
Loading D:\git-hooks-tests\TestSolution\UnitTests\bin\Debug\UnitTests.dll...
Starting execution...

Results               Top Level Tests
-------               ---------------
Passed                UnitTests.ServiceTest.ShouldReturnTrue

1/1 test(s) Passed

Summary
-------
Test Run Completed.
  Passed  1
  ---------
  Total   1
Results file:  D:\git-hooks-tests\testresults.txt
Test Settings: TestSettings1

Test Results: Completed
Total tests: 1
Passed: 1
Failed: 0

Gandalf Approves, see you next time!
Finally block reached  
```

Failing result output:
```
Pushing to https://github.com/XXXX/git-hooks-tests.git
-----------------------------------------------
Solutions path: D:\git-hooks-tests
Test .dll Files to exclude: Unit2Tests,Unit3Tests
Mstest path: C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe
TestSettingFile path: D:\git-hooks-tests\TestSolution\TestSettings1.testsettings
-----------------------------------------------
Runing unit tests
c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -File .\scripts\run-tests.ps1 -solutionPath D:\git-hooks-tests -testFilesToExclude Unit2Tests,Unit3Tests -mstest C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe -testSettingFilePath D:\git-hooks-tests\TestSolution\TestSettings1.testsettings

Loading D:\git-hooks-tests\TestSolution\TestSettings1.testsettings...
Loading D:\git-hooks-tests\TestSolution\UnitTests\bin\Debug\UnitTests.dll...
Starting execution...

Results               Top Level Tests
-------               ---------------
Failed                UnitTests.ServiceTest.ShouldReturnTrue
[errormessage] = Test method UnitTests.ServiceTest.ShouldReturnTrue threw exception: 
Microsoft.VisualStudio.TestTools.UnitTesting.AssertFailedException: Assert.AreEqual failed. Expected:<True>. Actual:<False>. 

0/1 test(s) Passed, 1 Failed

Summary
-------
Test Run Failed.
  Failed  1
  ---------
  Total   1
Results file:  D:\git-hooks-tests\testresults.txt
Test Settings: TestSettings1


Test Results: Failed
Total tests: 1
Passed: 0
Failed: 1

Failed test: ShouldReturnTrue
Test method UnitTests.ServiceTest.ShouldReturnTrue threw exception: 
Microsoft.VisualStudio.TestTools.UnitTesting.AssertFailedException: Assert.AreEqual failed. Expected:<True>. Actual:<False>. 
at UnitTests.ServiceTest.ShouldReturnTrue() in D:\git-hooks-tests\TestSolution\UnitTests\ServiceTest.cs:line 26

You Shall Not Pass!!!
Finally block reached

Your unit tests are failing please fix them before you push to your git repository
```

## Authors

* **Hamdoon Mohammad** - *System Developer* - hamdoon.mohammad@wipcore.se
