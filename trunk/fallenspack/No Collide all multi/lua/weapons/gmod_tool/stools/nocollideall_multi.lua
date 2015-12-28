TOOL.Category		= "Constraints"
TOOL.Name			= "#No-Collide All Multi"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "freeze" ] = 1
TOOL.ClientConVar[ "on" ] = 1
TOOL.ClientConVar[ "base" ] = 0
TOOL.ClientConVar[ "remove" ] = 0

if ( CLIENT ) then
    language.Add( "Tool_nocollideall_multi_name", "Multi No-Collide All tool" )
    language.Add( "Tool_nocollideall_multi_desc", "No-Collide All one or multiple props. You can also No-Collide everything to what you are looking at" )
    language.Add( "Tool_nocollideall_multi_0", "Primary: Select a prop to No-Collide. (Use to select all) Secondary: Confirm No-Collide. Reload: Clear Targets." )
end

TOOL.enttbl = {}

/*******************************************************************************************************
Purpose: this function is what's needed to make dupe support work the "_" is a replacement for the Player argument whiich the function needs
*******************************************************************************************************/
local function SetGroup(_,Entity,Data)
	if not Data.Group then return false end
	Entity:SetCollisionGroup(Data.Group)
	duplicator.StoreEntityModifier( Entity, "nocollideall" , Data)
end
duplicator.RegisterEntityModifier( "nocollideall", SetGroup )


function TOOL:LeftClick(Trace)
	if CLIENT then return true end
	local ent = Trace.Entity
	if !ent:IsValid() or ent:IsPlayer() or ent:IsWorld() then return false end
	if self:GetOwner():KeyDown(IN_USE) then
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if !self.enttbl[v] then
				self.enttbl[v] = Color(v:GetColor())
				v:SetColor(40,255,0,150)
			end
		end
	else
		if not self.enttbl[ent] then
			self.enttbl[ent] = Color(ent:GetColor())
			ent:SetColor(40,255,0,150)
		else
			local temp = self.enttbl[ent]
			ent:SetColor(temp.r,temp.g,temp.b,temp.a)
			self.enttbl[ent] = nil
		end
	end
	return true
end

function TOOL:RightClick(trace)
	if CLIENT then return true end
	if table.Count(self.enttbl) < 1 then return end

	local freeze = self:GetClientNumber( "freeze" )
	local onoff = self:GetClientNumber( "on" )
	local nocollidetobase = self:GetClientNumber( "base" )
	local removedupe = self:GetClientNumber( "remove" )
	
	local ent = trace.Entity
	for k,v in pairs(self.enttbl) do
		if k:IsValid() then
			k:SetColor(v.r,v.g,v.b,v.a)
			if onoff == 1 then
				group = COLLISION_GROUP_WORLD
			end
			if onoff == 0 then
				group = COLLISION_GROUP_NONE
			end	
			SetGroup(_,k,{Group = group})
			
			if nocollidetobase == 1 and ent:IsValid() and !ent:IsWorld() then
				local constraint = constraint.NoCollide(ent,k,0,0)
				undo.Create("#No-collide to base")
					undo.AddEntity( constraint )
					undo.SetPlayer( self:GetOwner() )
				undo.Finish()
			end
			if freeze == 1 then
				phys = k:GetPhysicsObject()
				if phys:IsMoveable() then
					phys:EnableMotion(false)
					phys:Wake()
				end
			end
		end
	end 
	self.enttbl = {}
	return true
end


function TOOL:Reload()
	if table.Count(self.enttbl) < 1 then return end
	
	for k,v in pairs(self.enttbl) do
		if k:IsValid() then
			k:SetColor(v.r,v.g,v.b,v.a)
		end
	end
	self.enttbl = {}
	return true
end

if CLIENT then
	function TOOL.BuildCPanel(Panel)
		local temp
		Panel:AddControl("Header",{Text = "#nocollideall_multi_name", Description	= "#nocollideall_multi_desc"})	
		temp = Panel:AddControl("CheckBox", {Label = "Collisions", Description ="No-Collide all or don't NO-Collide all the props", Command = "nocollideall_multi_on"})
		temp:SetToolTip("Ticking this means that collisions with other props will be turned OFF for the selected entities.")
		temp = Panel:AddControl("CheckBox", {Label = "Freeze", Description ="Freeze or UnFreeze the props", Command = "nocollideall_multi_freeze"})
		temp:SetToolTip("Ticking this will freeze all selected entities.")
		temp = Panel:AddControl("CheckBox", {Label = "No-Collide to Base", Description ="No-Collide to what you are looking at", Command = "nocollideall_multi_base"})
		temp:SetToolTip("checking this nocollides all selected props to what you are looking at. (useful when parenting)")
	end
end