import re
import csv
import json
import grequests

inputFile = "C:\\Users\\kfang\\Downloads\\detroit_index.txt"
outputFile = "C:\\Users\\kfang\\Downloads\\detroit_outputfile_py.txt"
getInfoUri = "https://mvic.sos.state.mi.us/Voter/SearchByName"

monthArray = ["1","2","3","4","5","6","7","8","9","10","11","12"]

req_list = []

with open(inputFile) as csvInputFile:
    csvDictReader = csv.DictReader(csvInputFile)
    for row in csvDictReader:
        postDataBase = {
            'FirstName': row["FIRST_NAME"],
            'LastName': row["LAST_NAME"],
            'NameBirthYear': row["YEAR_OF_BIRTH"],
            'ZipCode': row["ZIP_CODE"]
        }

        for month in monthArray:
            postDataForm = postDataBase.copy()
            postDataForm["NameBirthMonth"] = month
            req_list.append(grequests.post(getInfoUri, data = postDataForm ))

res_list = grequests.map(req_list)

ballotRetDateRegExp = re.compile('<b>Ballot\s+received<\/b><br\s*\/>(\d{1,2}\/\d{1,2}\/2020)<br\s*\/>')

ballotRet_list = []

i = 0
for rst in res_list:
    i = i + 1
    if rst is not None:
        ballotRetDateInfo = ballotRetDateRegExp.search(rst.text)
        if ballotRetDateInfo:
            tmpDict = dict((x.strip(), y.strip())
                        for x, y in (element.split('=')
                        for element in rst.request.body.split('&')))
            tmpDict["BallotRetDate"] = ballotRetDateInfo.group(1)
            ballotRet_list.append(tmpDict)
    else:
        print("No Result.")

with open(outputFile, 'w') as outfile:
    json.dump(ballotRet_list, outfile)
