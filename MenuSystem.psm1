<######################################################################
	Multi Layered Dynamic Menu System 
    Copyright (C) 2015  Ashley Unwin, www.AshleyUnwin.com
	
	It is requested that you leave this notice in place when using the
	Menu System.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    the latest version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
######################################################################>



function global:Use-Menu {

<#
.SYNOPSIS
 
 A system designed to take a hashtable input and layout a multi level options menu.
 
.DESCRIPTION

 The command takes an input of nested hash tables and creates a menu system where the hash table keys are the menu options, and teh values are either function names or further hash tables representing deeper levels of menu. 

.PARAMETER
 
 <MenuHash>
 Defines a HashTable or Nested HashTables that create the layout of the menu. Keys are Menu Options, if the value is another HashTable then it links to the sub-menu, if the value is just a value it attempts to run a function with that name.')]

.PARAMETER
 
 <xContinue>
 A $True value lets the system know this is a continuation from a previous Menu Loop, No value or a $False value resets the menu to the top level.

.PARAMETER

 <NoSplash>
 A $True value prevents the Splash Screen from appearing, no value or a $False value allows the Splash Screen to run.

.PARAMETER

 <SelectionHist>
 Contains information about the previously selected menu options in an array.

.PARAMETER

 <Title>
 Defines the menu title at the top of the page.

.EXAMPLE

Create a Menu from a simple Hash Table

Use-Menu -MenuHash $xMenuHash 
 
.EXAMPLE

 Create a Menu from an imported CSV file and set each value with a function name.
 Then run the menu and capture the return from the functions.
 
 $csv | foreach-object {
			$xMenuHash.add($_.Company,"fSetupCompany -xCompany "+$_.company)
		}
 $xReturn = Use-Menu -MenuHash $xMenuHash -Title $xTitle -NoSplash 1

.NOTES

 The system could theoretically take unlimited levels of sub-menus but the run time of each cycle will increase exponentionally 

.LINK
 http://www.ashleyunwin.com/powershell-multi-layered-dynamic-menu-system/

#>



[CmdletBinding()]

PARAM(

[Parameter(position=0,
HelpMessage='Defines a HashTable or Nested HashTables that create the layout of the menu. Keys are Menu Options, if the value is another HashTable then it links to the sub-menu, if the value is just a value it attempts to run a function with that name.')]
[HashTable]$MenuHash=@{ 
	"1a"=@{	"1a 2a"="1a2aValue"
			"1a 2b"="1a2bValue"
			"1a 2c"="1a2cValue"}
	"1b"=@{	"1b 2a"=@{
				"1b 2a 3a"=@{
					"1b 2a 3a 4a"=@{
						"1b 2a 3a 4a 5a"="1b2a3a4a5aValue"
						"1b 2a 3a 4a 5b"="1b2a3a4a5bValue"
						"1b 2a 3a 4a 5c"="1b2a3a4a5aValue"}
					"1b 2a 3a 4b"="1b2a3a4bValue"
					"1b 2a 3a 4c"="1b2a3a4cValue"}
				"1b 2a 3b"="1b2a3bValue"
				"1b 2a 3c"="1b2a3cValue"}
			"1b 2b"="1b2bValue"
			"1b 2c"="1b2cValue"}
	"1c"=@{	"1c 2a"="1c2aValue"
			"1c 2b"="1c2bValue"
			"1c 2c"="1c2cValue"}
	"1d"="1dValue"},
	
[Parameter(position=1,
HelpMessage='A $True value lets the system know this is a continuation from a previous Menu Loop, No value or a $False value resets the menu to the top level.')]
[bool]$xContinue,

[Parameter(position=2,
HelpMessage='A $True value prevents the Splash Screen from appearing, no value or a $False value allows the Splash Screen to run.')]
[bool]$NoSplash,

[Parameter(position=3,
HelpMessage='Contains information about the previously selected menu options in an array.')]
$SelectionHist,

[Parameter(position=4,
HelpMessage='Defines the menu title at the top of the page.')]
[string]$Title="System Menu",

[Parameter(position=5,
HelpMessage='Should the menu auto sort the list .')]
[bool]$NoSort = 0 
)

	Begin{}

	Process{

		#Run Splash Screen unless requested not to or if not in first loop
		if ($NoSplash -ne $true) {
			if ($xContinue -ne $true) {
				Start-SplashScreen
			}
		}

		#Check we have an array
		if ($MenuHash -ne $null) {
			
			#Set the Current Menu to be the whole array
			$CurrentMenu=$MenuHash
			
			#Check if we are continuing from a previous loop
			if ($xContinue) {
			$global:SelectionHist = $SelectionHist
			}else{
			#If we are not continuing then ensure the selection history is blank to reset to top level menu
			$SelectionHist = $null
			}
			
			
			if ($SelectionHist -ne $null) {
				#If its not null run through each of the previous menu levels setting the current menu to each level until we reach the level required
				ForEach ($item in $SelectionHist){
					$CurrentMenu = $CurrentMenu[$item]
				}
			}else{
				#If selection history was null, create the selection history object as an array list
				$SelectionHist = New-Object System.Collections.ArrayList
			}
			

			
			#Start writing the menu headers
			cls
			Write-Host "`n`t$title`n`n" -ForegroundColor Magenta
			Write-Host "`t`tPlease select the option you require`n" -Fore red
			
			#Reset variables used to create each loop
			$i=1
			$array=@("0")
			
			If ($NoSort) {
				$Menu = $CurrentMenu.keys
			}else{
				$Menu = $CurrentMenu.keys | sort-object
			}
			
			#Run through the Keys in the hash table in alphabetical order
			foreach ($MenuItem in $Menu) { 
				#Look to see if its a menu or a function
				if ($CurrentMenu[$menuitem] -is [hashtable]) {
					write-host "`t`t" $i "-" $MenuItem "Menu" -Fore Cyan
				}else{
					write-host "`t`t" $i "-" $MenuItem -Fore Green
				}
				#Create an array linking the $i number to the Menu Item displayed
				if ($array[$i]) {
					$array[$i]= $MenuItem
				} else {
					$array+= $MenuItem
				} 
				$i++ 
			}
			
			#Only print previous option when there is a previous
			if ($selectionhist.count -gt 0) {
				write-host "`n`t`t P - Previous Menu" -ForegroundColor DarkYellow
				write-host "`t`t Q - Exit Menu" -ForegroundColor Red
			}else {
				write-host "`n`t`t Q - Exit Menu" -ForegroundColor Red
			}
			
			#Collect the users input
			[string]$xInput = Read-Host "`n`tEnter Menu Option Number"
			
			#If they entered no input then error for a few seconds then re-print the same menu
			if ($xInput -eq "") {		
					cls
					write-host "`n`n`t`tThat was not a valid selection" -ForegroundColor Red
					start-sleep -s 1
					Use-Menu -MenuHash $MenuHash -selectionhist $selectionhist -xcontinue 1 -title $title
			}

			#If they said Quit, Quit
			if ($xInput -eq "q") {
				cls
				$global:Quit = $true
				return
			}
			
			#If they said Previous Menu
			if ($xInput -eq "p"){
				#Count how many items in selection history (remove 1 for some unknown reason)
				$q = $selectionhist.count - 1
				#Remove the last item in the array, in order to allow moving back one level
				$selectionhist.removerange($q,1)
				#Jump to the start sending the Hash and selection history along, also say this is a continuation and not a fresh call for the menu. 
				Use-Menu -MenuHash $MenuHash -selectionhist $selectionhist -xcontinue 1 -title $title
				return
			}
			
			#If they didn't say Q or P, check if input is a number (it wont be, it was a string)
			if ($xInput -is [int]){
			}else{
				#Convert string to integer
				[int]$xInput = $xInput
				#Hide the error if the input was actually some random letter
				cls
			}
			
			#If they entered a number it will now be an integer not a string
			if ($xInput -is [int] ) {
				#Check if its a valid number
				if ($xInput -lt $array.count) {
					#Lookup the number entered and find its value from the array of $i to menu items, Store this in a new variable
					$xInput2 = $array[$xInput]
					#Lookup that option in the current menu and see if we get a hash (another menu) or a value (a function to run)				
					if ($CurrentMenu[$xInput2] -is [hashtable]) {	
						#if its a new menu then add the option to the selection history
						$selectionhist.add($xInput2)
						#Jump to the start sending the Hash and selection history along, also say this is a continuation and not a fresh call for the menu.
						Use-Menu -MenuHash $MenuHash -SelectionHist $SelectionHist -xContinue $true -Title $Title
					}else{
						#If we didn't get a hash, then it must be a value of which we need to run the corresponding function and quit the menu
						cls
						$xResult = invoke-expression $CurrentMenu[$xInput2]
						return $xResult
					}
				} else {
				#If its not a Valid number
				cls
				write-host "`n`n`t`tThat was not a valid selection" -ForegroundColor Red
				start-sleep -s 1
				Use-Menu -MenuHash $MenuHash -SelectionHist $SelectionHist -xContinue $True -Title $Title
				}
			} else {
				#If they entered some random character then error for a few seconds then re-print the same menu
				cls
				write-host "`n`n`t`tThat was not a valid selection" -ForegroundColor Red
				start-sleep -s 1
				Use-Menu -MenuHash $MenuHash -SelectionHist $SelectionHist -xContinue $True -Title $Title
			}	
		}	

	}

	End{}
	
}				

