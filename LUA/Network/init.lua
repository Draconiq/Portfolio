--// Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


--// General
local ErrorContainer
local KeyCard
local Remotes = script.Remotes
local Side = RunService:IsServer() and "Server" or "Client"
local DirectoryPaths = {
	Client = ReplicatedStorage.Library.Client,
	Shared = ReplicatedStorage.Library.Shared,
	Server = Side == "Server" and ServerStorage.Library or nil
}
local Network = {
	RemoteEvent = Remotes.RemoteEvent,
	RemoteFunction = Remotes.RemoteFunction,
	BindableEvent = Remotes.BindableEvent,
	BindableFunction = Remotes.BindableFunction,
}



--// Library & Module Flow Handler

function Network:GetLibrary(...)

	--// Modules Directory - (Side,Client)
	local Args = table.pack(...)
	local ArgNum = #Args

	local LibrarySide,LibraryName = (ArgNum == 2) and Args[1] or Side,(ArgNum == 2) and Args[2] or Args[1]

	--// Index Search and create return folder
	local LibraryPath = DirectoryPaths[LibrarySide]:FindFirstChild(LibraryName)

	if not LibraryPath then warn(ErrorContainer[100][Side]:format(Side == "Client" and Players.LocalPlayer.UserId or "Server",LibraryName)) return end
	
	LibraryPath = LibraryPath:GetChildren()

	local Library = {}

	--// Returns Folder in Modularised Dictionary Format
	for _,V in ipairs(LibraryPath) do

		if not V:IsA("ModuleScript") then continue end

		Library[V.Name] = require(V)

	end

	return Library

end


function Network:GetModule(Name)

	--// Search through each directory path
	for _,Folder in pairs(DirectoryPaths) do

		--// Get Contents of Directory Path
		local Search = Folder:GetDescendants()

		--// Search through contents of directory Path
		for _,Obj in ipairs(Search) do

			if not(Obj:IsA("ModuleScript") and Obj.Name == Name) then continue end

			return require(Obj)

		end

	end
	
	warn("Error 404: ".. Name .. " was not found")
	
	return nil

end




--// Network Receiver

