--[[
#-----------------------------------------------------------------------------#
----*					MTA DayZ: status_player.lua						*----
----* Original Author: Marwin W., Germany, Lower Saxony, Otterndorf		*----

----* This gamemode is being developed by L, CiBeR96, 1B0Y				*----
----* Type: CLIENT														*----
#-----------------------------------------------------------------------------#
]]

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function()
		dayzVersion = "MTA:DayZ 0.9.4.2a"
		versionLabel  = guiCreateLabel(1,1,0.3,0.3,dayzVersion,true)
		guiSetSize ( versionLabel, guiLabelGetTextExtent ( versionLabel ), guiLabelGetFontHeight ( versionLabel ), false )
		x,y = guiGetSize(versionLabel,true)
		guiSetPosition( versionLabel, 1-x, 1-y*1.8, true )
		guiSetAlpha(versionLabel,0.5)
	end
)

setPedTargetingMarkerEnabled(false)

function stopPlayerVoices()
	for i, player in ipairs(getElementsByType("player")) do
		setPedVoice(player, "PED_TYPE_DISABLED")
	end
end
setTimer(stopPlayerVoices,1000,0)

function createBloodFX()
	if getElementData(localPlayer,"logedin") then
		local x,y,z = getElementPosition(localPlayer)
		local bleeding = getElementData(localPlayer,"bleeding") or 0
		if bleeding > 0 then
			local px,py,pz = getPedBonePosition(localPlayer,3)
			local pdistance = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
			if bleeding >= 61 then
				number = 5
			elseif bleeding >= 31 and bleeding <= 60 then
				number = 3
			elseif bleeding >= 10 and bleeding <= 30 then
				number = 1
			else
				number = 0
			end
			if pdistance <= 120 then
				fxAddBlood (px,py,pz,0,0,0,number,1)
			end
		end
	end	
end
setTimer(createBloodFX,300,0)

function setPlayerBleeding()
	if getElementData(localPlayer,"logedin") then
		if getElementData(localPlayer,"bleeding") > 20 then
			setElementData(localPlayer,"blood",getElementData(localPlayer,"blood")-getElementData(localPlayer,"bleeding"))
		else
			local randomnumber = math.random(0,10)
			if randomnumber < 5 then
				setElementData(localPlayer,"bleeding",0)
			end
		end
	end
end
setTimer(setPlayerBleeding,30000,0)

function setPlayerDeath()
	if getElementData(localPlayer,"logedin") then
		if getElementData(localPlayer,"blood") <= 0 then
			if not getElementData(localPlayer,"isDead") then
				triggerServerEvent("kilLDayZPlayer",localPlayer,false,false)
			end
		end
	end
end
setTimer(setPlayerDeath,1000,0)

function setPlayerBrokenbone()
	if getElementData(localPlayer,"logedin") then
		if getElementData(localPlayer,"brokenbone") then
			toggleControl("jump", false)
			toggleControl("sprint",false)
		else
			toggleControl("jump", true)
			toggleControl("sprint", true)
		end
	end
end
setTimer(setPlayerBrokenbone,2000,0)

function setPlayerCold()
	if getElementData(localPlayer,"logedin") then
		if getElementData(localPlayer,"temperature") <= 33 then
			setElementData(localPlayer,"cold",true)
		elseif getElementData(localPlayer,"temperature") > 33 then
			setElementData(localPlayer,"cold",false)
		end
		if getElementData(localPlayer,"cold") then
			local x,y,z = getElementPosition(localPlayer)
			createExplosion (x,y,z+15,8,false,0.5,false)
			local x, y, z, lx, ly, lz = getCameraMatrix()
			randomsound = math.random(0,99)
			if randomsound >= 0 and randomsound <= 10 then
				local getnumber = math.random(0,2)
				playSound(":DayZ/sounds/status/cough_"..getnumber..".ogg",false)
				setElementData(localPlayer,"volume",100)
				setTimer(function() setElementData(localPlayer,"volume",0) end,1500,1)
			elseif randomsound >= 11 and randomsound <= 20 then	
				setElementData(localPlayer,"volume",100)
				setTimer(function() setElementData(localPlayer,"volume",0) end,1500,1)
				playSound(":DayZ/sounds/status/sneezing.mp3",false)
			end
		end	
	end
end
setTimer(setPlayerCold,40000,0)

