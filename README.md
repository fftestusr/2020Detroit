# Summary
There is a file named "detroid_index.txt" spreaded on internet https://pastebin.com/zjz6nm6Q.
The script in this repo is used to check if users listed in that file turned in their ballot in 2020 U.S. election.

## PowerShell Script
This is a very simple PowerShell script that could be understand quickly but not very efficient as it is a simple for iteration call with time complexity of O(n).

## Python Script
Slightly faster than the PowerShell one using the grequests module but still simple without any optimization. Also, not sure if the website will block the request considering about 170K request sent with this script by grequests.
