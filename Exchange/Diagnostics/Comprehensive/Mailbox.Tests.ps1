<# will need to be connected to Exchange for this to work
    Will release a function soon to connect from anywhere.
#>
Describe -Name "Database Health and Configuration" -Tag @("Database", "Simple") -Fixture {
	Context -Name "Database Health" -Fixture {
		It -name "<Name> Active on <PrimaryServer>" -TestCases $Config.MailboxDatabase -test {
			param($Name,$PrimaryServer)
			$Result = Get-MailboxDatabase -Identity $Name
			#($Result.ActivationPreference | Where-Object {$_.Value -eq 1}).Key | should be $PrimaryServer
			$Result.Server | should be $PrimaryServer
		}# Active on Primary Server
		<#
			The following IT statement could be done better
			I went with this approach for now as it allows for use of testcases
			and only makes one call into Exchange.
		#>
		It -name "<Name> Index,Copy Length and Status" -testcases $Config.MailboxDatabase -test {
			param($Name)
			Get-MailboxDatabaseCopyStatus -Identity $name | Foreach-Object -Process{
				$_.ContentIndexState | should be "Healthy"
				$_.CopyQueueLength | should belessthan 100
				$_.status | should Not Be 'Failed'
				$_.status | should Not Be 'Resynchronizing'
			}
		}#It Index,Copy Length and Status
	}#Context Database health
}#Describe