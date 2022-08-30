-- for sql config
local mysql = {
	host = SERVER and "127.0.0.1" or "", -- "",
	database = SERVER and "swaglagmagrag5" or "",
	username = SERVER and "swaglagmagrag" or "",
	password = SERVER and "swaglagmagrag" or "",
	port = SERVER and 3306 or 420
}

if (not Server.IP) then
	Server.BuildAddress()
end

moat.cfg.sql = mysql