function Network.OnNetworkEvent(...)

	--// Get Directory Path
	local Args = table.pack(...)

	local Player,Data = (#Args == 2 and Args[1]) or Players.LocalPlayer,#Args == 2 and Args[2] or Args[1]




	--// Security
	local Flagged = (Side == "Server" and not(table.find(KeyCard,Data.Directory))) and true or false

	if Flagged then warn(ErrorContainer[101]:format(Player.UserId,Data.Directory)) return end



	--// Get the Directory Path
	local Directory = string.split(Data.Directory,"_")

	local Module,Function = Directory[1],(Directory[2] or nil)
	
	Module = Network:GetModule(Module)

	local Path = Function and Module.Function or Module or nil


	
	--// Make sure there is a valid path

	if not Path then warn(ErrorContainer[401]:format(Player.UserId,Directory,Side)) end

	Function = (type(Module) == "function") and Module or (Function) and Module[Function] or Module



	--// Set FunctionData and insert Character into it
	Data.FunctionData = Data.FunctionData or {}

	Data.FunctionData.Character = Data.FunctionData.Character or Player and Player.Character

	Data.FunctionData.Player = Player
	



	--// Returns the data so it's universal to all remotes
	return (type(Function) ~= "function") and Function or Function(Data.FunctionData)
    
end


--// Special Network Transmitters

function Network.FireClientsInRadius(Position,Radius,Data)

	local Utilities  = Network:GetModule("Utilities")

	local TargetPlayers = Utilities.ReturnPlayersInRadius(Position,Radius)

	for _,Player in ipairs(TargetPlayers) do

		Network.RemoteEvent:FireClient(Player,Data)

	end

end






ErrorContainer = Network:GetModule("ErrorContainer")



--// Methods & Callback Connections

Network.BindableEvent.Event:Connect(Network.OnNetworkEvent)

Network.BindableFunction.OnInvoke = Network.OnNetworkEvent

if Side == "Server" then

	Network.RemoteEvent.OnServerEvent:Connect(Network.OnNetworkEvent)

	Network.RemoteFunction.OnServerInvoke = Network.OnNetworkEvent

	KeyCard = Network:GetModule("KeyCard")
	
else

	Network.RemoteEvent.OnClientEvent:Connect(Network.OnNetworkEvent)

	Network.RemoteFunction.OnClientInvoke = Network.OnNetworkEvent

end


return Network


--[[

                                        ,   ,
                                        $,  $,     ,
                                        "ss.$ss. .s'
                                ,     .ss$$$$$$$$$$s,
                                $. s$$$$$$$$$$$$$$`$$Ss
                                "$$$$$$$$$$$$$$$$$$o$$$       ,
                               s$$$$$$$$$$$$$$$$$$$$$$$$s,  ,s
                              s$$$$$$$$$"$$$$$$""""$$$$$$"$$$$$,
                              s$$$$$$$$$$s""$$$$ssssss"$$$$$$$$"
                             s$$$$$$$$$$'         `"""ss"$"$s""
                             s$$$$$$$$$$,              `"""""$  .s$$s
                             s$$$$$$$$$$$$s,...               `s$$'  `
                         `ssss$$$$$$$$$$$$$$$$$$$$####s.     .$$"$.   , s-
                           `""""$$$$$$$$$$$$$$$$$$$$#####$$$$$$"     $.$'
                                 "$$$$$$$$$$$$$$$$$$$$$####s""     .$$$|
                                  "$$$$$$$$$$$$$$$$$$$$$$$$##s    .$$" $
                                   $$""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"   `
                                  $$"  "$"$$$$$$$$$$$$$$$$$$$$S""""'
                             ,   ,"     '  $$$$$$$$$$$$$$$$####s
                             $.          .s$$$$$$$$$$$$$$$$$####"
                 ,           "$s.   ..ssS$$$$$$$$$$$$$$$$$$$####"
                 $           .$$$S$$$$$$$$$$$$$$$$$$$$$$$$#####"
                 Ss     ..sS$$$$$$$$$$$$$$$$$$$$$$$$$$$######""
                  "$$sS$$$$$$$$$$$$$$$$$$$$$$$$$$$########"
           ,      s$$$$$$$$$$$$$$$$$$$$$$$$#########""'
           $    s$$$$$$$$$$$$$$$$$$$$$#######""'      s'         ,
           $$..$$$$$$$$$$$$$$$$$$######"'       ....,$$....    ,$
            "$$$$$$$$$$$$$$$######"' ,     .sS$$$$$$$$$$$$$$$$s$$
              $$$$$$$$$$$$#####"     $, .s$$$$$$$$$$$$$$$$$$$$$$$$s.
   )          $$$$$$$$$$$#####'      `$$$$$$$$$###########$$$$$$$$$$$.
  ((          $$$$$$$$$$$#####       $$$$$$$$###"       "####$$$$$$$$$$
  ) \         $$$$$$$$$$$$####.     $$$$$$###"             "###$$$$$$$$$   s'
 (   )        $$$$$$$$$$$$$####.   $$$$$###"                ####$$$$$$$$s$$'
 )  ( (       $$"$$$$$$$$$$$#####.$$$$$###' -Draconiq      .###$$$$$$$$$$"
 (  )  )   _,$"   $$$$$$$$$$$$######.$$##'                .###$$$$$$$$$$
 ) (  ( \.         "$$$$$$$$$$$$$#######,,,.          ..####$$$$$$$$$$$"
(   )$ )  )        ,$$$$$$$$$$$$$$$$$$####################$$$$$$$$$$$"
(   ($$  ( \     _sS"  `"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$S$$,
 )  )$$$s ) )  .      .   `$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"'  `$$
  (   $$$Ss/  .$,    .$,,s$$$$$$##S$$$$$$$$$$$$$$$$$$$$$$$$S""        '
    \)_$$$$$$$$$$$$$$$$$$$$$$$##"  $$        `$$.        `$$.
        `"S$$$$$$$$$$$$$$$$$#"      $          `$          `$
            `"""""""""""""'         '           '           '
]]
