$inputFile = "detroit_index.txt"
$outputFile = "detroit_outputfile.txt"
$getInfoUri = "https://mvic.sos.state.mi.us/Voter/SearchByName"

$inputData = Import-Csv -Path $inputFile

$outputRstInfo = @()

foreach ($item in $inputData)
{
    Write-Host "Processing [$($item.FIRST_NAME) $($item.LAST_NAME)] borned at [$($item.YEAR_OF_BIRTH)] from [$($item.ZIP_CODE)]..." -ForegroundColor Yellow

    $postParams = @{
        FirstName      = $item.FIRST_NAME;
        LastName       = $item.LAST_NAME;
        NameBirthYear  = $item.YEAR_OF_BIRTH;
        ZipCode        = $item.ZIP_CODE
    }

    # We don't know the birth month, so iterate from 1 to 12 here.
    foreach ($month in @('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'))
    {
        if ($postParams.ContainsKey("NameBirthMonth"))
        {
            $postParams.NameBirthMonth = $month
        }
        else
        {
            $postParams.Add("NameBirthMonth", $month)
        }

        $rst = Invoke-WebRequest -Uri $getInfoUri -Method Post -Body $postParams
        $validInfo = $rst.AllElements | Where-Object { $_.id -eq "lblAbsenteeVoterInformation" }

        if ($validInfo)
        {
            $foundballotReturnDate = $validInfo.innerHTML -match 'Ballot received</B><BR>(?<ballotRetDate>\d{1,2}\/\d{1,2}\/2020)<BR>'
            if ($foundballotReturnDate)
            {
                $retDate = $Matches.ballotRetDate
                Write-Host "Found ballot returned at [$retDate]!" -ForegroundColor Green
                $postParams.Add("BallotReturnDate", $retDate)

                $outputRstInfo += $postParams
                break
            }
        }
    }
}

$outputRstInfo | ConvertTo-Json | Out-File $outputFile