function isPlayerInBuilding(x,y,z)
	if isInBuilding(x,y,z) then
		triggerServerEvent("onPlayerChangeStatus",source,"isInBuilding",true)
	else
		triggerServerEvent("onPlayerChangeStatus",source,"isInBuilding",false)
	end
end
addEvent("isPlayerInBuilding",true)
addEventHandler("isPlayerInBuilding",root,isPlayerInBuilding)

function setPlayerPain()
	if getElementData(localPlayer,"logedin") then
		if getElementData(localPlayer,"pain") then
			local x,y,z = getElementPosition(localPlayer)
			createExplosion (x,y,z+15,8,false,1.0,false)
			local x, y, z, lx, ly, lz = getCameraMatrix()
			x, lx = x + 1, lx + 1
			setCameraMatrix(x,y,z,lx,ly,lz)
			setCameraTarget (localPlayer)
		end
	end
end
setTimer(setPlayerPain,6000,0)
--[[ 
Volume (Noise):

0 = Silent
20 = Very Low
40 = Low
60 = Moderate
80 = High
100 = Very High

]]

function setVolume()
	value = 0
	local block, animation = getPedAnimation(localPlayer)
	if getPedMoveState (localPlayer) == "stand" then
		value = 0
	elseif getPedMoveState (localPlayer) == "crouch" then	
		value = 0
	elseif getPedMoveState(localPlayer) == "crawl" then
		value = 20
	elseif getPedMoveState (localPlayer) == "walk" then
		value = 40
	elseif getPedMoveState (localPlayer) == "powerwalk" then
		value = 60
	elseif getPedMoveState (localPlayer) == "jog" then
		value = 80
	elseif getPedMoveState (localPlayer) == "sprint" then	
		value = 100
	elseif not getPedMoveState (localPlayer) then
		value = 20
	end
	if getElementData(localPlayer,"shooting") and getElementData(localPlayer,"shooting") > 0 then
		value = value+getElementData(localPlayer,"shooting")
	end
	if isPedInVehicle (localPlayer) then
		value = 100
	end	
	if value > 100 then
		value = 100
	end
	if block == "ped" or block == "SHOP" or block == "BEACH" then
		value = 0
	end
	setElementData(localPlayer,"volume",value)
end
setTimer(setVolume,100,0)

--[[
Visibility:

0 = Invisible
20 = Very Low Visibility
40 = Low Visibility
60 = Moderate Visibility
80 = High Visibility
100 = Very High Visibility

]]
function setVisibility()
	value = 0
	local block, animation = getPedAnimation(localPlayer)
	if getPedMoveState (localPlayer) == "stand" then
		value = 40
	elseif getPedMoveState (localPlayer) == "crouch" then	
		value = 0
	elseif getPedMoveState(localPlayer) == "crawl" then
		value = 20
	elseif getPedMoveState (localPlayer) == "walk" then
		value = 60
	elseif getPedMoveState (localPlayer) == "powerwalk" then
		value = 60
	elseif getPedMoveState (localPlayer) == "jog" then
		value = 60
	elseif getPedMoveState (localPlayer) == "sprint" then	
		value = 80
	elseif not getPedMoveState (localPlayer) then	
		value = 20
	end
	if getElementData(localPlayer,"jumping") then
		value = 100
	end
	if isObjectAroundPlayer (localPlayer,2, 4 ) then
		value = 0
	end
	if isPedInVehicle (localPlayer) then
		value = 100
	end
	if block == "ped" or block == "SHOP" or block == "BEACH" then
		value = 0
	end
	setElementData(localPlayer,"visibly",value)
end
setTimer(setVisibility,100,0)

function debugJump()
	if getControlState("jump") then
		setElementData(localPlayer,"jumping",true)
		setTimer(debugJump2,650,1)
	end
end
setTimer(debugJump,100,0)

function debugJump2()
	setElementData(localPlayer,"jumping",false)
end

local SneakEabled = false
function setPlayerSneakOnWalk()
	if getControlState("walk") then
		if not SneakEnabled then
			triggerServerEvent("setPlayerSneak",localPlayer,69)
			SneakEnabled = true
		end
	else
		if SneakEnabled then
			triggerServerEvent("setPlayerSneak",localPlayer,54)
			SneakEnabled = false
		end
	end
