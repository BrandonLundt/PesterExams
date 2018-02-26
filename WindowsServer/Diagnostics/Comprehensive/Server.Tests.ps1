Describe -Name "Exchange Virtual Machine - Simple Validation" -Tags @("Simple", "Virtual Machine") -Fixture {
	Context -Name "Remote Connectivity" -Fixture {
		It -Name "<ComputerName> is available from WSMan" -TestCases $Config.ComputerName -test {
			Param($Name)
            
			Test-Connection -ComputerName $Name -Count 1 -Quiet | Should -Be $true -Because "We need to be able to connect to the Server remote to test it"
			Test-WSMan -ComputerName $Name | Should -Not -BeNullOrEmpty -Because "If the result is null, test-WSMan was not able to connect"
		} #It WSMAN available
	}
	<#
		This doesn't give the specific drive that is low on space, it does however indicate that something is wrong.
		For now, this is acceptable, it won't be later.
	#>
	$Opt = New-CimSessionOption -Protocol Dcom
	Context -Name "Windows OS Resources Validation" -Fixture {
		It -Name "<Name> Drive Space greater than 10% free" -TestCases $Config.ComputerName -test {
			Param($Name)
			$Cim_Session = New-CimSession -ComputerName $Name -SessionOption $Opt
			Get-CimInstance -ClassName win32_volume -CimSession $Cim_Session | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
				($_.FreeSpace / $_.Capacity) * 100 | Should -BeGreaterThan 10 -Because "A full drive isn't helpful...to anyone"
			} #Foreach-Object
			Remove-CimSession -CimSession $Cim_Session
		}#It
        Foreach( $Computer in $Config.ComputerName){
            $Cim_Session = New-CimSession -ComputerName $Computer.Name -SessionOption $Opt
		    It -Name ($Computer.Name + " <Name> Configured Correctly") -TestCases $Computer.Service -test {
			    Param($Name,$State,$Status,$StartMode)
			    $Result = Get-CimInstance -ClassName Win32_Service -CimSession $CIM_Session -filter "name like '$Name'" 
                $Result | Should -Not -BeNullOrEmpty -Because "Get-CimInstance should have returned some type of data, this confirms the service exists on the remote system"
                $Result.State | Should -Be $State -Because "We are expecting this service to be in a state of $State"
                $Result.Status | Should -Be $Status -Because "We expect our service to be of status $Status"
                $Result.StartMode | Should -Be $StartMode -Because "We expect our service to be of startup type $StartMode"
		    }#It
            Remove-CimSession -CimSession $Cim_Session
        }
	}#Context
}#Describe