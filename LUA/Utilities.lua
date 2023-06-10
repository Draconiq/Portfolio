--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

--// General

local Functions = {}








--// Functions


--// Queries the Attributes of the Character
function Functions.QueryState(Character,QueryList) 

    for Attribute, Value in pairs(QueryList) do

		if Character:GetAttribute(Attribute) ~= Value then

			return false

		end

	end

	return true

end



--// Changes Humanoid states to parsed dictioanry
function Functions:ApplyHumanoidState(Humanoid,States) 

    for State,Value in pairs(States) do

        Humanoid:ChangeState(Enum.HumanoidStateType[State],Value)

    end

end



--// Apply properties to an instance with exteriror properties such as Delay and Duration
function Functions.ApplyProperties(Obj,Properties) 
	
    for Property,Value in next,Properties do

        if Property == "Parent" or Property == "Delay" or Property == "Duration" or string.find(Property,"_") then continue end

        Obj[Property] = Value

    end

    _ = Properties.Delay and task.wait(Properties.Delay)

    Obj.Parent = Properties.Parent or Obj.Parent

end



--// Effecient Instance Method
function Functions.Create(Class,Properties) 

    local Creation = type(Class) == "string" and Instance.new(Class) or Class

    Properties = Properties or {}
    
    Functions.ApplyProperties(Creation,Properties)

    _ = Properties.Duration and Debris:AddItem(Creation,Properties.Duration)

    return Creation

end



--// Returns Players in a certain radius (Typically used for firing clients)
function Functions.ReturnPlayersInRadius(Position,Radius) 

    local Position = type(Position) == "userdata" and Position.Position or Position
    
    local PlayersFound = {}
    local PlayerSearch = Players:GetChildren()

    for i = 1,#PlayerSearch do

        local Player = PlayerSearch[i]
        local Character = Player.Character

        if not(Character) then continue end

        local Check = (Character.HumanoidRootPart.Position - Position).magnitude <= Radius
        _ = Check and table.insert(PlayersFound, Player) or nil

    end
    
    return PlayersFound

end



--// Returns whether a table is an Array or Dictionary
function Functions.ReturnTableType(Table) 

    for i,_ in pairs(Table) do

        if type(i) ~= "number" then

            return "Dictionary"

        end

    end

    return "Array"
    
end



--// Destroys class of descendants 
function Functions.DestroyClass(Character,Class) 

    local Search = Character:GetDescendants()

    for _,Obj in ipairs(Search) do

        if Obj.ClassName ~= Class then continue end

        Obj:Destroy()

    end

end



--// Gets length of dictionary
function Functions.GetLengthOfDict(Dict) 
    local Counter = 0

    for i,_ in pairs(Dict) do

        Counter +=1

    end
    
    return Counter

end



--// Emits Parents decendants
function Functions.EmitDescendants(Obj)

    local Search = Obj:GetDescendants()

    for _,Obj in ipairs(Search) do

        if not Obj:IsA("ParticleEmitter") then continue end

        local Delay = Obj:GetAttribute("Delay")

        local EmitCount = Obj:GetAttribute("EmitCount")

        coroutine.wrap(function()

            _ = Delay and task.wait(Delay)

            Obj:Emit(EmitCount)

        end)()

    end
end    



--// Changes the Property of Parents descendants to Switch
function Functions.EnableDescendants(Obj,Switch)

    local Search = Obj:GetDescendants()

    for _,Obj in ipairs(Search) do

        if not Obj:IsA("ParticleEmitter") then continue end

        Obj.Enabled = Switch

    end

end



--// Gets the players Data Folder
function Functions.GetFolder(Player)

    local Data = ReplicatedStorage.Data
    
    return Data:FindFirstChild(Player.Name)

end



--// Gets Players Current File Under Data
function Functions.GetFile(Player)

    local Folder = Functions.GetFolder(Player)
    
    local CurrentFile = Folder.CurrentFile.Value

    return Folder.Files:FindFirstChild(CurrentFile)

end



--// Returns Object that has attribute with specified value
function Functions.GetAttributeWithValue(Parent,Attribute,Value)

    local Search = Parent:GetDescendants()

    for _,Obj in ipairs(Search) do

        if Obj:GetAttribute(Attribute) ~= Value then continue end

        return Obj

    end

end



--// Merges tables parsed 
function Functions.MergeTables(Tables)

    local MergedTable = {}

    for _,Value in ipairs(Tables) do
        
        for _,Index in ipairs(Value) do
            
            table.insert(MergedTable,Index)

        end

    end

    return MergedTable

end


--// Clears children excluding 
function Functions.ClearChildren(Parent,Filter,FilterType)

    local Search = Parent:GetChildren()

    local function IsInFilter(Obj)

        for _,Category in ipairs(Filter) do

            if Obj:IsA(Category) or Obj.ClassName == Category then return true end

        end
        
        return false

    end

    for _,Obj in ipairs(Search) do

        if (FilterType == "Whitelist" and not IsInFilter(Obj)) or FilterType == "Blacklist" and IsInFilter(Obj) then 

            Obj:Destroy()

        end

    end

end






return Functions