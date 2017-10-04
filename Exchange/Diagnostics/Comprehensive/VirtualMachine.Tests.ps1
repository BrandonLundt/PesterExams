Describe -Name "Exchange Virtual Machine - Comprehensive Validation" -Tags @("Simple", "Virtual Machine") -Fixture {
	Context -Name "Remote Connectivity" -Fixture {
		It -Name "<ComputerName> is available from WSMan" -TestCases $Config.ClientAccessServer -test {
			Param($ComputerName)
			Test-Connection -ComputerName $ComputerName -Count 1 -Quiet | Should be $true
			Test-WSMan -ComputerName $ComputerName | Should not beNullOrEmpty
		} #It WSMAN available
		It -Name "<ComputerName> is available from WSMan" -TestCases $Config.MailboxServer -test {
			Param($ComputerName)
			Test-Connection -ComputerName $ComputerName -Count 1 -Quiet | Should be $true
			Test-WSMan -ComputerName $ComputerName | Should not beNullOrEmpty
		} #It WSMAN available
	}
	<#
		Enabling the Dcom protocol allows this to work with PowerShell 2.0.
		Removing this will speed up the queries, but remove backwards compatibility
	#>
	$Opt = New-CimSessionOption -Protocol Dcom
	Context -Name "Windows OS Resources Validation" -Fixture {
		<#
			This doesn't give the specific drive that is low on space, it does however indicate that something is wrong.
			Opening an issue in GitLab to review this later. For now, this is acceptable, it won't be later.
		#>
		It -Name "<ComputerName> Client Access Drive Space greater than 10% free" -TestCases $Config.ClientAccessServer -test {
			Param($ComputerName)
			$Cim_Session = New-CimSession -ComputerName $ComputerName -Credential $Credential -SessionOption $Opt
			Get-CimInstance -ClassName win32_volume -CimSession $Cim_Session | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
				($_.FreeSpace / $_.Capacity) * 100 | Should begreaterthan 10
			} #Foreach-Object
			Remove-CimSession -CimSession $Cim_Session
		}#It
		It -Name "<ComputerName> Client Access Drive Space greater than 10% free" -TestCases $Config.MailboxServer -test {
			Param($ComputerName)
			$Cim_Session = New-CimSession -ComputerName $ComputerName -Credential $Credential -SessionOption $Opt
			Get-CimInstance -ClassName win32_volume -CimSession $Cim_Session | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
				($_.FreeSpace / $_.Capacity) * 100 | Should begreaterthan 10
			} #Foreach-Object
			Remove-CimSession -CimSession $Cim_Session
		}#It
		<#
			The following checks if any service set to automatic is running.
		#>
		It -Name "<ComputerName> Services Running" -TestCases $Config.ClientAccessServer -test {
			Param($ComputerName)
			$Cim_Session = New-CimSession -ComputerName $ComputerName -Credential $Credential -SessionOption $Opt
			Get-CimInstance -ClassName Win32_Service -CimSession $CIM_Session -filter "startmode='auto' and state<>'running'" | Should be NullOrEmpty
			Remove-CimSession -CimSession $Cim_Session
		} #It
		It -Name "<ComputerName> Services Running" -TestCases $Config.MailboxServer -test {
			Param($ComputerName)
			$Cim_Session = New-CimSession -ComputerName $ComputerName -Credential $Credential -SessionOption $Opt
			Get-CimInstance -ClassName Win32_Service -CimSession $CIM_Session -filter "startmode='auto' and state<>'running'" | Should be NullOrEmpty
			Remove-CimSession -CimSession $Cim_Session
		} #It
	}#Context
}#Describe