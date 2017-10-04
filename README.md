# PesterExams
Prepackaged Pester tests for applications.

## Getting Started
 - [Pester GitHub](https://github.com/pester/Pester)
 - [Pester Wiki](https://github.com/pester/Pester/wiki/Pester)
 - [Hey Scripting Guy!](https://blogs.technet.microsoft.com/heyscriptingguy/2015/12/14/what-is-pester-and-why-should-i-care/)

## Importing config and executing tests
```powershell
function ConvertPSObjectToHashtable{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process{
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]){
            $collection = @(
                foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject]){
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties){
                $hash[$property.Name] = ConvertPSObjectToHashtable $property.Value
            }

            $hash
        }
        else{
            $InputObject
        }
    }
}

$Config = Get-Content -path Config\Config.json | ConvertFrom-Json | ConvertPSObjectToHashtable
Invoke-Pester -Script .\Diagnostics\Simple
```