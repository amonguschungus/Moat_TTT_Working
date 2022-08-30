surface.CreateFont("moat_wdl", {
	font = "DermaLarge",
	size = 22,
	weight = 700
})

surface.CreateFont("moat_wdls", {
	font = "DermaLarge",
	size = 22,
	weight = 700,
	blursize = 3
})

surface.CreateFont("moat_wdl2", {
	font = "DermaLarge",
	size = 20,
	weight = 600
})

surface.CreateFont("moat_wdl2s", {
	font = "DermaLarge",
	size = 20,
	weight = 600,
	blursize = 3
})

surface.CreateFont("moat_ItemDescShadow3", {
	font = "DermaLarge",
	size = 14,
	weight = 800,
	blursize = 2
})

surface.CreateFont("moat_wdlb3", {
	font = "DermaLarge",
	size = 41,
	weight = 200
})

surface.CreateFont("moat_wdlb3s", {
	font = "DermaLarge",
	size = 41,
	weight = 500,
	blursize = 5
})

Content = Content or {}
Content.cur = 1
Content.ids = {
	-- [1] = "1993862543",
	-- [2] = "1993869386"
	[1] = "1542685010",
	[2] = "1542687639",
	[3] = "1996681978",
	[4] = "2060094075",
}

Content.name = ""
Content.done = true
Content.start = 0
local disable_downloads = CreateClientConVar("disable_downloads", 0, true, false)
local grad_r = Material("vgui/gradient-l")
local windows = system.IsWindows()
function Content.DrawHUD()
	if (Content.done == true) then return end
	if (Content.start < CurTime() and Content.done == true) then return end
	if (not Content.nostuck) then
		Content.nostuck = CurTime() + 300
	end

	if (Content.nostuck <= CurTime()) then
		return
	end

	local scrw = ScrW()
	local dl_num = math.Round(100 - (100/(#Content.ids)) * Content.cur)
	local dl_bar = 1 - (dl_num / 100)
	/*
	surface.SetDrawColor(0, 0, 0, 175)
	surface.DrawRect((scrw/2) - 250, 130, 500, 30)

	surface.SetDrawColor(165, 165, 165, 150)
	surface.DrawOutlinedRect((scrw/2) - 250, 130, 500, 30)

	surface.SetDrawColor(0, 0, 0, 50)
	surface.DrawOutlinedRect((scrw/2) - 251, 129, 502, 32)

	surface.SetDrawColor(175, 25, 25, 255)
	surface.DrawRect((scrw/2) - 249, 131, 498 * dl_bar, 28)

	surface.SetDrawColor(110, 25, 25, 255)
	surface.SetMaterial(grad_r)
	surface.DrawTexturedRect((scrw/2) - 249, 131, 498 * dl_bar, 28)

	draw.Text({
		text = "|",
		font = "moat_wdlb3", 
		pos = {(scrw/2 - 256) + (498 * dl_bar), 121},
		color = Color(255, 255, 255, 100)
	})

	draw.Text({
		text = "|",
		font = "moat_wdlb3s", 
		pos = {(scrw/2 - 256) + (498 * dl_bar), 121},
		color = Color(255, 255, 255, 255)
	})

	draw.Text({
		text = "|",
		font = "moat_wdlb3s", 
		pos = {(scrw/2 - 256) + (498 * dl_bar), 125},
		color = Color(255, 255, 255, 255)
	})
	*/
	local dl_text = "Fixing Errors: " .. dl_num .. "% Remaining.."
	if (dl_num == 0) then
		if (not Content.close) then
			Content.close = CurTime()
		elseif (Content.close and Content.close < CurTime() - 15) then
			Content.done = true
		end

		dl_text = "Finishing Fixing Errors.. Yay!"
	end
	/*
	draw.Text({
		text = dl_text,
		font = "moat_wdl2s", 
		pos = {scrw/2 - 239, 135},
		color = Color(0, 0, 0, 255)
	})

	draw.Text({
		text = dl_text,
		font = "moat_wdl2", 
		pos = {scrw/2 - 240, 134},
		color = Color(200, 200, 200, 255)
	})
	*/
	if (windows) then
		draw.Text({
			text = "Woah, welcome to the server! We're fixing these errors you see for you",
			font = "moat_wdls", 
			pos = {(scrw/2) + 1, 76},
			xalign = TEXT_ALIGN_CENTER,
			color = Color(0, 0, 0, 255)
		})
	end

	draw.Text({
		text = "Woah, welcome to the server! We're fixing these errors you see for you",
		font = "moat_wdl", 
		pos = {(scrw/2), 75},
		xalign = TEXT_ALIGN_CENTER
	})

	if (windows) then
		draw.Text({
			text = "Don't worry, you won't see errors after this!",
			font = "moat_ItemDescShadow3", 
			pos = {(scrw/2) + 1, 101},
			xalign = TEXT_ALIGN_CENTER,
			color = Color(0, 0, 0, 255)
		})
	end

	draw.Text({
		text = "Don't worry, you won't see errors after this!",
		font = "moat_ItemDesc", 
		pos = {(scrw/2), 100},
		xalign = TEXT_ALIGN_CENTER
	})
	
	if (windows) then
		draw.Text({
			text = "You might experience a slight stutter while we do, it's normal <3",
			font = "moat_ItemDescShadow3", 
			pos = {(scrw/2) + 1, 176},
			xalign = TEXT_ALIGN_CENTER,
			color = Color(0, 0, 0, 255)
		})
	end

	draw.Text({
		text = "You might experience a slight stutter while we do, it's normal <3",
		font = "moat_ItemDesc", 
		pos = {(scrw/2), 175},
		xalign = TEXT_ALIGN_CENTER,
	})
end
-- hook.Add("HUDPaint", "Content.drawhud", Content.DrawHUD)

function Content:Location(id, id2)
	if (not id) then return false end

	local addons = file.Find("addons/*" .. id .. ".gma", "GAME")

	if (addons and #addons == 1) then
		return "addons/" .. addons[1]
	end

	if (id2 and file.Exists("cache/workshop/" .. id2 .. ".gma", "GAME")) then
		return "cache/workshop/" .. id2 .. ".gma"
	end

	if (id2 and file.Exists("cache/workshop/" .. id2 .. ".cache", "GAME")) then
		return "cache/workshop/" .. id2 .. ".cache"
	end

	if (file.Exists("cache/workshop/" .. id .. ".gma", "GAME")) then
		return "cache/workshop/" .. id .. ".gma"
	end

	if (file.Exists("cache/workshop/" .. id .. ".cache", "GAME")) then
		return "cache/workshop/" .. id .. ".cache"
	end

	return false
end

function Content:Mount(id, id2, path)
	local cache = Content:Location(id, id2)
	if (cache and not path) then
		path = cache
	end

	local success, returned = pcall(function()
		local did = game.MountGMA(path)
		if (not did) then
			return false
		end

		return true
	end)

	return success
end

local tries = 0
function Content:DownloadID(id, id2, exists)
	steamworks.DownloadUGC(id, function(path, file)
		local success, returned = Content:Mount(id, id2, path)

		-- MsgC(Color(103, 152, 235), "[MG Content] ", Color(255, 255, 255), "Loaded Resource " .. Content.ids[Content.cur] .. ".\n")

		if (exists) then
			-- timer.Simple(1, function() Content:NextAddon() end)
			Content:NextAddon()
		else
			Content:NextAddon()
		end
	end)
end

function Content:DownloadAddon()
	local wid = Content.ids[Content.cur]
	tries = tries + 1

	if (steamworks.IsSubscribed(wid)) then
		Content:Mount(wid)
		Content:NextAddon()
		return
	end

	steamworks.FileInfo(wid, function(r)
		local exists = (file.Exists("cache/workshop/" .. tostring(r.fileid) .. ".cache", "GAME") or file.Exists("cache/workshop/" .. tostring(r.fileid) .. ".gma", "GAME") or file.Exists("cache/workshop/" .. wid .. ".cache", "GAME") or file.Exists("cache/workshop/" .. wid .. ".gma", "GAME") or #file.Find("addons/*" .. wid .. ".gma", "GAME") == 1)
		Content:DownloadID(wid, r.fileid, exists)
	end)
end

function Content:NextAddon()
	Content.cur = Content.cur + 1
	tries = 0

	if (Content.ids[Content.cur]) then
		Content:DownloadAddon()
	else
		Content:FinishDownloads()
	end
end

function Content:HotMount(wid)
	if (steamworks.IsSubscribed(wid)) then
		MsgC(Color(103, 152, 235), "[MOAT.GG ", Color(255, 105, 180), "We're subbed to " .. tostring(wid) .. ".\n")

		return
	end

	steamworks.FileInfo(wid, function(r)
		if (not r) then
			if (tries < 10) then self:HotMount(wid) return end
			return MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Failed to Hot Load " .. tostring(wid) .. ".\n")
		end

		steamworks.Download(r.fileid, true, function(c)
			if (not c) then
				if (tries < 10) then self:HotMount(wid) return end
				return MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Failed to Mount " .. tostring(wid) .. ".\n")
			end

			game.MountGMA(c)

			MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Hot Loaded " .. tostring(wid) .. ".\n")
		end)
	end)
end

local function round(num, idp)
	local mult = 10 ^ (idp or 2)

	return math.floor(num * mult + 0.5) / mult
end

local files = {
	{File='moat/ttt/textures-data.lmp',FileName='textures'},
	{File='moat/ttt/tttbase-data.lmp',FileName='tttbase'},
	{File='moat/ttt/talents-data.lmp',FileName='talents'},
	{File='moat/ttt/weapons-data.lmp',FileName='weapons'}
}
local parent = 'download/data/'
file.CreateDir 'moat/ttt'
MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Init\n")
local compressedSize = 0
local decompressedSize = 0
local totalTime = 0

local function prepare(outFile, inf)
	local start = SysTime()
	local fh = file.Open(parent .. inf.File, 'rb', 'GAME')

	if (not fh) then
		MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Unable to open datapack: "..inf.FileName.."\n")

		return false
	end

	local size = fh:Size()
	compressedSize = compressedSize + size
	local compressedData = fh:Read(size)
	fh:Close()

	if (not compressedData) then
		MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Unable to read datapack: "..inf.FileName.."\n")

		return false
	end

	local rawData = util.Decompress(compressedData)
	compressedData = nil
	collectgarbage()

	if (not rawData) then
		MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Unable to decompress datapack: "..inf.FileName.."\n")

		return false
	end

	local fh2 = file.Open(outFile, 'wb', 'DATA')

	if (not fh2) then
		MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Unable to open outfile for datapack: "..inf.FileName.."\n")

		return false
	end

	decompressedSize = decompressedSize + rawData:len()
	fh2:Write(rawData)
	fh2:Close()
	rawData = nil
	collectgarbage()
	local time = (SysTime() - start)
	totalTime = totalTime + time

	MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Cached datapack: "..inf.FileName.." in "..round(time, 4).." seconds\n")

	return true
end

local totalFiles = 0

local function mount(inf)
	local outFile = inf.File .. '.dat'
	local isCached = file.Exists(outFile, 'DATA')

	if (not isCached) and (not file.Exists(parent .. inf.File, 'GAME')) then
		MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Missing datapack: "..inf.FileName.."\n")

		return 0
	end

	if (not isCached) and (not prepare(outFile, inf)) then return 0 end
	local start = SysTime()
	local succ, files = game.MountGMA('data/' .. outFile)

	if (not succ) then
		MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Failing to mount datapack: "..inf.FileName.."\n")

		return 0
	end

	totalFiles = totalFiles + #files
	local time = (SysTime() - start)
	MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Mounted datapack: "..inf.FileName.." in "..round(time, 4).." seconds\n")

	return time
end

for k, v in ipairs(files) do
	totalTime = totalTime + mount(v)
end

if (compressedSize > 0) then
	MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Decompressed "..round(compressedSize / 1048576) .. "MB\n")
end

if (decompressedSize > 0) then
	MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Cached "..round(decompressedSize / 1048576) .. "MB\n")
end

MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Loaded "..totalFiles.." files\n")
MsgC(Color(103, 152, 235), "[MOAT.GG] ", Color(255, 105, 180), "Finished in "..round(totalTime, 4).." seconds\n")