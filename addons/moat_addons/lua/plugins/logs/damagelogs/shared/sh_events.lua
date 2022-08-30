Damagelog.events = Damagelog.events or {}
Damagelog.IncludedEvents = Damagelog.IncludedEvents or {}
function Damagelog:AddEvent(event, f)

	local id = #self.events + 1

	function event.CallEvent(tbl, force_time, force_index)
		if GetRoundState() != ROUND_ACTIVE or GetGlobal("MOAT_MINIGAME_ACTIVE") then return end
		self:CheckDamageTable()
		local time
		if force_time then
			time = tbl[force_time]
		else
			time = self.Time
		end
		tbl.horray = false
		local infos = {
			id = id,
			type = event.Type,
			time = time,
			round = self.CurrentRound,
			infos = tbl
		}
		if force_index then
			self.DamageTable[tbl[force_index]] = infos
		else
			table.insert(self.DamageTable, infos)
		end
	
		local recip = {}
		for k,v in pairs(player.GetAll()) do
			if v:CanUseDamagelog() then
				table.insert(recip, v)
			end
		end
		net.Start("M_DL_RefreshDamagelog")
		net.WriteTable(infos)
		net.Send(recip)
		
	end
	
	self.events[id] = event
	table.insert(self.IncludedEvents, Damagelog.CurrentFile)

end

if SERVER then

	Damagelog.event_hooks = {}

	function Damagelog:InitializeEventHooks()
		for _,name in pairs(self.event_hooks) do
			hook.Add(name, "Damagelog_events_"..name, function(...)
				for k,v in pairs(self.events) do
					if v[name] then 
						v[name](v, ...)
					end
				end
			end)
		end
	end
	
	function Damagelog:EventHook(name)
		if not table.HasValue(self.event_hooks, name) then
			table.insert(self.event_hooks, name)
		end
	end
	
end

function Damagelog:IsTeamkill(role1, role2)
	if role1 == role2 then 
		return true
	elseif role1 == ROLE_DETECTIVE and role2 == ROLE_INNOCENT then 
		return true
	elseif role1 == ROLE_INNOCENT and role2 == ROLE_DETECTIVE then 
		return true
	end
	return false
end

local function includeEventFile(f)
	f = "_events/"..f
	if SERVER then
		AddCSLuaFile(f)
	end
	include(f)
end

local files = {
	"bodyfound.lua",
	"credits.lua",
	"damages.lua",
	"dna.lua",
	"fall_damage.lua",
	"kills.lua",
	"misc.lua",
	"nades.lua",
	"suicide.lua",
	"ttt_button.lua",
	"ttt_radio.lua",
	"weapons.lua",
}

for k,v in ipairs(files) do
	if not table.HasValue(Damagelog.IncludedEvents, v) then
		Damagelog.CurrentFile = v
		includeEventFile(v)
	end
end
if CLIENT then 
	Damagelog:SaveColors()
	Damagelog:SaveFilters()
else
	Damagelog:InitializeEventHooks() 
end
