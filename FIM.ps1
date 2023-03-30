
Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline?"
Write-Host "B) Begin Monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
#Write-Host  "User entered $($response)"
Write-Host ""

Function Calculate-File-Hash($filepath){
    $filepath = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filepath
}

Function Erase-Baseline-If-Already-Exist(){
    $baselineExist = Test-Path -Path  .\Desktop\Project\FIM\Files/baseline.txt

    if ($baselineExist){
        #Delete
        Remove-Item -Path .\Desktop\Project\FIM\Files/baseline.txt
    }
   
    
}
if ($response -eq "A".ToUpper()){
    #Delete baseline if exist 
    Erase-Baseline-If-Already-Exist

    #Calculate hash from the target files and store  in the baseline.txt
    #Collect all the files in the folder 
    $files = Get-ChildItem -Path.\Desktop\Project\FIM\Files
    
    #For each file calculate the hash, and write to baseline.txt
    foreach ($f in $files){
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\Desktop\Project\FIM/baseline.txt -Append
       
    }


}
elseif ($response -eq "B".ToUpper()){
    #Load file hash from baseline.txt and store them in a dictonary
    $fileHashDictonary = @{}
    $filePathAndHashes = Get-Content -Path  .\Desktop\Project\FIM/baseline.txt

    foreach ($f in $filePathAndHashes){
        $fileHashDictonary.add($f.Split("|")[0], $f.Split("|")[1])
    }
 
    #$fileHashDictonary
    #Begin monitoring files with saved baseline
    while($true) {
        Start-Sleep -Seconds 1

        #Collect all the files in the folder 
        $files = Get-ChildItem -Path.\Desktop\Project\FIM\Files
    
        #For each file calculate the hash, and write to baseline.txt
        foreach ($f in $files){
            $hash = Calculate-File-Hash $f.FullName
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\Desktop\Project\FIM/baseline.txt -Append
            
            #Notify if a new file has been created
            if ($fileHashDictonary[$hash.Path] -eq $null){
                # A new file created 
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
            }

            else{
                if ($fileHashDictonary[$hash.Path] -eq $hash.Hash) {
                    # The file has not changed.
                }
                else{
                    Write-Host "$($hash.Path) has been changed!!!" -ForegroundColor Yellow
                }
            }
         


    }
       foreach ($key in $fileHashDictonary.Keys) {
                $baselineFileExists = Test-Path -Path $key
                if ( -Not $baselineFileExists) {
                    # One of the baseline file has beeen deleted!!
                    Write-Host "$($key) has been deleted!!!" -ForegroundColor Red

                }
            }

}
}