end
setTimer(setPlayerSneakOnWalk,1000,0)

function updateDaysAliveTime()
	if getElementData(localPlayer,"logedin") then
		local daysalive = getElementData(localPlayer,"daysalive")
		setElementData(localPlayer,"daysalive",daysalive+1)
	end
end
setTimer(updateDaysAliveTime,2880000,0)

function updatePlayTime()
	if getElementData(localPlayer,"logedin") then
		local playtime = getElementData(localPlayer,"alivetime")
		setElementData(localPlayer,"alivetime",playtime+1)	
	end	
end
setTimer(updatePlayTime,60000,0)

function onPlayerActionPlaySound(item)
	if item == "meat" then
		local number = math.random(0,1)
		playSound(":DayZ/sounds/items/cook_"..number..".ogg",false)
	elseif item == "water" then
		playSound(":DayZ/sounds/items/fillwater.ogg",false)
	elseif item == "tent" then
		playSound(":DayZ/sounds/items/tentunpack.ogg",false)
	elseif item == "repair" then
		playSound(":DayZ/sounds/items/repair.ogg",false)
	end
end
addEvent("onPlayerActionPlaySound",true)
addEventHandler("onPlayerActionPlaySound",root,onPlayerActionPlaySound)

local bloodTest = {}
local number = 0
local vialsLeft = 3
local handFont = guiCreateFont(":DayZ/fonts/needhelp.ttf",17)

bloodTest["testsheet"] = guiCreateStaticImage(0.13, 0.20, 0.71, 0.61, ":DayZ/gui/status/blood/bloodtest.png", true)
bloodTest["drop1"] = guiCreateStaticImage(0.162, 0.182, 0.13, 0.17, ":DayZ/gui/status/blood/drop.png", true, bloodTest["testsheet"])
guiSetProperty(bloodTest["drop1"], "ImageColours", "tl:FF86787C tr:FF86787C bl:FF86787C br:FF86787C")
bloodTest["drop2"] = guiCreateStaticImage(0.338, 0.182, 0.13, 0.17, ":DayZ/gui/status/blood/drop.png", true, bloodTest["testsheet"])
guiSetProperty(bloodTest["drop2"], "ImageColours", "tl:FF86787C tr:FF86787C bl:FF86787C br:FF86787C")
bloodTest["drop3"] = guiCreateStaticImage(0.512, 0.182, 0.13, 0.17, ":DayZ/gui/status/blood/drop.png", true, bloodTest["testsheet"])
guiSetProperty(bloodTest["drop3"], "ImageColours", "tl:FF86787C tr:FF86787C bl:FF86787C br:FF86787C")
bloodTest["drop4"] = guiCreateStaticImage(0.69, 0.182, 0.13, 0.17, ":DayZ/gui/status/blood/drop.png", true, bloodTest["testsheet"])
guiSetProperty(bloodTest["drop4"], "ImageColours", "tl:FF86787C tr:FF86787C bl:FF86787C br:FF86787C")
bloodTest["tested"] = guiCreateLabel(0.16, 0.45, 0.33, 0.09, getPlayerName(localPlayer), true, bloodTest["testsheet"])
guiLabelSetColor(bloodTest["tested"], 0, 0, 0)
guiLabelSetHorizontalAlign(bloodTest["tested"], "center", false)
guiLabelSetVerticalAlign(bloodTest["tested"], "center")
bloodTest["instructions"] = guiCreateLabel(0.16, 0.68, 0.33, 0.09, "Click the circles to \ndetermine your blood type!", true, bloodTest["testsheet"])
guiLabelSetColor(bloodTest["instructions"], 0, 0, 0)
guiLabelSetVerticalAlign(bloodTest["instructions"], "center")
bloodTest["substance"] = guiCreateStaticImage(0.69, 0.49, 0.22, 0.37, ":DayZ/gui/status/blood/substance.png", true, bloodTest["testsheet"])
bloodTest["substanceleft"] = guiCreateLabel(0.30, 0.42, 0.56, 0.46, vialsLeft, true, bloodTest["substance"])
guiSetFont(bloodTest["substanceleft"], "default-bold-small")
guiLabelSetHorizontalAlign(bloodTest["substanceleft"], "center", false)
guiLabelSetVerticalAlign(bloodTest["substanceleft"], "center")    
bloodTest["close"] = guiCreateLabel(0.11, 0.83, 0.23, 0.07, "Close", true, bloodTest["testsheet"])
guiLabelSetVerticalAlign(bloodTest["close"], "center")
guiLabelSetColor(bloodTest["close"],0,0,0)
guiSetFont(bloodTest["tested"],handFont)
guiSetFont(bloodTest["instructions"],handFont)
guiSetFont(bloodTest["close"],handFont)