function global:Start-SplashScreen {
	#Creates a basic Splash Screen function to credit the author. 
	#To prevent this Splash Screen from showing use the 'Use-Menu -NoSplash $true' option when calling the menu system
	PARAM(
	[int]$xSleep = 1
	)
	cls
	Write-Host "`n"
	Write-Host "`t`t*******************************" -ForegroundColor Red
	Write-Host "`t`t*   A Multi-Layered Dynamic   *" -ForegroundColor Red
	Write-Host "`t`t*        Menu System          *" -ForegroundColor Red
	Write-Host "`t`t*                             *" -ForegroundColor Red
	Write-Host "`t`t*   Created by Ashley Unwin   *" -ForegroundColor Red
	Write-Host "`t`t*     www.AshleyUnwin.com     *" -ForegroundColor Red
	Write-Host "`t`t*******************************" -ForegroundColor Red
	start-sleep -s $xSleep
	}

##################################### Demo functions to work with defaults #####################################
function 1a2aValue {Write-host "Running Function 1a 2a Value"}
function 1a2bValue  {Write-host "Running Function 1a 2b Value"}
function 1a2cValue {Write-host "Running Function 1a 2c Value"}
function 1b2a3a4a5aValue {Write-host "Running Function 1b 2a 3a 4a 5a Value"}
function 1b2a3a4a5bValue {Write-host "Running Function 1b 2a 3a 4a 5b Value"}
function 1b2a3a4a5cValue {Write-host "Running Function 1b 2a 3a 4a 5a Value"}
function 1b2a3a4bValue {Write-host "Running Function 1b 2a 3a 4b Value"}
function 1b2a3a4cValue {Write-host "Running Function 1b 2a 3a 4c Value"}
function 1b2a3bValue {Write-host "Running Function 1b 2a 3b Value"}
function 1b2a3cValue {Write-host "Running Function 1b 2a 3c Value"}
function 1b2bValue {Write-host "Running Function 1b 2b Value "}
function 1b2cValue {Write-host "Running Function 1b 2c Value"}
function 1c2aValue {Write-host "Running Function 1c 2a Value"}
function 1c2bValue {Write-host "Running Function 1c 2b Value"}
function 1c2cValue {Write-host "Running Function 1c 2c Value"}
function 1dValue {Write-host "Running Function 1d Value"}
##################################### END of Demo Functions #####################################
