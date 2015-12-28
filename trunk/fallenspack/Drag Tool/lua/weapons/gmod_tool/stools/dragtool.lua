TOOL.Category		= "Constraints"
TOOL.Name			= "#Disable Drag"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if ( CLIENT ) then
    language.Add( "Tool_dragtool_name", "Dragtool" )
    language.Add( "Tool_dragtool_desc", "Enable or Disable drag for entities" )
    language.Add( "Tool_dragtool_0", "Primary: Turn drag for an entity off, Secondary: Re-enable drag" )
end

local function enabledrag(_ , Entity , Data )
	if SERVER then
		if Entity:IsValid() and !Entity:IsWorld() then
			local phys = Entity:GetPhysicsObject()
			phys:EnableDrag( Data.DragOnOff )
		end
		duplicator.StoreEntityModifier( Entity, "DragEnabled" , Data)
	end
	
end

duplicator.RegisterEntityModifier( "DragEnabled", enabledrag )


function TOOL:LeftClick(Trace)
	
	local ent = Trace.Entity

	enabledrag( _ , ent , {DragOnOff = false})

	return true
end

function TOOL:RightClick(Trace)

	local ent = Trace.Entity

	enabledrag( _ , ent , {DragOnOff = true})
	
	return true
end
