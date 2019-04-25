#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\kuhiscripts icons\logo_green.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ImageSearch.au3>
#include <Array.au3>
#include <AutoItConstants.au3>
#include <Date.au3>

Global $picXY[2]
Global $requiredXY[2]
Global $availableXY[2]
Global $nextXY[2]
Global $filled_items = 0
Global $ticks = 0
Global $looping = False

HotKeySet("{END}","Quit")
HotKeySet("{HOME}","ActivateLoop")

;Create console
Global $text = "Team Fortress Bot"
Global $sphandle = SplashTextOn("", $text, 300, 40, ((@DesktopWidth / 2) - 150), 0, $DLG_NOTITLE, "Segoe UI", 9, 300)

;Clean logs
Console("Creating log.txt file...")
FileOpen("log.txt", 2)
FileWriteLine("log.txt", "LOGS FROM: " & _NowDate())
FileClose("log.txt")

;FindGame
Console("Searching game window...")
FindGame()
Console("Ready, Keys: END(quit) & HOME(Start bot).")

;Loop
While 1
	If $looping Then
		Loop()
	EndIf
	Sleep(100)
WEnd

Exit

;FUNCS
Func Loop()
	FindGame()

	;Open inventory
	Console("Bot started.")
	
	;Console("Finding items...")
	;ClickIngame("images\items.png", $picXY, true)
	;	
	;Console("Finding backpack...")
	;MouseMove(0,0,1)
	;sleep(200)
	;ClickIngame("images\backpack.png", $picXY, true)
    ;
	;;el fabricator se abre con click derecho o click izquierdo?
	;Console("Fabricator inspect...")
	;ClickIngame("images\fabricator.png", $picXY, true) ;añadir ultimo parametro true
    ;
	;;inspect fabricator
	;ClickIngame("images\inspectmarked.png", $picXY, false)
	
	;hide mouse
	MouseMove(0, 0, 1)
	
	;fill required items
	Console("Filling required items...")
	$filled = false
	While Not ($filled)
		$j = 1
		$i = 1
		While $i < 4
			Console("Filling page " & $i & "/3")
			
			While $j < 7
				;Define images
				$ava_image = "images\available\item" & $j & ".png"
				$req_image = "images\required\item" & $j & ".png"
				
				Console("Checking item " & $j & "/6")				

				;If item is still required
				$itemdone = false
				$pagecount = 1
				While Not $itemdone
					Console("Required item: " & $j & "/6")
					$done = false
					
					;Check if item is required
					If Not SearchItemRequired($req_image, $requiredXY) Then
						$done = true
						$itemdone = true
						Console("Can't find item.")
					EndIf

					;Check if the item is in actual page (inventory) and move it
					If Not $done And SearchItemInventory($ava_image, $availableXY) Then
						Console("Moving item from inventory to required items...")
						MouseClickDrag("left", $availableXY[0], $availableXY[1], $requiredXY[0], $requiredXY[1], 1)
						$done = true
					EndIf

					;If not in actual page, move to next page
					If Not $done Then
						Console("Item is not in actual inventory page.")
						If SearchItemInventory("images\next.png", $availableXY) Then
							Console("Image found at " & $availableXY[0] & " / " & $availableXY[1])
							MouseClick("left", $availableXY[0], $availableXY[1], 1, 1)
							$pagecount = $pagecount + 1
							$done = true
						EndIf
					EndIf

					;Detect out of stock.
					If $pagecount >= 20 Then
						;out of stock
						$done = true
						$itemdone = true
						Console("Skipping out of stock item.")
					EndIf
				WEnd

				;Next item				
				$j = $j + 1
			WEnd

			;Move to next page
			Console("Moving to next required page...")
			If SearchItemRequired("images\next.png", $picXY) Then
				Console("Image found at " & $picXY[0] & " / " & $picXY[1])
				MouseClick("left", $picXY[0], $picXY[1], 1, 1)
				Sleep(500)
			EndIf
			$i = $i + 1
			$j = 1
		WEnd
		$filled = true
	WEnd
	
	If FindImage("images\apply.png", $picXY) Then
		Console("Clicking apply...")
		MouseClick("left", $picXY[0], $picXY[1], 1, 1)
		Sleep(200)
	Else
		If FindImage("images\craft.png", $picXY) Then
			Console("Clicking craft...")
			MouseClick("left", $picXY[0], $picXY[1], 1, 1)
			Sleep(200)
		EndIf
	EndIf
	
	If FindImage("images\ok.png", $picXY) Then
		Console("Clicking ok...")
		MouseClick("left", $picXY[0], $picXY[1], 1, 1)
		Sleep(200)
	EndIf
	
	$looping = false
	Console("Ready, Keys: END(quit) & HOME(Start bot).")
EndFunc

Func ActivateLoop()
	$looping = true
EndFunc

Func ClickIngame($image, ByRef $imageXY, $debug = false, $side = "left")
	WinActivate("Team Fortress 2")
	Sleep(500)
	Local $search = _ImageSearch($image, 1, $imageXY[0], $imageXY[1], 0)
	If $search = 1 Then
		If $side = "left" Then
			MouseClick("left", $imageXY[0], $imageXY[1], 1, 1)
		Else
			MouseClick("right", $imageXY[0], $imageXY[1], 1, 1)
		EndIf
	Else
		If $debug Then
			Console("Error, check log.txt file.")
			WriteLog("Unable to find image " & $image)
			Sleep(3000)
			Exit
		EndIf
	EndIf
	Sleep(1000)
EndFunc

Func FindGame()
If Not WinActivate("Team Fortress 2") Then
	Console("Error, check log.txt file.")
	WriteLog("Unable to find game window, game is closed.")
	Sleep(3000)
	Exit
EndIf
EndFunc

Func Quit()
Exit
EndFunc

Func Console($text2)
ControlSetText($sphandle, $text, 'Static1', $text2)
$text = $text2
EndFunc

Func WriteLog($text)
FileOpen("log.txt", 1)
FileWriteLine("log.txt", _NowTime() & " -- " & $text)
;FileWriteLine("log.txt", "ImageXY[0] = " & $picXY[0] & @LF & "ImageXY[1] = " & $picXY[1]) ; debug image XY
FileClose("log.txt")
EndFunc

Func NextPage($area)
If $area = "available" Then
	If SearchItemInventory("images\next.png", $availableXY) Then
		MouseClick("right", $nextXY[0], $nextXY[1], 1, 1)
	EndIf
EndIf
If $area = "required" Then
	If SearchItemRequired("images\next.png", $requiredXY) Then
		MouseClick("right", $nextXY[0], $nextXY[1], 1, 1)
	EndIf
EndIf
EndFunc

Func SearchItemRequired($image, ByRef $XY)
	$req_width = @DesktopWidth
	$st_width = $req_width / 2
	$req_height = @DesktopHeight
	
	MouseMove(0, 0, 1)
	sleep(200)
	
	If _ImageSearchArea($image, 1, $st_width, 0, $req_width, $req_height, $XY[0], $XY[1], 0, 0) Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func SearchItemInventory($image, ByRef $XY)
	;define screen left side
	$inventory_width = @DesktopWidth / 2
	$inventory_height = @DesktopHeight
		
	MouseMove(0, 0, 1)
	sleep(200)

	If _ImageSearchArea($image, 1, 0, 0, $inventory_width, $inventory_height, $XY[0], $XY[1], 0, 0) Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func FindImage($image, ByRef $imageXY)
	Local $search = _ImageSearch($image, 1, $imageXY[0], $imageXY[1], 0)
	If $search = 1 Then
		Return True
	Else
		Return False
	EndIf
EndFunc