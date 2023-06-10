--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")


--// Modules
local Network = require(ReplicatedStorage.Network)
local Utilities = Network:GetModule("Utilities")


--// General
local Create = Utilities.Create
local Modules = {}










local function IsDecimal(Value)

    local Check = math.floor(Value) == Value

    return not Check

end

--// Converts a Folder into a Dictionary
function Modules.Folder_To_Dictionary(Folder) 

    local Dictionary = {}
    local Search = Folder:GetChildren()

    for _,Obj in ipairs(Search) do

        local Class = Obj.ClassName

        local Constrained = string.find(Class,"Constrained")

        Dictionary[Obj.Name] = (Class == "Folder") and Modules.Folder_To_Dictionary(Obj) or (Constrained) and {Obj.MinValue,Obj.Value,Obj.MaxValue} or Obj.Value

    end

    return Dictionary

end



--// Converts and Parents a Dictionary to a folder
function Modules.Dictionary_To_Folder(Parent,Dictionary)

    for Key,Value in pairs(Dictionary) do

        local Type = typeof(Value)

        local Branch = (Type == "string" or Type == "number" or Type == "boolean") and "Default" or "Table"

        local _ =

            Branch == "Default" and

                Create(Type == "string" and "StringValue" or Type == "number" and (IsDecimal(Value) and "NumberValue" or "IntValue") or "BoolValue",{
                    Name = Key,
                    Value = Value,
                    Parent = Parent,
                }) 

            or

            Branch == "Table" and 

                Utilities.ReturnTableType(Value) == "Array" and #Value == 3 and

                    Create("IntConstrainedValue",{
                        Name = Key,
                        MinValue = Value[1],
                        Value = Value[2],
                        MaxValue = Value[3],
                        Parent = Parent,
                    }) 
                    
                    or

                    Modules.Dictionary_To_Folder(Create("Folder",{
                        Name = Key,
                        Parent = Parent,
                    }),Value)
    end

end


return Modules