guiSetVisible(bloodTest["testsheet"],false)

function activateBloodTest()
	if guiGetVisible(bloodTest["testsheet"]) then
		guiSetVisible(bloodTest["testsheet"],false)
		showCursor(false)
		removeEventHandler("onClientMouseEnter",bloodTest["close"],colorSelected)
		removeEventHandler("onClientMouseLeave",bloodTest["close"],colorDeselected)
	else
		guiSetVisible(bloodTest["testsheet"],true)
		showCursor(not isCursorShowing())
		addEventHandler("onClientMouseEnter",bloodTest["close"],colorSelected,false)
		addEventHandler("onClientMouseLeave",bloodTest["close"],colorDeselected,false)
		vialsLeft = 3
		guiSetProperty(bloodTest["drop1"], "ImageColours", "tl:FF86787C tr:FF86787C bl:FF86787C br:FF86787C")
		guiSetProperty(bloodTest["drop2"], "ImageColours", "tl:FF86787C tr:FF86787C bl:FF86787C br:FF86787C")
		guiSetProperty(bloodTest["drop3"], "ImageColours", "tl:FF86787C tr:FF86787C bl:FF86787C br:FF86787C")
		guiSetProperty(bloodTest["drop4"], "ImageColours", "tl:FF86787C tr:FF86787C bl:FF86787C br:FF86787C")
	end
end

function colorSelected()
	guiLabelSetColor(bloodTest["close"],255,0,0)
end

function colorDeselected (b,s)
	guiLabelSetColor(bloodTest["close"],0,0,0)
end

function closeBloodTest()
	guiSetVisible(bloodTest["testsheet"],false)
	showCursor(not isCursorShowing())
	removeEventHandler("onClientMouseEnter",bloodTest["close"],colorSelected)
	removeEventHandler("onClientMouseLeave",bloodTest["close"],colorDeselected)
end

function assignTypeToDrop()
	local bloodstring = ""
	for i = 1, 4 do
		if i == 1 then
			bloodstring = "0"
			setElementData(bloodTest["drop1"],"bloodtype",bloodstring)
		elseif i == 2 then
			bloodstring = "A"
			setElementData(bloodTest["drop2"],"bloodtype",bloodstring)
		elseif i == 3 then
			bloodstring = "B"
			setElementData(bloodTest["drop3"],"bloodtype",bloodstring)
		elseif i == 4 then
			bloodstring = "AB"
			setElementData(bloodTest["drop4"],"bloodtype",bloodstring)
		end
		addEventHandler("onClientGUIClick",bloodTest["drop"..i],checkBloodType, false)
	end
	addEventHandler("onClientGUIClick",bloodTest["close"],closeBloodTest,false)
end
addEventHandler("onClientPlayerSpawn",localPlayer,assignTypeToDrop)

function checkBloodType(button, state)
	if button == "left" then
		if vialsLeft > 0 then
			if getElementData(source,"bloodtype") == getElementData(localPlayer,"bloodtype") then
				guiSetProperty(source, "ImageColours", "tl:FF00FF00 tr:FF00FF00 bl:FF00FF00 br:FF00FF00")
				setElementData(localPlayer,"bloodtypediscovered",getElementData(localPlayer,"bloodtype"))
				vialsLeft = 0
				guiSetText(bloodTest["substanceleft"],vialsLeft)
			else
				if vialsLeft == 0 then
					triggerEvent("displayClientInfo",localPlayer,"Blood","No more test substance left!",255,0,0)
					return
				else
					guiSetProperty(source, "ImageColours", "tl:FFFF0000 tr:FFFF0000 bl:FFFF0000 br:FFFF0000")
					vialsLeft = vialsLeft-1
					guiSetText(bloodTest["substanceleft"],vialsLeft)
				end
			end
		else
			triggerEvent("displayClientInfo",localPlayer,"Blood","No more test substance left!",255,0,0)
		end
	end
end