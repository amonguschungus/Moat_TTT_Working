moat_contracts_v2 = {}
wpn_contracts = {}
kill_contracts = {}
util.AddNetworkString("moat.contracts")
util.AddNetworkString("moat.contractinfo")
util.AddNetworkString("moat.contracts.chat")
util.AddNetworkString("lottery.updateamount")
util.AddNetworkString("lottery.updatepopular")
util.AddNetworkString("lottery.Purchase")
util.AddNetworkString("lottery.updatetotal")
util.AddNetworkString("lottery.firstjoin")
util.AddNetworkString("lottery.Win")
util.AddNetworkString("lottery.last")
util.AddNetworkString("moat_bounty_send")
util.AddNetworkString("moat_bounty_update")
util.AddNetworkString("moat_bounty_chat")
util.AddNetworkString("moat_bounty_reload")
util.AddNetworkString("bounty.refresh")
MOAT_BOUNTIES = MOAT_BOUNTIES or {}
MOAT_BOUNTIES.DatabasePrefix = "live1"
MOAT_BOUNTIES.Bounties = {}
MOAT_BOUNTIES.ActiveBounties = {}
XP_MULTIPLIER = XP_MULTIPLIER or 1

function MOAT_BOUNTIES.CreateTable(name, create)
    if (not sql.TableExists(name)) then
        sql.Query(create)
        MsgC(Color(0, 255, 0), "Created SQL Table: " .. name .. "\n")
    end
end

function MOAT_BOUNTIES:BroadcastChat(tier, str)
    net.Start("moat_bounty_chat")
    net.WriteUInt(tier, 4)
    net.WriteString(str)
    net.Broadcast()
end

function MOAT_BOUNTIES:SendChat(tier, str, ply)
    net.Start("moat_bounty_chat")
    net.WriteUInt(tier, 4)
    net.WriteString(str)
    net.Send(ply)
end

local top_cache
contract_starttime = os.time()
contract_id = 0
contract_loaded = false

local function c()
    return MINVENTORY_MYSQL and MINVENTORY_MYSQL:status() == mysqloo.DATABASE_CONNECTED
end

function contract_increase(ply, am)
    -- what
end

function createsql()
    local db = MINVENTORY_MYSQL
    local q = db:query("DROP PROCEDURE IF EXISTS createUserInfo; CREATE PROCEDURE createUserInfo(in stid text, in stname text charset utf8mb4, in ipaddr text, in ostime bigint) BEGIN set @Count = (SELECT COUNT(*) AS Cnt FROM player WHERE `SteamID`=stid); if (@Count = 0) then insert into player (`SteamID`, `SteamName`, `FirstJoined`, `Vars`) VALUES (stid, stname, ostime, null); insert into player_iplog (`SteamID`, `Address`, `LastSeen`) VALUES(stid, ipaddr, -1); select 1 as Created; else select 0 as Created; end if; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS selectUserInfo; CREATE PROCEDURE selectUserInfo(in stid text) BEGIN SELECT player.SteamName, player.Rank, player.TimePlayed, player.FirstJoined, player.Vars, player_iplog.Address, player_iplog.LastSeen FROM player, player_iplog WHERE player.SteamID=stid AND player_iplog.SteamID=stid ORDER BY LastSeen DESC LIMIT 1; END; DROP PROCEDURE IF EXISTS updateUserInfo; CREATE PROCEDURE updateUserInfo(in stid text, in steamname text, in ipaddr text, in ostime bigint) BEGIN update player set `SteamName` = steamname where `SteamID` = stid; delete from player_iplog where `SteamID` = stid and `Address` = ipaddr; INSERT INTO player_iplog (`SteamID`, `Address`, `LastSeen`) VALUES (stid, ipaddr, ostime); END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS removeItem; CREATE PROCEDURE removeItem(in cid int) BEGIN update mg_items set ownerid = 0 where id = cid; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS transferItem; CREATE PROCEDURE transferItem(in cid int, in owner bigint) BEGIN update mg_items set ownerid = owner where id = cid; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS updateItemStat; CREATE PROCEDURE updateItemStat(in cid int, in stat char(1), in newval float) BEGIN update mg_itemstats set statid = newval where weaponid = cid; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS insertItemName; CREATE PROCEDURE insertItemName(in uid int unsigned, in nstr varchar(32)) BEGIN insert into moat_inv_items_names (weaponid, nickname) values (uid, nstr); select uid as cid; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS selectStats; CREATE PROCEDURE selectStats(in steamid bigint) BEGIN select var, val from mg_players where id = steamid; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS selectStat; CREATE PROCEDURE selectStat(in steamid bigint, in stat char(1)) BEGIN select var, val from mg_players where id = steamid and var = stat; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS saveStat; CREATE PROCEDURE saveStat(in `steamid` bigint, in `stat` CHAR(1), in `num` INT) BEGIN insert into mg_players (id, var, val) values (steamid, stat, num) on duplicate key update val = num; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS getSteamIDFromDiscordTag; CREATE PROCEDURE getSteamIDFromDiscordTag(in tag varchar(255)) BEGIN SET @mid = (SELECT member_id FROM memberssocialinfo_sites WHERE discord LIKE tag LIMIT 1); if (FOUND_ROWS() = 0) then select 0 as steamid; else select steamid FROM core_members WHERE member_id LIKE @mid LIMIT 1; end if; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS selectRconCommands; CREATE PROCEDURE selectRconCommands(in `srvr` varchar(255)) BEGIN select id, staff_steamid, staff_rank, staff_name, command, args, steamid from rcon_commands as rc inner join rcon_queue as rq on rc.id = rq.cmdid where rq.server = srvr; END;")
    q:start()
    local q = db:query("INSERT INTO moat_contracts_v2 (contract,start_time,updating_server,contract_id) VALUES ('Global Shotgun Killer', CURRENT_TIMESTAMP, '1.1.1.1:27015', 1)")
    q:start()
    local q = db:query([[DROP PROCEDURE IF EXISTS insertRconCommand;
    CREATE PROCEDURE insertRconCommand(in `sid` varchar(30), in `srank` tinytext, in `sname` text, in `cmd` text, in `srvr` varchar(255), in `arg` text, in `sido` varchar(30))
    BEGIN
        insert into rcon_commands (staff_steamid, staff_rank, staff_name, `server`, command, args, steamid) values (sid, srank, sname, srvr, cmd, arg, sido);
    
        set @cid = LAST_INSERT_ID();
        if (srvr = "*") then
            set @num = (SELECT COUNT(*) FROM player_servers);
            while @num > 0 do
                select ip, port into @i, @p from player_servers where id = @num;
                insert into rcon_queue (cmdid, server) values (@cid, concat(@i, ":", @p));
                set @num = @num - 1;
            end while;
        else
            insert into rcon_queue (cmdid, server) values (@cid, srvr);
        end if;
    
        select @cid as cmd_id;
    END;]])
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS selectContract; CREATE PROCEDURE selectContract(in `id` varchar(255)) BEGIN SELECT score as myscore, steamid, (SELECT COUNT(*) FROM moat_contractplayers_v2 WHERE score >= myscore) AS position, (SELECT COUNT(steamid) FROM moat_contractplayers_v2) AS players FROM moat_contractplayers_v2 WHERE steamid = id; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS removeRconCommands; CREATE PROCEDURE removeRconCommands(in srvr varchar(255)) BEGIN delete from rcon_queue where server = srvr; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS selectContracts; CREATE PROCEDURE selectContracts(in `ip` varchar(255)) BEGIN SELECT `moat_contractplayers`.`score` as myscore, `moat_contractplayers`.`steamid`, (SELECT COUNT(*) FROM `moat_contractplayers` WHERE score >= myscore) AS position, (SELECT COUNT(steamid) FROM moat_contractplayers) AS players FROM `moat_contractplayers` INNER JOin `player_sessions` ON (`moat_contractplayers`.`steamid` = `player_sessions`.`steamid64` AND `player_sessions`.`server` = ip) ORDER BY score; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS insertPayload; CREATE PROCEDURE insertPayload(in `pl` mediumtext) BEGIN INSERT INTO github_payloads (payload) VALUES (pl); SELECT LAST_INSERT_ID() AS pid; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS updateGithubAuthors; CREATE PROCEDURE updateGithubAuthors(in `puid` varchar(255), in `pname` text, in `pemail` text, in `pnode_id` text, in `pavatar_url` text, in `pgithub_url` text) BEGIN INSERT INTO github_authors (uid, name, email, node_id, avatar_url, github_url) VALUES (puid, pname, pemail, pnode_id, pavatar_url, pgithub_url) ON DUPLICATE KEY UPDATE name = pname, email = pemail, avatar_url = pavatar_url, github_url = pgithub_url; SELECT id FROM github_authors WHERE uid = puid; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS selectInventory; CREATE PROCEDURE selectInventory(in `steamid64` bigint) BEGIN SELECT id, itemid, slotid, classname FROM mg_items WHERE ownerid = steamid64; SELECT id, statid, value FROM mg_itemstats as ws INNER JOin mg_items as wd ON ws.weaponid = wd.id WHERE wd.ownerid = steamid64; SELECT id, talentid, required, modification, value FROM mg_itemtalents as wt INNER JOin mg_items as wd ON wt.weaponid = wd.id WHERE wd.ownerid = steamid64 ORDER BY modification; SELECT id, nickname FROM mg_itemnames as wn INNER JOin mg_items as wd ON wn.weaponid = wd.id WHERE wd.ownerid = steamid64; SELECT id, type, paintid FROM mg_itempaints as wp INNER JOin mg_items as wd ON wp.weaponid = wd.id WHERE wd.ownerid = steamid64; END;")
    q:start()
    local q = db:query("DROP PROCEDURE IF EXISTS TakeDonatorCredits; CREATE PROCEDURE TakeDonatorCredits(in steamid64 bigint, in credits int) BEGIN UPDATE player SET donator_credits = donator_credits - credits WHERE steam_id = steamid64; SELECT donator_credits FROM player WHERE steam_id = steamid64; END;")
    q:start()
    local q = db:query("INSERT moat_lottery SET amount = 1000")
    q:start()
    local q = db:query("INSERT moat_lottery_last SET num = 1")
    q:start()
    local dq = db:query("CREATE TABLE IF NOT EXISTS `moat_contracts_v2` ( ID int NOT NULL AUTO_INCREMENT, `contract` varchar(64) NOT NULL, `start_time` TIMESTAMP NOT NULL, `contract_id` int, `updating_server` VARCHAR(32), PRIMARY KEY (ID) ) ")
    dq:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_contractplayers_v2` ( `steamid` varchar(100) NOT NULL, `score` INT NOT NULL, PRIMARY KEY (steamid) ) ")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_contractwinners_v2` ( `steamid` bigint unsigned NOT NULL, `place` INT unsigned NOT NULL, PRIMARY KEY (steamid) ) ")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_contractrig` ( `contract` varchar(100) NOT NULL, PRIMARY KEY (contract) ) ")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_veterangamers` ( `steamid` varchar(20) NOT NULL, PRIMARY KEY (steamid) ) ")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_lottery` ( `amount` INT NOT NULL, PRIMARY KEY (amount) ) ")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_lottery_last` ( `num` INT NOT NULL, PRIMARY KEY (num) ) ")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_lottery_players` ( `steamid` varchar(32), `name` varchar(255), `ticket` INT NOT NULL, PRIMARY KEY (steamid) ) ")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_lottery_winners` ( `steamid` varchar(32), `amount` INT NOT NULL, PRIMARY KEY (steamid) ) ")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `bounties_current` (ID int NOT NULL AUTO_INCREMENT, bounties TEXT NOT NULL, PRIMARY KEY (ID))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `bounties_players` (`steamid` varchar(100) NOT NULL, `score` TEXT NOT NULL, PRIMARY KEY (steamid) )")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_battlepass` (`steamid` varchar(32) NOT NULL, `tier` int(11) NOT NULL, `xp` int(11) NOT NULL, PRIMARY KEY (steamid) )")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `rcon_commands` (`id` int(10) unsigned NOT NULL AUTO_INCREMENT, `staff_steamid` varchar(30) NOT NULL, `staff_rank` text NOT NULL, `staff_name` text DEFAULT NULL, `server` varchar(255) NOT NULL, `command` mediumtext NOT NULL, `args` text DEFAULT NULL, `steamid` varchar(30) DEFAULT NULL, `date` timestamp DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `rcon_queue` (`cmdid` int(10) unsigned NOT NULL, `server` varchar(255) NOT NULL, `date` timestamp DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`cmdid`,`server`), CONSTRAINT `fk_rcon_queue_rcon_commands` FOREIGN KEY (`cmdid`) REFERENCES `rcon_commands` (`id`) ON DELETE CASCADE)")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_mapvote_prevent` (`active` tinyint(4) NOT NULL, PRIMARY KEY (`active`))")
    q:start()
    local e = [[CREATE TABLE IF NOT EXISTS `player_servers` (
        `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
        `name` varchar(255) NOT NULL,
        `full_ip` varchar(45) DEFAULT NULL,
        `map` varchar(255) DEFAULT 'NULL',
        `players` int(10) unsigned DEFAULT NULL,
        `staff` int(10) unsigned DEFAULT NULL,
        `ip` varchar(255) NOT NULL,
        `port` varchar(10) NOT NULL,
        `custom_ip` varchar(255) NOT NULL,
        `join_url` varchar(255) DEFAULT NULL,
        `hostname` varchar(255) DEFAULT 'NULL',
        `map_changed` int(10) unsigned DEFAULT NULL,
        `max_players` int(10) unsigned DEFAULT NULL,
        `rounds_left` int(10) unsigned DEFAULT NULL,
        `round_state` varchar(50) NOT NULL,
        `time_left` int(10) unsigned DEFAULT NULL,
        `map_time_left` int(10) unsigned DEFAULT NULL,
        `traitors_alive` int(10) unsigned DEFAULT NULL,
        `innocents_alive` int(10) unsigned DEFAULT NULL,
        `others_alive` int(10) unsigned DEFAULT NULL,
        `spectators` int(10) unsigned DEFAULT NULL,
        `traitor_wins` int(10) unsigned DEFAULT NULL,
        `innocent_wins` int(10) unsigned DEFAULT NULL,
        `top_player_steamid` bigint(20) unsigned DEFAULT NULL,
        `top_player_name` varchar(255) DEFAULT NULL,
        `top_player_score` int(10) unsigned DEFAULT NULL,
        `special_round` varchar(255) DEFAULT NULL,
        `map_event` varchar(255) DEFAULT NULL,
        `last_update` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`),
        UNIQUE KEY `ip` (`ip`,`port`),
        UNIQUE KEY `full_ip` (`full_ip`)
    );]]
    local q = db:query(e)
    q:start()
    local e = [[CREATE TABLE IF NOT EXISTS `player_warns` (
        `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
        `steam_id` bigint(20) unsigned NOT NULL,
        `staff_steam_id` bigint(20) unsigned NOT NULL,
        `name` varchar(100) NOT NULL,
        `staff_name` varchar(100) NOT NULL,
        `time` int(10) unsigned NOT NULL,
        `reason` varchar(255) NOT NULL,
        `acknowledged` int(10) unsigned DEFAULT NULL,
        PRIMARY KEY (`id`),
        KEY `acknowledged` (`acknowledged`),
        KEY `steam_id` (`steam_id`)
    );]]
    local q = db:query(e)
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `core_ttt_oct` ( `steamid` varchar(100) NOT NULL, `max_slots` int(255) NOT NULL, `credits` mediumtext NOT NULL, `l_slot1` mediumtext DEFAULT NULL, `l_slot2` mediumtext DEFAULT NULL, `l_slot3` mediumtext DEFAULT NULL, `l_slot4` mediumtext DEFAULT NULL, `l_slot5` mediumtext DEFAULT NULL, `l_slot6` mediumtext DEFAULT NULL, `l_slot7` mediumtext DEFAULT NULL, `l_slot8` mediumtext DEFAULT NULL, `l_slot9` mediumtext DEFAULT NULL, `l_slot10` mediumtext DEFAULT NULL, `inventory` longtext NOT NULL, PRIMARY KEY (`steamid`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `core_ttt_old` ( `steamid` varchar(100) NOT NULL, `max_slots` int(255) NOT NULL, `credits` mediumtext NOT NULL, `l_slot1` mediumtext DEFAULT NULL, `l_slot2` mediumtext DEFAULT NULL, `l_slot3` mediumtext DEFAULT NULL, `l_slot4` mediumtext DEFAULT NULL, `l_slot5` mediumtext DEFAULT NULL, `l_slot6` mediumtext DEFAULT NULL, `l_slot7` mediumtext DEFAULT NULL, `l_slot8` mediumtext DEFAULT NULL, `l_slot9` mediumtext DEFAULT NULL, `l_slot10` mediumtext DEFAULT NULL, `inventory` longtext NOT NULL, PRIMARY KEY (`steamid`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_errors` ( `id` int(11) NOT NULL AUTO_INCREMENT, `error` mediumtext NOT NULL, `serverip` varchar(255) NOT NULL, `realm` tinyint(1) NOT NULL, `stack` mediumtext DEFAULT NULL, `steamid` varchar(20) DEFAULT NULL, `date` timestamp DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `core_dev_ttt` ( `steamid` varchar(100) NOT NULL, `max_slots` int(255) NOT NULL, `credits` mediumtext NOT NULL, `l_slot1` mediumtext DEFAULT NULL, `l_slot2` mediumtext DEFAULT NULL, `l_slot3` mediumtext DEFAULT NULL, `l_slot4` mediumtext DEFAULT NULL, `l_slot5` mediumtext DEFAULT NULL, `l_slot6` mediumtext DEFAULT NULL, `l_slot7` mediumtext DEFAULT NULL, `l_slot8` mediumtext DEFAULT NULL, `l_slot9` mediumtext DEFAULT NULL, `l_slot10` mediumtext DEFAULT NULL, `inventory` longtext NOT NULL, `inventory_backup` longtext NOT NULL, PRIMARY KEY (`steamid`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player` (`steam_id` bigint(17) NOT NULL, `name` varchar(100) DEFAULT NULL, `rank` varchar(60) DEFAULT NULL, `first_join` int(10) DEFAULT NULL, `karma` int(10) DEFAULT 2000, `last_join` int(10) DEFAULT NULL, `avatar_url` varchar(150) DEFAULT NULL, `playtime` int(10) DEFAULT NULL, `inventory_credits` int(10) unsigned DEFAULT NULL, `event_credits` int(10) unsigned DEFAULT NULL, `donator_credits` int(10) unsigned DEFAULT NULL, `extra` varchar(150) DEFAULT NULL, `rank_expire` int(11) DEFAULT NULL, `rank_expire_to` varchar(32) DEFAULT NULL, `rank_changed` int(11) DEFAULT NULL, `mvp_access` int(11) DEFAULT NULL, PRIMARY KEY (`steam_id`), KEY `rank` (`rank`), KEY `inventory_credits` (`inventory_credits`), KEY `playtime` (`playtime`), KEY `last_join` (`last_join`), FULLTEXT KEY `name` (`name`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_logs` (`id` int(10) unsigned NOT NULL AUTO_INCREMENT, `steam_id` bigint(20) unsigned NOT NULL, `name` varchar(100) NOT NULL, `cmd` varchar(100) NOT NULL, `args` text NOT NULL, `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (`id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_gmod` ( `data_day` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `owners` int(11) NOT NULL, `price` float NOT NULL, `event` varchar(255) DEFAULT NULL, `event_link` varchar(255) DEFAULT NULL, PRIMARY KEY (`data_day`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_iplog` ( `LastSeen` bigint(20) NOT NULL, `SteamID` varchar(50) NOT NULL, `Address` varchar(50) NOT NULL, KEY `SteamID` (`SteamID`), KEY `Address` (`Address`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_ranks` ( `name` varchar(255) NOT NULL, `weight` int(11) NOT NULL, `flags` tinytext NOT NULL, PRIMARY KEY (`name`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `staff_tracker` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, `steamid` bigint(20) unsigned NOT NULL, `join_time` timestamp DEFAULT CURRENT_TIMESTAMP, `leave_time` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `rounds_played` tinyint(10) unsigned NOT NULL DEFAULT 0, `rounds_on` int(10) unsigned NOT NULL DEFAULT 0, `time_played` int(10) unsigned NOT NULL DEFAULT 0, `reports_handled` smallint(10) unsigned NOT NULL DEFAULT 0, `server_ip` int(4) unsigned NOT NULL, `server_port` smallint(2) unsigned NOT NULL, PRIMARY KEY (`id`), KEY `join_time` (`join_time`), KEY `leave_time` (`leave_time`), KEY `steamid` (`steamid`), KEY `server_ip` (`server_ip`), KEY `server_port` (`server_port`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `stats` ( `id` int(11) NOT NULL AUTO_INCREMENT, `steamid` varchar(30) NOT NULL, `credits` int(11) NOT NULL, `time` int(11) NOT NULL, `rank` mediumtext NOT NULL, `name` mediumtext NOT NULL, PRIMARY KEY (`id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `steam_rewards` ( `steam` char(20) NOT NULL, `value` int(11) NOT NULL, PRIMARY KEY (`steam`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `titles` (`id` int(11) NOT NULL AUTO_INCREMENT, `steamid` varchar(30) NOT NULL, `title` mediumtext NOT NULL, `color` mediumtext NOT NULL, `changerid` varchar(30) NOT NULL, PRIMARY KEY (`id`), UNIQUE KEY `steamid` (`steamid`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `customnotifications_notifications` ( `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID Number', `options` mediumtext DEFAULT NULL, `enabled` tinyint(1) NOT NULL DEFAULT 1, `to_run` int(10) DEFAULT 0, `bf_options` int(11) NOT NULL DEFAULT 0, `url` mediumtext DEFAULT NULL, `member_id` int(11) NOT NULL DEFAULT 0, `sent_on` int(11) DEFAULT NULL, PRIMARY KEY (`id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_bans_trading` (`steam_id` bigint(20) NOT NULL, `staff_steam_id` bigint(20) NOT NULL, `reason` varchar(255) NOT NULL, `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (`steam_id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_bans` (`id` int(5) NOT NULL AUTO_INCREMENT, `time` int(11) DEFAULT NULL, `steam_id` bigint(17) DEFAULT NULL, `staff_steam_id` bigint(17) DEFAULT NULL, `name` varchar(100) DEFAULT NULL, `staff_name` varchar(100) DEFAULT NULL, `length` int(11) DEFAULT NULL, `reason` varchar(200) DEFAULT NULL, `unban_reason` varchar(200) DEFAULT NULL, PRIMARY KEY (`id`), KEY `SteamID` (`steam_id`), KEY `A_SteamID` (`staff_steam_id`), KEY `Name` (`name`), KEY `A_Name` (`staff_name`), KEY `length` (`length`), KEY `time` (`time`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_bans_comms` (`id` int(10) unsigned NOT NULL AUTO_INCREMENT, `ban_type` tinyint(3) unsigned NOT NULL, `steam_id` bigint(20) unsigned NOT NULL, `staff_steam_id` bigint(20) unsigned NOT NULL, `name` varchar(32) DEFAULT NULL, `staff_name` varchar(32) DEFAULT NULL, `length` int(10) unsigned DEFAULT NULL, `time` int(10) unsigned DEFAULT NULL, `reason` varchar(255) DEFAULT NULL, `unban_reason` varchar(255) DEFAULT NULL, `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (`id`), KEY `steam_id` (`steam_id`), KEY `length` (`length`), KEY `time` (`time`), KEY `unban_reason` (`unban_reason`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_bans_trading` (`steam_id` bigint(20) NOT NULL, `staff_steam_id` bigint(20) NOT NULL, `reason` varchar(255) NOT NULL, `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (`steam_id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_bans_votekick` (`steam_id` bigint(20) NOT NULL, `staff_steam_id` bigint(20) NOT NULL, `reason` varchar(255) NOT NULL, `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (`steam_id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `player_cmds` (`name` varchar(100) NOT NULL, `flag` char(1) DEFAULT NULL, `weight` bit(1) DEFAULT b'0', `args` mediumtext DEFAULT NULL, PRIMARY KEY (`name`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `mse_logs` (`id` int(11) NOT NULL AUTO_INCREMENT, `steamid` varchar(30) NOT NULL, `cmd` mediumtext NOT NULL, `time` mediumtext NOT NULL, PRIMARY KEY (`id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `mse_players` (`id` int(11) NOT NULL AUTO_INCREMENT, `steamid` varchar(30) NOT NULL, `rank` mediumtext NOT NULL, `cooldown` int(11) NOT NULL, `amount` int(11) NOT NULL, PRIMARY KEY (`id`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `ac_hashes_real` (`hash` binary(64) NOT NULL, `triggers` int(10) unsigned NOT NULL DEFAULT 1, PRIMARY KEY (`hash`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `ac_hash_track_real` ( `steamid` bigint(20) unsigned NOT NULL, `hash` binary(64) NOT NULL, PRIMARY KEY (`steamid`,`hash`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_rollsave` (`id` int(255) NOT NULL AUTO_INCREMENT, `steamid` varchar(32) NOT NULL, `item_tbl` mediumtext NOT NULL, PRIMARY KEY (`id`), KEY `steamid` (`steamid`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_stats` ( `steamid` varchar(32) NOT NULL, `stats_tbl` mediumtext NOT NULL, PRIMARY KEY (`steamid`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_feedback` (`vote` int(11) NOT NULL, `map` varchar(100) NOT NULL, `steamid` varchar(32) NOT NULL, KEY `vote` (`vote`), KEY `map` (`map`), KEY `steamid` (`steamid`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_logs` ( `ID` int(11) NOT NULL AUTO_INCREMENT, `time` int(11) NOT NULL, `message` mediumtext NOT NULL, PRIMARY KEY (`ID`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_gchat` (`ID` int(11) NOT NULL AUTO_INCREMENT, `steamid` varchar(255) NOT NULL, `time` int(11) NOT NULL, `name` varchar(255) CHARACTER SET utf8mb4 NOT NULL, `msg` mediumtext NOT NULL, PRIMARY KEY (`ID`), KEY `time` (`time`))")
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `moat_mapvote_prevent` (`active` tinyint(4) NOT NULL, PRIMARY KEY (`active`))")
    q:start()
    local e = [[CREATE TABLE IF NOT EXISTS `core_members` (
        `member_id` mediumint(8) NOT NULL AUTO_INCREMENT,
        `name` varchar(255) NOT NULL DEFAULT '',
        `member_group_id` smallint(3) NOT NULL DEFAULT 0,
        `email` varchar(150) NOT NULL DEFAULT '',
        `joined` int(10) NOT NULL DEFAULT 0,
        `ip_address` varchar(46) NOT NULL DEFAULT '',
        `skin` smallint(5) DEFAULT NULL,
        `warn_level` int(10) DEFAULT NULL,
        `warn_lastwarn` int(10) NOT NULL DEFAULT 0,
        `language` mediumint(4) DEFAULT NULL,
        `restrict_post` int(10) NOT NULL DEFAULT 0,
        `bday_day` int(2) DEFAULT NULL,
        `bday_month` int(2) DEFAULT NULL,
        `bday_year` int(4) DEFAULT NULL,
        `msg_count_new` int(2) NOT NULL DEFAULT 0,
        `msg_count_total` int(3) NOT NULL DEFAULT 0,
        `msg_count_reset` int(1) NOT NULL DEFAULT 0,
        `msg_show_notification` int(1) NOT NULL DEFAULT 0,
        `last_visit` int(10) DEFAULT 0,
        `last_activity` int(10) DEFAULT 0,
        `mod_posts` int(10) NOT NULL DEFAULT 0,
        `auto_track` varchar(255) DEFAULT '0',
        `temp_ban` int(10) DEFAULT 0,
        `mgroup_others` varchar(245) NOT NULL DEFAULT '',
        `member_login_key_expire` int(10) NOT NULL DEFAULT 0,
        `members_seo_name` varchar(255) NOT NULL DEFAULT '',
        `members_cache` mediumtext DEFAULT NULL,
        `failed_logins` text DEFAULT NULL,
        `failed_login_count` smallint(3) NOT NULL DEFAULT 0,
        `members_profile_views` int(10) unsigned NOT NULL DEFAULT 0,
        `members_pass_hash` varchar(255) DEFAULT NULL,
        `members_pass_salt` varchar(22) DEFAULT NULL,
        `members_bitoptions` int(10) unsigned NOT NULL DEFAULT 0,
        `fb_uid` bigint(20) unsigned NOT NULL DEFAULT 0,
        `members_day_posts` varchar(32) NOT NULL DEFAULT '0,0',
        `live_id` varchar(32) DEFAULT NULL,
        `twitter_id` varchar(255) NOT NULL DEFAULT '',
        `twitter_token` varchar(255) NOT NULL DEFAULT '',
        `twitter_secret` varchar(255) NOT NULL DEFAULT '',
        `notification_cnt` mediumint(9) NOT NULL DEFAULT 0,
        `fb_token` text DEFAULT NULL,
        `ipsconnect_id` int(10) NOT NULL DEFAULT 0,
        `google_id` varchar(50) DEFAULT NULL,
        `linkedin_id` varchar(32) DEFAULT NULL,
        `pp_last_visitors` text DEFAULT NULL,
        `pp_main_photo` text DEFAULT NULL,
        `pp_main_width` int(5) DEFAULT NULL,
        `pp_main_height` int(5) DEFAULT NULL,
        `pp_thumb_photo` text DEFAULT NULL,
        `pp_thumb_width` int(5) DEFAULT NULL,
        `pp_thumb_height` int(5) DEFAULT NULL,
        `pp_setting_count_comments` int(2) DEFAULT NULL,
        `pp_reputation_points` int(10) DEFAULT NULL,
        `pp_photo_type` varchar(20) DEFAULT NULL,
        `signature` text DEFAULT NULL,
        `pconversation_filters` text DEFAULT NULL,
        `fb_photo` text DEFAULT NULL,
        `fb_photo_thumb` text DEFAULT NULL,
        `fb_bwoptions` int(10) DEFAULT NULL,
        `tc_last_sid_import` varchar(50) DEFAULT NULL,
        `tc_photo` text DEFAULT NULL,
        `tc_bwoptions` int(10) DEFAULT NULL,
        `pp_customization` mediumtext DEFAULT NULL,
        `timezone` varchar(64) DEFAULT NULL,
        `pp_cover_photo` varchar(255) NOT NULL DEFAULT '',
        `profilesync` text DEFAULT NULL,
        `profilesync_lastsync` int(10) NOT NULL DEFAULT 0 COMMENT 'Indicates the last time any profile sync service was ran',
        `google_token` text DEFAULT NULL,
        `linkedin_token` text DEFAULT NULL,
        `live_token` text DEFAULT NULL,
        `allow_admin_mails` bit(1) DEFAULT b'0',
        `members_bitoptions2` int(10) unsigned NOT NULL DEFAULT 0,
        `create_menu` text DEFAULT NULL COMMENT 'Cached contents of the "Create" drop down menu.',
        `ipsconnect_revalidate_url` text DEFAULT NULL,
        `members_disable_pm` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0 - not disabled, 1 - disabled, member can re-enable, 2 - disabled',
        `marked_site_read` int(10) unsigned DEFAULT 0,
        `pp_cover_offset` int(10) NOT NULL DEFAULT 0,
        `acp_skin` smallint(6) DEFAULT NULL,
        `acp_language` mediumint(9) DEFAULT NULL,
        `member_title` varchar(64) DEFAULT NULL,
        `member_posts` mediumint(7) NOT NULL DEFAULT 0,
        `member_last_post` int(10) DEFAULT NULL,
        `member_streams` text DEFAULT NULL,
        `photo_last_update` int(10) DEFAULT NULL,
        `steamid` varchar(17) DEFAULT NULL,
        `kuzi_song_path` varchar(255) DEFAULT '' COMMENT 'Profile song path.',
        `failed_mfa_attempts` smallint(3) unsigned DEFAULT 0 COMMENT 'Number of times tried and failed MFA',
        `unlucky_enable` int(1) DEFAULT 0,
        `unlucky_url` varchar(255) DEFAULT '',
        `mfa_details` text DEFAULT NULL,
        `permission_array` text DEFAULT NULL COMMENT 'A cache of the clubs and social groups that the member is in',
        `discord_id` varchar(20) DEFAULT NULL,
        `discord_name` varchar(50) DEFAULT NULL,
        `account_closed` tinyint(1) unsigned DEFAULT 0,
        `account_closed_reason` text DEFAULT NULL,
        `autoreplypm_on` tinyint(1) DEFAULT 0,
        `autoreplypm_text` text DEFAULT NULL,
        `nbcontentratings_positive` int(10) unsigned DEFAULT NULL,
        `nbcontentratings_negative` int(10) unsigned DEFAULT NULL,
        `nbcontentratings_neutral` int(10) unsigned DEFAULT NULL,
        `tm_member_tracked` tinyint(1) NOT NULL DEFAULT 0,
        `tm_member_tracked_deadline` int(10) NOT NULL DEFAULT 0,
        `tm_member_tracked_log_entries` int(10) NOT NULL DEFAULT 0,
        `tm_member_tracked_actions` text DEFAULT NULL,
        `completed` bit(1) NOT NULL DEFAULT b'0' COMMENT 'Whether the account is completed or not',
        `conv_password` varchar(255) DEFAULT NULL,
        `conv_password_extra` varchar(255) DEFAULT NULL,
        `membermap_location_synced` tinyint(1) DEFAULT 0,
        `cm_credits` text DEFAULT NULL,
        `cm_no_sev` tinyint(1) DEFAULT 0,
        `cm_return_group` smallint(3) DEFAULT 0,
        `idm_block_submissions` tinyint(1) unsigned DEFAULT 0 COMMENT 'Blocked from submitting Downloads files?',
        PRIMARY KEY (`member_id`),
        UNIQUE KEY `discord_id` (`discord_id`),
        KEY `bday_day` (`bday_day`),
        KEY `bday_month` (`bday_month`),
        KEY `members_bitoptions` (`members_bitoptions`),
        KEY `ip_address` (`ip_address`),
        KEY `failed_login_count` (`failed_login_count`),
        KEY `joined` (`joined`),
        KEY `fb_uid` (`fb_uid`),
        KEY `twitter_id` (`twitter_id`(191)),
        KEY `email` (`email`),
        KEY `member_groups` (`member_group_id`,`mgroup_others`(188)),
        KEY `google_id` (`google_id`),
        KEY `linkedin_id` (`linkedin_id`),
        KEY `mgroup` (`member_id`,`member_group_id`),
        KEY `allow_admin_mails` (`allow_admin_mails`),
        KEY `name_index` (`name`(191)),
        KEY `ipsconnect_id` (`ipsconnect_id`),
        KEY `mod_posts` (`mod_posts`),
        KEY `photo_last_update` (`photo_last_update`),
        KEY `steamid` (`steamid`),
        KEY `last_activity` (`last_activity`),
        KEY `completed` (`completed`,`temp_ban`),
        KEY `profilesync` (`profilesync_lastsync`,`profilesync`(150))
    );]]
    local q = db:query(e)
    q:start()
    local q = db:query("CREATE TABLE IF NOT EXISTS `chat_log` (`time` varchar(255) NOT NULL DEFAULT '', `steam_id` varchar(255) NOT NULL DEFAULT '', `message` varchar(255) NOT NULL DEFAULT '', `server` varchar(255) NOT NULL DEFAULT '')")
    q:start()
    print("You're gonna see some errors while it loads itself up, give it about 10 seconds then type mga reload!")
end

function _contracts()
    --[[local dev_server = GetHostName():lower():find("dev")
    if (dev_server) then return end]]
    local db = MINVENTORY_MYSQL
    
    lottery_stats = lottery_stats or {
        amount = 10000,
        players = 0,
        popular_num = 1,
        popular_ply = 0,
        loaded = false
    }

    function global_bounties_reward()
        for k, v in ipairs(player.GetAll()) do
            if not v.Bounties then continue end
            if v.Bounties.ID ~= MOAT_BOUNTIES.ActiveBounties.ID then continue end

            for i, o in pairs(v.Bounties) do
                if o.d then
                    MOAT_BOUNTIES:RewardPlayer(v, i)
                    v.Bounties[i].d = nil
                end
            end

            local s = db:escape(util.TableToJSON(v.Bounties))
            local q = db:query("INSERT INTO bounties_players (steamid, score) VALUES (" .. v:SteamID64() .. ", '" .. s .. "') ON DUPLICATE KEY UPDATE score='" .. s .. "';"):start()
        end
    end

    function global_bounties_refresh()
        local id = (MOAT_BOUNTIES.ActiveBounties or {
            ID = 0
        }).ID

        local bounties = {}
        local used = {}

        for i = 1, 4 do
            bounties[i] = MOAT_BOUNTIES:GetRandomBounty(1)
        end

        for i = 5, 8 do
            bounties[i] = MOAT_BOUNTIES:GetRandomBounty(2)
        end

        for i = 9, 12 do
            bounties[i] = MOAT_BOUNTIES:GetRandomBounty(3)
        end

        local q = db:query("INSERT INTO bounties_current (bounties) VALUES ('" .. db:escape(util.TableToJSON(bounties)) .. "');")
        q:start()
        local d = bounties

        -- PrintTable(d)
        for k, v in pairs(d) do
            d[k] = util.JSONToTable(v)
            d[k].bnty = MOAT_BOUNTIES.Bounties[d[k].id]
            d[k].bnty.id = d[k].id

            if (d[k].bnty.runfunc) then
                d[k].bnty.runfunc(d[k].mods, d[k].id, id + 1)
            end

            MsgC(Color(0, 255, 0), "Global Bounty with ID " .. d[k].id .. " " .. d[k].bnty.name .. " has refreshed.\n")
        end

        MOAT_BOUNTIES.ActiveBounties = table.Copy(d)
        MOAT_BOUNTIES.ActiveBounties.ID = id + 1
        MOAT_BOUNTIES.DiscordBounties()

        if player.GetCount() > 0 then
            net.Start("bounty.refresh")
            net.Broadcast()

            for _, ply in ipairs(player.GetAll()) do
                for k, v in pairs(MOAT_BOUNTIES.ActiveBounties) do
                    if not isnumber(k) then continue end
                    MOAT_BOUNTIES:SendBountyToPlayer(ply, v.bnty, v.mods, 0)
                end
            end
        end
    end

    function global_bounties_get()
        local q = db:query("SELECT * FROM bounties_current ORDER BY ID DESC LIMIT 1;")

        function q:onSuccess(d)
            if (d[1] == nil) then
                global_bounties_refresh()
            end

            local idd = d[1].ID
            d = util.JSONToTable(d[1].bounties)

            for k, v in pairs(d) do
                d[k] = util.JSONToTable(v)
                d[k].bnty = MOAT_BOUNTIES.Bounties[d[k].id]
                d[k].bnty.id = d[k].id

                if (d[k].bnty.runfunc) then
                    d[k].bnty.runfunc(d[k].mods, d[k].id, idd)
                end

                MsgC(Color(0, 255, 0), "Global Bounty with ID " .. d[k].id .. " " .. d[k].bnty.name .. " has Loaded.\n")
            end

            MOAT_BOUNTIES.ActiveBounties = table.Copy(d)
            MOAT_BOUNTIES.ActiveBounties.ID = idd
        end

        q:start()
    end

    function MOAT_BOUNTIES:IncreaseProgress(ply, bounty_id, max, idd)
        if player.GetCount() < 4 then return end
        if idd ~= MOAT_BOUNTIES.ActiveBounties.ID then return end -- old bounty from before the refresh
        if (not ply:IsValid()) then return end
        local tier = bounty_id
        local id = ply:SteamID64()
        if (GetGlobal("MOAT_MINIGAME_ACTIVE")) then return end
        if (not tier or not id) then return end
        if (not ply.Bounties) then return end

        if (ply.Bounties.ID or 0) ~= MOAT_BOUNTIES.ActiveBounties.ID then
            ply.Bounties = {
                ID = MOAT_BOUNTIES.ActiveBounties.ID
            }
            -- saved from last day of bounties
        end

        if not istable(ply.Bounties[tier]) then
            ply.Bounties[tier] = {0}
        end

        local cur_num = tonumber(ply.Bounties[tier][1])

        if (cur_num < max) then
            ply.Bounties[tier][1] = cur_num + 1
            net.Start("moat_bounty_update")
            net.WriteUInt(tier, 16)
            net.WriteUInt(cur_num + 1, 16)
            net.Send(ply)

            if (self.Bounties[bounty_id].name == "Marathon Walker") then
                MOAT_BOUNTIES:SendChat(1, "You have completed a round of the marathon walker bounty!", ply)
            end

            if (cur_num + 1 == max) then
                ply.Bounties[tier].d = true
            end
        end
    end

    function global_bounties_initplayerspawn(ply)
        local q = db:query("SELECT score FROM bounties_players WHERE steamid = '" .. ply:SteamID64() .. "';")

        function q:onSuccess(d)
            if #d > 0 then
                ply.Bounties = util.JSONToTable(d[1].score)
            else
                ply.Bounties = {
                    ID = MOAT_BOUNTIES.ActiveBounties.ID
                }
            end

            for k, v in pairs(MOAT_BOUNTIES.ActiveBounties) do
                if not isnumber(k) then continue end
                local cur_progress = 0

                if istable(ply.Bounties) then
                    if ply.Bounties[v.id] and ply.Bounties.ID == MOAT_BOUNTIES.ActiveBounties.ID then
                        cur_progress = ply.Bounties[v.id][1]
                    end
                end

                MOAT_BOUNTIES:SendBountyToPlayer(ply, v.bnty, v.mods, cur_progress)
            end
        end

        q:start()
    end

    function lottery_updateamount()
        local q = db:query("SELECT amount from moat_lottery;")

        function q:onSuccess(d)
            lottery_stats.loaded = true
            if not lottery_stats.amount or not d[1].amount then
                lottery_stats.amount = 10000
            else
                lottery_stats.amount = d[1].amount
            end
            net.Start("lottery.updateamount")
            net.WriteInt(d[1].amount, 32)
            net.Broadcast()
        end

        q:start()
    end

    lottery_updateamount()

    function lottery_updatepopular()
        local q = db:query("SELECT ticket, COUNT(*) AS num from moat_lottery_players GROUP BY ticket ORDER BY COUNT(*) DESC")

        function q:onSuccess(d)
            if #d < 1 then return end
            d = d[1]
            lottery_stats.loaded = true
            lottery_stats.popular_num = d.ticket
            lottery_stats.popular_ply = d.num
            net.Start("lottery.updatepopular")
            net.WriteInt(d.ticket, 32)
            net.WriteInt(d.num, 32)
            net.Broadcast()
        end

        q:start()
    end

    lottery_updatepopular()

    function lottery_updatetotal()
        local q = db:query("SELECT COUNT(*) AS num FROM moat_lottery_players;")

        function q:onSuccess(d)
            lottery_stats.loaded = true
            lottery_stats.players = d[1].num
            net.Start("lottery.updatetotal")
            net.WriteInt(d[1].num or 0, 32)
            net.Broadcast()
        end

        q:start()
    end

    lottery_updatetotal()

    function lottery_updatelast()
        local q = db:query("SELECT num FROM moat_lottery_last")

        function q:onSuccess(d)
            if not lottery_stats or not d[1] then
                lottery_stats.last_num = math.random(200)
                d[1].num = math.random(200)
            else
                lottery_stats.last_num = d[1].num
            end
            net.Start("lottery.last")
            net.WriteInt(d[1].num, 32)
            net.Broadcast()
        end

        q:start()
    end

    lottery_updatelast()

    function lottery_playerspawn(ply)
        local q = db:query("SELECT * FROM moat_lottery_players WHERE steamid = '" .. ply:SteamID64() .. "';")

        function q:onSuccess(d)
            net.Start("lottery.firstjoin")
            net.WriteTable(lottery_stats)
            net.WriteBool(#d > 0)

            if #d > 0 then
                net.WriteInt(d[1].ticket, 32)
            end

            net.Send(ply)

            if not lottery_stats.loaded then
                lottery_updatetotal()
                lottery_updateamount()
                lottery_updatepopular()
                lottery_updatelast()
            end
        end

        q:start()

        timer.Simple(30, function()
            if not IsValid(ply) then return end
            local q = db:query("SELECT * FROM moat_lottery_winners WHERE steamid = '" .. ply:SteamID64() .. "';")

            function q:onSuccess(d)
                if #d < 1 then return end
                if not IsValid(ply) then return end
                ply:m_GiveIC(d[1].amount)
                net.Start("lottery.Win")
                net.WriteInt(d[1].amount, 32)
                net.Send(ply)
                local q = db:query("DELETE FROM moat_lottery_winners WHERE steamid = '" .. ply:SteamID64() .. "';")
                q:start()
            end

            q:start()
        end)
    end

    net.Receive("lottery.Purchase", function(l, ply)
        if not ply:m_HasIC(1000) then return end
        local i = net.ReadInt(32)
        if i < 1 or i > 200 then return end
        ply:m_GiveIC(-1000)
        --print(ply)
        local q = db:query("UPDATE moat_lottery SET amount = amount + 1000;")
        q:start()
        local q = db:query("REPLACE INTO moat_lottery_players (steamid, name, ticket) VALUES ('" .. ply:SteamID64() .. "','" .. db:escape(ply:Nick()) .. "'," .. i .. ");")

        function q:onSuccess()
            net.Start("lottery.Purchase")
            net.WriteInt(i, 32)
            net.Send(ply)
            lottery_updatetotal()
            lottery_updateamount()
            lottery_updatepopular()
        end

        function q:onError(d)
            print(d)
        end

        q:start()
    end)

    local l_test = false

    function lottery_finish()
        for i = 1, 7 do
            math.random()
        end

        local winner = math.random(1, 200)
        local q = db:query("UPDATE moat_lottery_last SET num = '" .. winner .. "';")
        q:start()
        local c = db:query("SELECT amount from moat_lottery;")

        function c:onSuccess(amt)
            lottery_stats.amount = amt[1].amount
            local q = db:query("SELECT * FROM moat_lottery_players WHERE ticket = '" .. winner .. "';")

            function q:onSuccess(plys)
                if #plys < 1 then
                    if (not l_test) then
                        local c = db:query("UPDATE moat_lottery SET amount = '" .. lottery_stats.amount * 0.75 .. "'")
                        c:start()
                        local e = db:query("DELETE FROM moat_lottery_players;")

                        function e:onSuccess()
                            timer.Simple(5, function()
                                lottery_updatetotal()
                                lottery_updateamount()
                                lottery_updatepopular()
                                lottery_updatelast()
                                net.Start("lottery.Purchase")
                                net.WriteInt(-1, 32)
                                net.Broadcast()
                            end)
                        end

                        function e:onError(d)
                            print(d)
                        end

                        e:start()
                    end

                    local msg = markdown.WrapBoldLine(string(":tada: ", "The " .. markdown.BoldUnderline(string.Comma(lottery_stats.amount) .. " IC"), " Lottery for " .. markdown.Bold(util.NiceDate(-1)), " was unlucky number " .. markdown.Bold(winner) .. "!", markdown.NewLine(":see_no_evil: There was " .. markdown.Bold("no") .. " winner!"))) .. markdown.BoldEnd(string(":moneybag: ", markdown.BoldUnderline(string.Comma(lottery_stats.amount * 0.75) .. " IC"), " :money_with_wings:", " has rolled over to today's pot!"))
                    discord.Send("Lottery Announcement", msg)
                    discord.Send("Lottery", msg)

                    return
                end

                local each = math.floor((lottery_stats.amount * 0.9) / #plys)

                if #plys == 1 then
                    local nick = plys[1].name
                    local steamid = plys[1].steamid
                    local msg = markdown.WrapBoldLine(string(":tada: ", "The " .. markdown.BoldUnderline(string.Comma(each) .. " IC"), " Lottery for " .. markdown.Bold(util.NiceDate(-1)), " was lucky number " .. markdown.Bold(winner) .. "!", markdown.NewLine(":hear_no_evil: There was " .. markdown.Bold("ONE") .. " winner! :scream:"))) .. markdown.BoldEnd(string(":moneybag: ", "Congratulations to ", markdown.Bold(string.Extra(nick, util.SteamIDFrom64(steamid))), " for winning it all! :clap::clap:"))
                    discord.Send("Lottery Announcement", msg)
                    discord.Send("Lottery", msg)
                else
                    local ps, pc = "", #plys

                    for i = 1, pc do
                        local n = markdown.Bold(plys[i].name)
                        ps = ps .. Either(i == pc, "and " .. n, n .. ", ")
                    end

                    local str_rep = math.min(pc, 5)
                    local msg = markdown.WrapBoldLine(string(":tada: ", "The " .. markdown.BoldUnderline(string.Comma(lottery_stats.amount) .. " IC"), " Lottery for " .. markdown.Bold(util.NiceDate(-1)), " was lucky number " .. markdown.Bold(winner) .. "!", markdown.NewLine(":hear_no_evil: There were " .. markdown.Bold(pc) .. " winners" .. string.rep("!", str_rep) .. " :flushed:"))) .. markdown.BoldEnd(string(":moneybag: ", "Winning " .. markdown.BoldUnderline(string.Comma(each) .. " IC") .. " each, ", "congrats to " .. ps .. string.rep("!", str_rep) .. " ", string.rep(":clap:", math.min(pc, 5))))
                    discord.Send("Lottery Announcement", msg)
                    discord.Send("Lottery", msg)
                end

                --print("Each winner gets " .. each)

                for k, v in pairs(plys) do
                    if l_test then return end
                    local q = db:query("INSERT INTO moat_lottery_winners (steamid,amount) VALUES ('" .. v.steamid .. "'," .. each .. ");")

                    timer.Simple(k, function()
                        local msg = v.name .. " (" .. util.SteamIDFrom64(v.steamid) .. ") won **" .. string.Comma(each) .. " IC** in the lottery!"
                        discord.Send("Lottery Win", msg)
                    end)

                    if k == #plys then
                        function q:onSuccess()
                            local c = db:query("UPDATE moat_lottery SET amount = 5000;")
                            c:start()
                            local e = db:query("DELETE FROM moat_lottery_players;")

                            function e:onSuccess()
                                timer.Simple(5, function()
                                    lottery_updatetotal()
                                    lottery_updateamount()
                                    lottery_updatepopular()
                                    lottery_updatelast()
                                end)
                            end

                            function e:onError(d)
                                print(d)
                            end

                            e:start()
                        end
                    end

                    q:start()
                end
            end

            function q:onError(d)
                print(d)
            end

            q:start()
        end

        c:start()
    end

    function contract_getcurrent(fun)
        local q = db:query("SELECT * FROM moat_contracts_v2 WHERE `updating_server` is not null;")

        function q:onSuccess(d)
            fun(d[1])
        end

        function q:onError(err)
        end

        q:start()
    end

    local function get_contracts()
        print("Retrieving contracts")
        local q = db:query("SELECT TIMESTAMPDIFF(SECOND, start_time, CURRENT_TIMESTAMP) as diff_seconds, contract, ID FROM moat_contracts_v2 WHERE updating_server IS NOT NULL ORDER BY ID DESC;" .. "UPDATE moat_contracts_v2 SET updating_server = '" .. db:escape(game.GetIP()) .. "' WHERE updating_server IS NOT NULL;")

        function q:onSuccess(data)
            data = data[1]
            if (not data) then return timer.Simple(10, get_contracts) end
            local refresh_in = 60 * 60 * 24 - data.diff_seconds -- seconds
            print("needs refreshing in " .. refresh_in .. " seconds")

            timer.Create("moat_contract_refresh", refresh_in, 1, function()
                -- then return end
                print("Trying to refresh contract")
                local q = db:query("SELECT id, DAYOFWEEK(CURRENT_TIMESTAMP) as day_of_week, contract, contract_id from moat_contracts_v2 where updating_server = '" .. db:escape(game.GetIP()) .. "';" .. "UPDATE moat_contracts_v2 SET updating_server = null WHERE updating_server = '" .. db:escape(game.GetIP()) .. "';")

                function q:onSuccess(data)
                    print("Refreshing contract")
                    data = data[1]

                    if (not data) then
                        print("Cannot update, server does not own contract")

                        return
                    end

                    contract_transferall()
                    local next_contract_id = data.contract_id or 1 -- id for weapon contracts
                    local upnext = kill_contracts[1]

                    if (data.day_of_week ~= 1) then
                        next_contract_id = (next_contract_id % #wpn_contracts) + 1
                        upnext = wpn_contracts[next_contract_id]
                    end

                    local name, c = upnext[1], upnext[2]
                    local q = db:query("INSERT INTO moat_contracts_v2 (contract,start_time,`updating_server`,`contract_id`) VALUES ('" .. db:escape(name) .. "', CURRENT_TIMESTAMP, '" .. db:escape(game.GetIP()) .. "', " .. next_contract_id .. ");")

                    function q:onSuccess()
                        local q = db:query("SELECT ID FROM moat_contracts_v2 WHERE `updating_server` is not null;")

                        function q:onSuccess(b)
                            contract_id = b[1].ID
                        end

                        q:start()
                    end

                    q:start()
                    c.runfunc()
                    local s = markdown.WrapBoldLine("Daily Contract for " .. (util.NiceDate():Bold()))
                    s = s .. markdown.Block(name .. markdown.WrapLine(c.desc))
                    discord.Send("Contracts", s)
                    lottery_finish()
                    contract_loaded = name
                    global_bounties_refresh()
                end

                function q:onError(err)
                    print(err)
                    debug.Trace()
                end

                q:start()
            end)

            moat_contracts_v2[data.contract].runfunc()
            contract_starttime = os.time() - data.diff_seconds
            contract_loaded = data.contract
            contract_id = data.ID
            global_bounties_get()
        end

        function q:onError(err)
            print(err)
            debug.Trace()
        end

        q:start()
    end

    get_contracts()

    function contract_top(fun)
        local q = db:query("SELECT * FROM moat_contractplayers_v2 ORDER BY score DESC LIMIT 50")

        function q:onSuccess(d)
            fun(d)
        end

        q:start()
    end

    function contract_getply(ply, fun)
        local q = db:query("SELECT * FROM moat_contractplayers_v2 WHERE steamid = " .. ply:SteamID64() .. ";")

        function q:onSuccess(d)
            fun(d[1])
        end

        q:start()
    end

    function contract_getplace(ply, fun)
        local q = db:query("call selectContract('" .. ply:SteamID64() .. "');")

        function q:onSuccess(d)
            fun(d[1])
        end

        q:start()
    end

    function contract_transferall()
        contract_top(function(d)
            for k, v in pairs(d) do
                timer.Simple(0.1 * k, function()
                    local q = db:query("INSERT INTO moat_contractwinners_v2 (steamid, place) VALUES (" .. v.steamid .. "," .. k .. ");")

                    if k == #d then
                        function q:onSuccess()
                            local b = db:query("DROP TABLE moat_contractplayers_v2;")
                            b:start()
                        end
                    end

                    q:start()
                end)
            end
        end)
    end

    local vapes = {"Golden Vape", "White Vape", "Medicinal Vape", "Helium Vape", "Hallucinogenic Vape", "Butterfly Vape", "Custom Vape"}

    function reward_ply(ply, place)
        if place == 1 then
            ply:m_GiveIC(10000)
            give_ec(ply, 1)
            ply:m_DropInventoryItem(6)
            net.Start("moat.contracts.chat")
            net.WriteString("You got 1st place on the last contract and have received 8,000 IC and a random Ascended Item and an EVENT CREDIT!")
            net.Send(ply)
        elseif place < 6 then
            ply:m_GiveIC(math.Round((51 - place) * 200))
            ply:m_DropInventoryItem(6)
            net.Start("moat.contracts.chat")
            net.WriteString("You got place #" .. place .. " on the last contract and have received " .. string.Comma(math.Round((51 - place) * 200)) .. " IC and a Random Ascended Item!")
            net.Send(ply)
        elseif place < 11 then
            ply:m_GiveIC(math.Round((51 - place) * 200))
            ply:m_DropInventoryItem(5)
            net.Start("moat.contracts.chat")
            net.WriteString("You got place #" .. place .. " on the last contract and have received " .. string.Comma(math.Round((51 - place) * 200)) .. " IC and a Random High End Item!")
            net.Send(ply)
        elseif place < 51 then
            ply:m_GiveIC(math.Round((51 - place) * 200))
            net.Start("moat.contracts.chat")
            net.WriteString("You got place #" .. place .. " on the last contract and have received " .. string.Comma(math.Round((51 - place) * 200)) .. " IC!")
            net.Send(ply)
        end
    end

    function GetRandomSteamID()
        return "7656119" .. tostring(7960265728 + math.random(1, 200000000))
    end

    function contract_increase(ply, am)
        if not contract_loaded then return end
        if (GetGlobal("MOAT_MINIGAME_ACTIVE")) then return end
        if player.GetCount() < 8 then return end
        if (os.time() - contract_starttime) > 86400 then return end -- Contract already over, wait for next map 

        if (os.time() - contract_starttime) > 83000 then
            contract_getcurrent(function(c)
                if contract_id ~= tonumber(c.ID) then return end -- check if other servers already refresh contract
                local q = db:query("UPDATE moat_contractplayers_v2 SET score = score + " .. am .. " WHERE steamid = " .. ply:SteamID64() .. ";")
                q:start()
            end)
        else
            local q = db:query("UPDATE moat_contractplayers_v2 SET score = score + " .. am .. " WHERE steamid = " .. ply:SteamID64() .. ";")
            q:start()
        end
    end

    hook.Add("TTTBeginRound", "Contracts", function()
        timer.Create( "moat_giverewards", 5, 99, function() 
            global_bounties_reward()
        end )
    end)
    hook.Add("TTTEndRound", "Contracts", function()
        timer.Remove("moat_giverewards")
        timer.Simple(5, function()
            lottery_updatetotal()
            lottery_updateamount()
            lottery_updatepopular()
            

            contract_top(function(top)
                top_cache = top

                for _, ply in pairs(player.GetAll()) do
                    if (ply:IsBot()) then continue end

                    contract_getplace(ply, function(p)
                        net.Start("moat.contracts")
                        net.WriteBool(true)
                        net.WriteString(contract_loaded)
                        net.WriteString(moat_contracts_v2[contract_loaded].desc)
                        net.WriteString(moat_contracts_v2[contract_loaded].adj)
                        net.WriteString(moat_contracts_v2[contract_loaded].short)
                        net.WriteUInt(p.players, 16)
                        net.WriteUInt(p.position, 16)
                        net.WriteUInt(p.myscore, 16)
                        net.WriteBool(true)
                        net.WriteTable(top)
                        net.Send(ply)
                    end)
                end
            end)
        end)
    end)
end

function addcontract(name, contract, type)
    moat_contracts_v2[name] = contract

    if (type) then
        if (type == "wpn") then
            table.insert(wpn_contracts, {name, contract})
        elseif (type == "kill") then
            table.insert(kill_contracts, {name, contract})
        end
    end
end

local function WasRightfulKill(att, vic)
    if (GetRoundState() ~= ROUND_ACTIVE) then return false end
    if true then return hook.Run("TTTIsRightfulDamage", att, vic) end
    local vicrole = vic:GetRole()
    local attrole = att:GetRole()
    --if attrole == (ROLE_KILLER or false) then return true end
    --s
    if (vicrole == ROLE_TRAITOR and attrole == ROLE_TRAITOR) then return false end
    if ((vicrole == ROLE_DETECTIVE or vicrole == ROLE_INNOCENT) and attrole ~= ROLE_TRAITOR) then return false end

    return true
end

local weapon_challenges = {
    {
        {
            ["weapon_doubleb"] = true,
            ["weapon_flakgun"] = true,
            ["weapon_spas12pvp"] = true,
            ["weapon_supershotty"] = true,
            ["weapon_ttt_m1014"] = true,
            ["weapon_ttt_m590"] = true,
            ["weapon_ttt_shotgun"] = true,
            ["weapon_ttt_te_benelli"] = true,
            ["weapon_zm_shotgun"] = true,
            ["weapon_ttt_dual_shotgun"] = true,
        },
        "ANY Shotgun Weapon", "Shotgun"
    },
    {
        {
            ["weapon_zm_mac10"] = true,
            ["weapon_ttt_te_mac"] = true,
            ["weapon_ttt_mac11"] = true,
            ["weapon_ttt_dual_mac10"] = true
        },
        "the MAC10 or the MAC10 TE or the MAC11", "MAC10 + MAC11"
    },
    {
        {
            ["weapon_ttt_p90"] = true
        },
        "the FN P90", "FN P90"
    },
    {
        {
            ["weapon_ttt_aug"] = true
        },
        "the AUG", "AUG"
    },
    {
        {
            ["weapon_ttt_g11"] = true
        },
        "the G11", "G11"
    },
    {
        {
            ["weapon_ttt_asval"] = true
        },
        "the AS VAL", "AS VAL"
    },
    {
        {
            ["weapon_ttt_dp28"] = true
        },
        "the DP-28", "DP-28"
    },
    {
        {
            ["weapon_ttt_badger"] = true
        },
        "the Honey Badger", "Honey Badger"
    },
    {
        {
            ["weapon_ttt_ppsh"] = true
        },
        "the PPSH-41", "PPSH-41"
    },
    {
        {
            ["weapon_ttt_ak47"] = true,
            ["weapon_ttt_te_ak47"] = true
        },
        "the AK47 or the AK47 TE", "AK47"
    },
    {
        {
            ["weapon_ttt_mr96"] = true
        },
        "the Revolver", "Revolver"
    },
    {
        {
            ["weapon_zm_pistol"] = true
        },
        "the Pistol", "Pistol"
    },
    {
        {
            ["weapon_ttt_sg550"] = true,
            ["weapon_ttt_te_sg550"] = true,
            ["weapon_ttt_dual_sg550"] = true
        },
        "the SG550 or the SG550 TE", "SG550"
    },
    {
        {
            ["weapon_ttt_m16"] = true,
            ["weapon_ttt_te_m4a1"] = true,
            ["weapon_ttt_te_m14"] = true,
            ["weapon_ttt_dual_m16"] = true
        },
        "the M16 or the M4A1 or the M14", "M16 + M4A1 + M14"
    },
    {
        {
            ["weapon_zm_sledge"] = true,
            ["weapon_ttt_dual_huge"] = true
        },
        "the H.U.G.E-249", "H.U.G.E-249"
    },
    {
        {
            ["weapon_ttt_dual_elites"] = true
        },
        "the Dual Elites", "Dual Elites"
    },
    {
        {
            ["weapon_zm_revolver"] = true,
            ["weapon_ttt_te_deagle"] = true,
            ["weapon_ttt_golden_deagle"] = true
        },
        "the Deagle or the Deagle TE", "Deagle"
    },
    {
        {
            ["weapon_ttt_ump45"] = true,
            ["weapon_ttt_dual_ump"] = true
        },
        "the UMP-45", "UMP-45"
    },
    {
        {
            ["weapon_ttt_msbs"] = true
        },
        "the MSBS", "MSBS"
    },
    {
        {
            ["weapon_doubleb"] = true,
            ["weapon_flakgun"] = true,
            ["weapon_spas12pvp"] = true,
            ["weapon_supershotty"] = true,
            ["weapon_ttt_m1014"] = true,
            ["weapon_ttt_m590"] = true,
            ["weapon_ttt_shotgun"] = true,
            ["weapon_ttt_te_benelli"] = true,
            ["weapon_zm_shotgun"] = true,
            ["weapon_ttt_dual_shotgun"] = true
        },
        "ANY Shotty Weapon", "Shotty"
    },
    {
        {
            ["weapon_xm8b"] = true
        },
        "the M8A1", "M8A1"
    },
    {
        {
            ["weapon_zm_rifle"] = true,
            ["weapon_ttt_te_m24"] = true
        },
        "the Rifle or the M24", "Rifle + M24"
    },
    {
        {
            ["weapon_ttt_galil"] = true,
            ["weapon_ttt_te_sako"] = true
        },
        "the Galil or the Sako", "Galil + Sako"
    },
    {
        {
            ["weapon_ttt_sg552"] = true,
            ["weapon_ttt_te_sr25"] = true
        },
        "the SG552 or the SR-25", "SG552 + SR-25"
    },
    {
        {
            ["weapon_doubleb"] = true,
            ["weapon_flakgun"] = true,
            ["weapon_spas12pvp"] = true,
            ["weapon_supershotty"] = true,
            ["weapon_ttt_m1014"] = true,
            ["weapon_ttt_m590"] = true,
            ["weapon_ttt_shotgun"] = true,
            ["weapon_ttt_te_benelli"] = true,
            ["weapon_zm_shotgun"] = true,
            ["weapon_ttt_dual_shotgun"] = true
        },
        "ANY Buckshot Weapon", "Buckshot"
    },
    {
        {
            ["weapon_flakgun"] = true
        },
        "the Flak-28", "Flak-28"
    },
    {
        {
            ["weapon_thompson"] = true
        },
        "the Tommy Gun", "Tommy Gun"
    },
    {
        {
            ["weapon_ttt_famas"] = true,
            ["weapon_ttt_te_famas"] = true
        },
        "the Famas or the Famas TE", "Famas"
    },
    {
        {
            ["weapon_ttt_glock"] = true,
            ["weapon_ttt_te_glock"] = true,
            ["weapon_ttt_dual_glock"] = true
        },
        "the Glock or the Glock TE", "Glock"
    },
    {
        {
            ["weapon_ttt_mp5"] = true,
            ["weapon_ttt_te_mp5"] = true
        },
        "the MP5 or the MP5 TE", "MP5"
    }
}

--{{["weapon_ttt_peacekeeper"] = true, ["weapon_ttt_an94"] = true}, "the Peacekeeper", "Peacekeeper"}
local chal_prefix = {"Dangerous", "Alarming", "Hazardous", "Troubling", "Deadly", "Fatal", "Nasty", "Risky", "Serious", "Terrible", "Threatening", "Ugly", "Cruel", "Evil", "Atrocious", "Vicious", "Pitiless", "Brutal", "Harsh", "Hateful", "Heartless", "Merciless", "Wicked", "Ferocious", "Spiteful"}

local chal_suffix = {"Killer", "Assassin", "Hunter", "Exterminator", "Slayer", "Criminal", "Murderer"}

for k, v in pairs(weapon_challenges) do
    addcontract("Global " .. v[3] .. " Killer", {
        desc = 'Get as many kills as you can with ' .. v[2] .. ', rightfully.',
        adj = "Kills",
        short = v[3],
        runfunc = function()
            --print("global", v[3], "killer")

            hook.Add("PlayerDeath", "RightfulContract" .. k, function(ply, inf, att)
                if not IsValid(att) then return end
                if not att:IsPlayer() then return end
                local inf = att:GetActiveWeapon()
                if not IsValid(inf) then return end

                if (att:IsValid() and att:IsPlayer() and ply ~= att and WasRightfulKill(att, ply)) and inf.ClassName and v[1][inf.ClassName] then
                    contract_increase(att, 1)
                end
            end)
        end
    }, "wpn")
end

addcontract("Rightful Slayer", {
    desc = "Eliminate as many terrorists as you can, rightfully.",
    adj = "Kills",
    short = "Kills",
    runfunc = function()
        hook.Add("PlayerDeath", "RightfulContract", function(ply, inf, att)
            if not IsValid(att) then return end
            if not att:IsPlayer() then return end
            local inf = att:GetActiveWeapon()
            if not IsValid(inf) then return end

            if (att:IsValid() and att:IsPlayer() and ply ~= att and WasRightfulKill(att, ply)) then
                contract_increase(att, 1)
            end
        end)
    end
}, "kill")

addcontract("Crouching Hunters", {
    desc = "Kill as many terrorists as you can rightfully while YOU are crouching.",
    adj = "Kills",
    short = "Crouching",
    runfunc = function()
        hook.Add("PlayerDeath", "RightfulContract", function(ply, inf, att)
            if not IsValid(att) then return end
            if not att:IsPlayer() then return end
            local inf = att:GetActiveWeapon()
            if not IsValid(inf) then return end
            if (not att:Crouching()) then return end

            if (att:IsValid() and att:IsPlayer() and ply ~= att and WasRightfulKill(att, ply)) then
                contract_increase(att, 1)
            end
        end)
    end
}, "kill")

addcontract("Melee Hunter", {
    desc = "Rightfully kill as many terrorists as you can with a melee weapon.",
    adj = "Kills",
    short = "Melees",
    runfunc = function()
        hook.Add("PlayerDeath", "RightfulContract", function(ply, inf, att)
            if not IsValid(att) then return end
            if not att:IsPlayer() then return end
            local inf = att:GetActiveWeapon()
            if not IsValid(inf) then return end

            --print("C12367")
            --  print(inf,inf.Weapon.Kind,inf.Weapon.Kind == WEAPON_MELEE,att:IsPlayer(),inf:IsWeapon(),WasRightfulKill(att, ply))
            if (att:IsValid() and att:IsPlayer() and ply ~= att and IsValid(inf) and inf:IsWeapon() and inf.Weapon.Kind and inf.Weapon.Kind == WEAPON_MELEE and WasRightfulKill(att, ply)) then
                --print("Cotnract increase")
                contract_increase(att, 1)
            end
        end)
    end
})

addcontract("Secondary Hunter", {
    desc = "Rightfully kill as many terrorists as you can with a secondary.",
    adj = "Kills",
    short = "Secondaries",
    runfunc = function()
        hook.Add("PlayerDeath", "RightfulContract", function(ply, inf, att)
            if not IsValid(att) then return end
            if not att:IsPlayer() then return end
            local inf = att:GetActiveWeapon()
            if not IsValid(inf) then return end

            if (att:IsValid() and att:IsPlayer() and ply ~= att and IsValid(inf) and inf:IsWeapon() and inf.Weapon.Kind and inf.Weapon.Kind == WEAPON_PISTOL and WasRightfulKill(att, ply)) then
                contract_increase(att, 1)
            end
        end)
    end
}, "kill")

local weapon_challenges2 = {
    {
        {
            ["weapon_ttt_peacekeeper"] = true,
            ["weapon_ttt_an94"] = true
        },
        "the Peacekeeper", "Peacekeeper"
    },
    {
        {
            ["weapon_ttt_te_g36c"] = true
        },
        "the G36C", "G36C"
    }
}

for k, v in pairs(weapon_challenges2) do
    addcontract("Global " .. v[3] .. " Killer", {
        desc = 'Get as many kills as you can with "' .. v[2] .. '", rightfully.',
        adj = "Kills",
        short = v[3],
        runfunc = function()
            hook.Add("PlayerDeath", "RightfulContract" .. k, function(ply, inf, att)
                if not IsValid(att) then return end
                if not att:IsPlayer() then return end
                local inf = att:GetActiveWeapon()
                if not IsValid(inf) then return end

                if (att:IsValid() and att:IsPlayer() and ply ~= att and WasRightfulKill(att, ply)) and inf.ClassName and v[1][inf.ClassName] then
                    contract_increase(att, 1)
                end
            end)
        end
    }, "wpn")
end

if MINVENTORY_MYSQL then
    if c() then
        _contracts()
    end
end

hook.Add("InitPostEntity", "Contracts", function()
    if not c() then
        timer.Create("CheckContracts", 1, 0, function()
            if c() then
                _contracts()
                timer.Remove("CheckContracts")
            end
        end)
    else
        _contracts()
    end
end)

local bounty_id = 1

function MOAT_BOUNTIES:AddBounty(name_, tbl)
    local bounty = {
        name = name_,
        tier = tbl.tier,
        desc = tbl.desc,
        vars = tbl.vars,
        runfunc = tbl.runfunc,
        rewards = tbl.rewards,
        rewardtbl = tbl.rewardtbl,
    }

    self.Bounties[bounty_id] = bounty
    bounty_id = bounty_id + 1
end

function MOAT_BOUNTIES.Rewards(a, b)
    local d = os.date("!*t", (os.time() - 21600 - 3600))

    return (d.yday == 43 and d.year == 2019) and b or a
end

local chances = MOAT_BOUNTIES.Rewards({
    [1] = 5,
    [2] = 2,
    [3] = 1
}, {
    [1] = 50,
    [2] = 25,
    [3] = 10
})

function MOAT_BOUNTIES:HighEndChance(tier)
    local c = chances[tier]
    if (not c) then return false end
    local num = math.random(1, c)
    if (num == c) then return true end

    return false
end

bounty_rewarded_players = bounty_rewarded_players or {}

function MOAT_BOUNTIES:RewardPlayer(ply, bounty_id)
    if (not ply:IsValid()) then return end

    if (not bounty_rewarded_players[ply]) then
        bounty_rewarded_players[ply] = {}
    elseif (bounty_rewarded_players[ply] and bounty_rewarded_players[ply][bounty_id]) then
        return
    end

    bounty_rewarded_players[ply][bounty_id] = true
    local rewards = self.Bounties[bounty_id].rewardtbl

    if (rewards.ic) then
        ply:m_GiveIC(rewards.ic)
    end

    if (rewards.exp) then
        ply:ApplyXP(rewards.exp * XP_MULTIPLIER)
    end

    local t = self.Bounties[bounty_id].tier

    -- moat_DropHoliday(ply, 1)
    if (t and self:HighEndChance(t)) then
        local rarity = 5

        if (t > 1) then
            rarity = MOAT_BOUNTIES.Rewards(5, t == 2 and 6 or 7)
        end

        ply:m_DropInventoryItem(rarity)
    end

    local mutator = {"High-End Stat Mutator", "High-End Talent Mutator"}

    mutator = mutator[math.random(2)]
    rewards.drop = MOAT_BOUNTIES.Rewards(false, mutator)

    if (rewards.drop) then
        if (istable(rewards.drop)) then
            ply:m_DropInventoryItem(table.Random(rewards.drop))
        else
            ply:m_DropInventoryItem(rewards.drop)
        end
    end

    local level = self.Bounties[bounty_id].tier
    self:SendChat(level, "You have completed the " .. self.Bounties[bounty_id].name .. " Bounty and have been rewarded " .. self.Bounties[bounty_id].rewards .. ".", ply)
end

local tier1_rewards = MOAT_BOUNTIES.Rewards({
    ic = 2500,
    exp = 1500
}, {
    exp = 5000
})

local tier1_rewards_str = MOAT_BOUNTIES.Rewards("2,500 Inventory Credits + 1,500 Player Experience + 1 in 5 Chance for High-End", "Any Random Mutator + 5,000 Player Experience + 1 in 25 Chance for Ascended") -- "2,500 Inventory Credits + 1,500 Player Experience + 1 in 5 Chance for High-End",

local tier2_rewards = MOAT_BOUNTIES.Rewards({
    ic = 5000,
    exp = 2500
}, {
    exp = 11000
})

local tier2_rewards_str = MOAT_BOUNTIES.Rewards("5,000 Inventory Credits + 2,500 Player Experience + 1 in 2 Chance for High-End", "Any Random Mutator + 11,000 Player Experience + 1 in 15 Chance for Ascended+") -- "5,000 Inventory Credits + 2,500 Player Experience + 1 in 2 Chance for High-End",

local tier3_rewards = MOAT_BOUNTIES.Rewards({
    ic = 7500,
    exp = 4000
}, {
    exp = 17000
})

local tier3_rewards_str = MOAT_BOUNTIES.Rewards("7,500 Inventory Credits + 4,000 Player Experience + 1 High-End item", "Any Random Mutator + 17,000 Player Experience + 1 in 10 for Cosmic+") -- "7,500 Inventory Credits + 4,000 Player Experience + 1 High-End item",

--[[-------------------------------------------------------------------------
TIER 1 BOUNTIES
---------------------------------------------------------------------------]]
for i = 1, #weapon_challenges do
    local wpntbl = weapon_challenges[i]

    MOAT_BOUNTIES:AddBounty((chal_prefix[i] or "Dangerous") .. " " .. wpntbl[3] .. " " .. (chal_suffix[i] or "Slayer"), {
        roles = "innocent traitor detective",
        tier = 3,
        desc = "Eliminate # terrorists, rightfully, with " .. wpntbl[2] .. ". Can be completed as any role.",
        vars = {math.random(35, 65)},
        runfunc = function(mods, bountyid, idd)
            hook.Add("PlayerDeath", "moat_weapon_challenges_1_" .. wpntbl[3], function(ply, inf, att)
                if (IsValid(att) and att:IsPlayer() and ply ~= att) then
                    inf = att:GetActiveWeapon()

                    if (IsValid(inf) and inf.ClassName and wpntbl[1][inf.ClassName] and WasRightfulKill(att, ply)) then
                        MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                    end
                end
            end)
        end,
        rewards = tier3_rewards_str,
        rewardtbl = tier3_rewards
    })
end

--v
MOAT_BOUNTIES:AddBounty("Detective Hunter", {
    roles = "traitor",
    tier = 1,
    desc = "Eliminate a total of # detectives. Can be completed as a traitor only.",
    vars = {math.random(5, 15)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_death_dethunt", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and att:GetRole() == ROLE_TRAITOR and GetRoundState() == ROUND_ACTIVE and ply:GetRole() == ROLE_DETECTIVE) then
                MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier1_rewards_str,
    rewardtbl = tier1_rewards
})

--v
MOAT_BOUNTIES:AddBounty("One Tapper", {
    roles = "innocent traitor detective",
    tier = 1,
    desc = "Eliminate # terrorists rightfully, only with one shot kills. Can be completed as any role.",
    vars = {math.random(6, 15)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("EntityTakeDamage", "moat_track_1tap", function(ply, dmginfo)
            if (MOAT_ACTIVE_BOSS) then return end
            local att = dmginfo:GetAttacker()
            if (not IsValid(ply) or not ply:IsPlayer()) then return end
            if (not IsValid(att) or not att:IsPlayer()) then return end
            if (ply:Health() < ply:GetMaxHealth()) then return end
            if (dmginfo:GetDamage() < ply:Health()) then return end
            if (not WasRightfulKill(att, ply)) then return end
            MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
        end)
    end,
    rewards = tier1_rewards_str,
    rewardtbl = tier1_rewards
})

--v
MOAT_BOUNTIES:AddBounty("Marathon Walker", {
    roles = "innocent traitor detective",
    tier = 1,
    desc = "In # different rounds, take # steps each round. (doesn't have to be in a row)",
    vars = {math.random(5, 8), math.random(250, 350)},
    -- Should probably be higher idk
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTBeginRound", "moat_reset_steps", function()
            for k, v in pairs(player.GetAll()) do
                v.cSteps = 0
            end
        end)

        hook.Add("PlayerFootstep", "moat_step_tracker", function(ply)
            if (GetRoundState() ~= ROUND_ACTIVE) then return end
            if (ply:Team() == TEAM_SPEC) then return end
            ply.cSteps = (ply.cSteps or 0) + 1

            if (ply.cSteps == mods[2]) then
                MOAT_BOUNTIES:IncreaseProgress(ply, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier1_rewards_str,
    rewardtbl = tier1_rewards
})

MOAT_BOUNTIES:AddBounty("Close Quarters Combat", {
    roles = "innocent traitor detective",
    tier = 1,
    desc = "Eliminate # terrorists, rightfully, while being close to your target. Can be completed as any role.",
    vars = {math.random(8, 20)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_close_quaters_combat", function(ply, inf, att)
            local vic_pos = ply:GetPos()

            if (IsValid(att) and att:IsPlayer() and ply ~= att and vic_pos:Distance(att:GetPos()) < 500 and WasRightfulKill(att, ply)) then
                MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier1_rewards_str,
    rewardtbl = tier1_rewards
})

MOAT_BOUNTIES:AddBounty("Longshot Killer", {
    roles = "innocent traitor detective",
    tier = 1,
    desc = "Eliminate # terrorists, rightfully, while being far away from your target. Can be completed as any role.",
    vars = {math.random(6, 14)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_longshot_killer", function(ply, inf, att)
            local vic_pos = ply:GetPos()

            if (IsValid(att) and att:IsPlayer() and ply ~= att and vic_pos:Distance(att:GetPos()) > 1000 and WasRightfulKill(att, ply)) then
                MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier1_rewards_str,
    rewardtbl = tier1_rewards
})

MOAT_BOUNTIES:AddBounty("Headshot Expert", {
    roles = "innocent traitor detective",
    tier = 1,
    desc = "Eliminate # terrorists, rightfully, with a headshot as the cause of death. Can be completed as any role.",
    vars = {math.random(7, 17)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("ScalePlayerDamage", "moat_headshot_expert_scale", function(ply, hitgroup, dmginfo)
            local att = dmginfo:GetAttacker()

            if (hitgroup == HITGROUP_HEAD) then
                att.lasthead = ply
            elseif (att.lasthead == ply) then
                att.lasthead = att
            end
        end)

        hook.Add("PlayerDeath", "moat_headshot_expert", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and (att.lasthead and att.lasthead == ply)) then
                inf = att:GetActiveWeapon()

                if (IsValid(inf) and inf:IsWeapon() and WasRightfulKill(att, ply)) then
                    MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                end
            end
        end)
    end,
    rewards = tier1_rewards_str,
    rewardtbl = tier1_rewards
})

--[[-------------------------------------------------------------------------
TIER 2 BOUNTIES
---------------------------------------------------------------------------]]
MOAT_BOUNTIES:AddBounty("Demolition Expert", {
    roles = "innocent traitor detective",
    tier = 2,
    desc = "Eliminate # terrorists, rightfully, with an explosion as the cause of death. Can be completed as any role.",
    vars = {math.random(9, 15)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("DoPlayerDeath", "moat_demo_expert", function(ply, att, dmg)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and dmg:IsExplosionDamage() and WasRightfulKill(att, ply)) then
                MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})

MOAT_BOUNTIES:AddBounty("Anti-Traitor Force", {
    roles = "innocent detective",
    tier = 2,
    desc = "In # round, eliminate # traitors, rightfully. Can be completed as any role.",
    vars = {1, math.random(2, 3)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTBeginRound", "moat_reset_antitraitor_force", function()
            for k, v in pairs(player.GetAll()) do
                v.antitforce = 0
            end
        end)

        hook.Add("PlayerDeath", "moat_antitraitor_force_death", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and GetRoundState() == ROUND_ACTIVE and ply:GetRole() == ROLE_TRAITOR and (att:GetRole() == ROLE_INNOCENT or att:GetRole() == ROLE_DETECTIVE)) then
                att.antitforce = (att.antitforce or 0) + 1

                if (att.antitforce == mods[2]) then
                    MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                end
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})

MOAT_BOUNTIES:AddBounty("Knife Addicted", {
    roles = "traitor",
    tier = 2,
    desc = "Eliminate # terrorists, rightfully, with a knife. Can be completed as a traitor only.",
    vars = {math.random(4, 7)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_knife_addicted", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att) then
                if (inf and inf:IsPlayer()) then
                    inf = att:GetActiveWeapon()
                end

                if (IsValid(inf) and inf.ClassName and (inf.ClassName == "weapon_ttt_knife" or inf.ClassName == "ttt_knife_proj") and WasRightfulKill(att, ply)) then
                    MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                end
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})

MOAT_BOUNTIES:AddBounty("DNA Addicted", {
    roles = "innocent traitor detective",
    tier = 2,
    desc = "Use the DNA tool to locate # traitors. Can be completed as a any role.",
    vars = {math.random(7, 12)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTBeginRound", "moat_reset_dna", function()
            for k, v in pairs(player.GetAll()) do
                v.dnatbl = {}
            end
        end)

        hook.Add("TTTFoundDNA", "moat_dna_addicted", function(ply, dna_owner, ent)
            if (not ply.dnatbl) then
                ply.dnatbl = {}
            end

            if (IsValid(ply) and GetRoundState() == ROUND_ACTIVE and IsValid(dna_owner) and dna_owner:GetRole() == ROLE_TRAITOR and not table.HasValue(ply.dnatbl, ent)) then
                table.insert(ply.dnatbl, ent)
                MOAT_BOUNTIES:IncreaseProgress(ply, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})

MOAT_BOUNTIES:AddBounty("Body Searcher", {
    roles = "innocent traitor detective",
    tier = 2,
    desc = "Identify # unidentified dead bodies. Can be completed as any role.",
    vars = {math.random(10, 25)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTBodyFound", "moat_body_searcher", function(ply, dead, rag)
            if (IsValid(ply) and GetRoundState() == ROUND_ACTIVE) then
                MOAT_BOUNTIES:IncreaseProgress(ply, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})

MOAT_BOUNTIES:AddBounty("Doctor Detective", {
    roles = "detective",
    tier = 2,
    desc = "Place down at least # health stations. Can be completed as a detective only.",
    vars = {math.random(2, 4), math.random(100, 200)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTPlacedHealthStation", "Doctor Detective", function(ply)
            if (IsValid(ply) and GetRoundState() == ROUND_ACTIVE and ply:GetRole() == ROLE_DETECTIVE) then
                MOAT_BOUNTIES:IncreaseProgress(ply, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})

MOAT_BOUNTIES:AddBounty("Equipment User", {
    roles = "traitor detective",
    tier = 2,
    desc = "Order # equipment items total. Can be completed as a traitor or detective only.",
    vars = {math.random(25, 45)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTOrderedEquipment", "moat_order_equip", function(ply, equipment, is_item)
            if (IsValid(ply) and GetRoundState() == ROUND_ACTIVE and (ply:GetRole() == ROLE_TRAITOR or ply:GetRole() == ROLE_DETECTIVE)) then
                MOAT_BOUNTIES:IncreaseProgress(ply, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})

MOAT_BOUNTIES:AddBounty("Traitor Assassin", {
    roles = "innocent detective",
    tier = 2,
    desc = "Eliminate # traitors, rightfully. Can be completed as an innocent or detective only.",
    vars = {math.random(10, 20)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_traitor_assassin", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and ply:GetRole() == ROLE_TRAITOR and WasRightfulKill(att, ply)) then
                MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})

--[[
MOAT_BOUNTIES:AddBounty("No Equipments Allowed", {
    tier = 2,
    desc = "Win # rounds as a traitor or detective without purchasing a single equipment item.",
    vars = {math.random(4, 9)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTEndRound", "moat_no_equipments_allowed_end", function(res)
            for k, v in pairs(player.GetAll()) do
                if (res == WIN_TRAITOR and v:GetRole() == ROLE_TRAITOR and v.noequipments) then
                    MOAT_BOUNTIES:IncreaseProgress(v, bountyid, mods[1], idd)
                elseif ((res == WIN_INNOCENT or res == WIN_TIMELIMIT) and v:GetRole() == ROLE_DETECTIVE and v.noequipments) then
                    MOAT_BOUNTIES:IncreaseProgress(v, bountyid, mods[1], idd)
                end
            end
        end)

        hook.Add("TTTBeginRound", "moat_no_equipments_allowed_begin", function()
            for k, v in pairs(player.GetAll()) do
                v.noequipments = true
            end
        end)

        hook.Add("TTTOrderedEquipment", "moat_no_equipments_allowed_equip", function(ply, equipment, is_item)
            if (IsValid(ply) and GetRoundState() == ROUND_ACTIVE and (ply:GetRole() == ROLE_TRAITOR or ply:GetRole() == ROLE_DETECTIVE)) then
                ply.noequipments = false
            end
        end)
    end,
    rewards = tier2_rewards_str,
    rewardtbl = tier2_rewards
})
]]
--[[-------------------------------------------------------------------------
TIER 3 BOUNTIES
---------------------------------------------------------------------------]]
--v
MOAT_BOUNTIES:AddBounty("Quickswitching killer", {
    roles = "innocent traitor detective",
    tier = 3,
    desc = "In # round, get # rightful kills with # different guns.",
    vars = {1, math.random(5, 10), math.random(3, 5)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTBeginRound", "QuickSwitch_", function()
            for k, v in pairs(player.GetAll()) do
                v.QuickSwitch_ = {}
                v.Quick_Kills = 0
            end
        end)

        hook.Add("PlayerDeath", "moat_quickswitch_killer", function(ply, inf, att)
            if (not att.QuickSwitch_) then return end -- Before round started

            if (IsValid(att) and att:IsPlayer() and ply ~= att and WasRightfulKill(att, ply)) then
                if (#att.QuickSwitch_ >= mods[3]) then
                    if (table.HasValue(att.QuickSwitch_, att:GetActiveWeapon())) then
                        att.Quick_Kills = att.Quick_Kills + 1
                    end
                else
                    table.insert(att.QuickSwitch_, att:GetActiveWeapon())
                    att.Quick_Kills = att.Quick_Kills + 1
                end

                if (att.Quick_Kills >= mods[2] and #att.QuickSwitch_ >= mods[3]) then
                    MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                end
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})

MOAT_BOUNTIES:AddBounty("Professional Traitor", {
    roles = "traitor",
    tier = 3,
    desc = "In # round, eliminate a total of # innocents brutally. Can be completed as a traitor only.",
    vars = {1, math.random(8, 11)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTBeginRound", "moat_reset_blood_traitor", function()
            for k, v in pairs(player.GetAll()) do
                v.proftraitor = 0
            end
        end)

        hook.Add("PlayerDeath", "moat_death_prof_traitor", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and att:GetRole() == ROLE_TRAITOR and WasRightfulKill(att, ply)) then
                att.proftraitor = (att.proftraitor or 0) + 1

                if (att.proftraitor == mods[2]) then
                    MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                end
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})

MOAT_BOUNTIES:AddBounty("Bloodthirsty Traitor", {
    roles = "traitor",
    tier = 3,
    desc = "Eliminate at least 5 innocents in one round, # times. Can be completed as a traitor only.",
    vars = {math.random(7, 14)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTBeginRound", "moat_reset_blood_traitor", function()
            for k, v in pairs(player.GetAll()) do
                v.bloodtraitor = 0
            end
        end)

        hook.Add("PlayerDeath", "moat_death_blood_traitor", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and att:GetRole() == ROLE_TRAITOR and WasRightfulKill(att, ply)) then
                att.bloodtraitor = (att.bloodtraitor or 0) + 1

                if (att.bloodtraitor == 5) then
                    MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                end
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})

MOAT_BOUNTIES:AddBounty("Melee Maniac", {
    roles = "innocent traitor detective",
    tier = 3,
    desc = "Eliminate # terrorists, rightfully, with a melee weapon as the cause of death. Can be completed as any role.",
    vars = {math.random(5, 10)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_melee_addicted", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att) then
                inf = att:GetActiveWeapon()

                if (IsValid(inf) and inf:IsWeapon() and inf.Weapon.Kind and inf.Weapon.Kind == WEAPON_MELEE and WasRightfulKill(att, ply)) then
                    MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                end
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})

MOAT_BOUNTIES:AddBounty("Double Killer", {
    roles = "innocent traitor detective",
    tier = 3,
    desc = "Eliminate an innocent back to back with another kill # times. Can be completed as a traitor only with guns.",
    vars = {math.random(15, 25)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_double_killer", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att) then
                inf = att:GetActiveWeapon()

                if (IsValid(inf) and inf:IsWeapon() and att:GetRole() == ROLE_TRAITOR and WasRightfulKill(att, ply)) then
                    local not_applied_progress = true

                    if (att.lastkilltime and ((CurTime() - 5) < att.lastkilltime)) then
                        MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                        att.lastkilltime = 0
                        not_applied_progress = false
                    end

                    if (not_applied_progress) then
                        att.lastkilltime = CurTime()
                    end
                end
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})

MOAT_BOUNTIES:AddBounty("Airborn Assassin", {
    roles = "innocent traitor detective",
    tier = 3,
    desc = "Eliminate # terrorists with a gun, rightfully, while airborn. Can be completed as any role.",
    vars = {math.random(20, 35)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_airborn_assassin", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and not att:IsOnGround() and att:WaterLevel() == 0) then
                inf = att:GetActiveWeapon()

                if (IsValid(inf) and inf:IsWeapon() and WasRightfulKill(att, ply)) then
                    MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                end
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})

--[[
MOAT_BOUNTIES:AddBounty("The A Team", {
    tier = 3,
    desc = "Win # rounds as a traitor with none of your traitor buddies dying. Can be completed as a traitor only.",
    vars = {math.random(3, 5)},
    runfunc = function(mods, bountyid, idd)
        local traitor_died = false

        hook.Add("TTTEndRound", "moat_a_team_end", function(res)
            for k, v in pairs(player.GetAll()) do
                if (res == WIN_TRAITOR and v:GetRole() == ROLE_TRAITOR and not traitor_died) then
                    MOAT_BOUNTIES:IncreaseProgress(v, bountyid, mods[1], idd)
                end
            end
        end)

        hook.Add("TTTBeginRound", "moat_a_team_begin", function(res)
            traitor_died = false
        end)

        hook.Add("PlayerDeath", "moat_a_team_death", function(ply, inf, att)
            if (ply:GetRole() == ROLE_TRAITOR) then
                traitor_died = true
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})
]]
--[[-------------------------------------------------------------------------
BOUNTY UPDATE
---------------------------------------------------------------------------]]
MOAT_BOUNTIES:AddBounty("Innocent Exterminator", {
    roles = "traitor",
    tier = 1,
    desc = "Exterminate # total innocents with any weapon. Can be completed as a traitor only.",
    vars = {math.random(20, 30)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("PlayerDeath", "moat_innocent_exterminator", function(ply, inf, att)
            if (IsValid(att) and att:IsPlayer() and ply ~= att and att:GetRole() == ROLE_TRAITOR and WasRightfulKill(att, ply)) then
                MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier1_rewards_str,
    rewardtbl = tier1_rewards
})

--[[
MOAT_BOUNTIES:AddBounty("Clutch Master", {
    tier = 3,
    desc = "Win # rounds as the last traitor alive with the most amount of kills. Can be completed as a traitor only.",
    vars = {math.random(3, 5)},
    runfunc = function(mods, bountyid, idd)
        local traitor_died = false

        hook.Add("TTTEndRound", "moat_a_team_end", function(res)
            if (res ~= WIN_TRAITOR) then return end
            local pls = player.GetAll()
            local traitor = nil
            local traitors = 0

            for i = 1, #pls do
                if (pls[i]:Team() ~= TEAM_SPEC and pls[i]:GetRole() == ROLE_TRAITOR) then
                    traitors = traitors + 1
                    traitor = pls[i]
                end
            end

            if (traitors == 1 and traitor) then
                MOAT_BOUNTIES:IncreaseProgress(traitor, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})
]]
MOAT_BOUNTIES:AddBounty("Bunny Roleplayer", {
    roles = "innocent traitor detective",
    tier = 1,
    desc = "In # round, jump # times. Cannot be completed with auto hop.",
    vars = {1, math.random(200, 300)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("TTTBeginRound", "moat_reset_steps", function()
            for k, v in pairs(player.GetAll()) do
                v.BJumps = 0
            end
        end)

        hook.Add("SetupMove", "moat_bunny_roleplayer", function(pl, mv, cmd)
            if (GetRoundState() ~= ROUND_ACTIVE) then return end
            if (pl:Team() == TEAM_SPEC) then return end
            if (not pl:IsPlayer()) then return end

            if (pl:WaterLevel() == 0 and mv:KeyDown(IN_JUMP)) then
                local onGround = pl:IsOnGround()

                if (not onGround) then
                    pl.CanReceiveJump = true
                end

                if (onGround and pl.CanReceiveJump) then
                    pl.CanReceiveJump = false
                    pl.BJumps = (pl.BJumps or 0) + 1
                end
            end

            if (pl.BJumps == mods[2]) then
                MOAT_BOUNTIES:IncreaseProgress(pl, bountyid, mods[1], idd)
            end
        end)
    end,
    rewards = tier1_rewards_str,
    rewardtbl = tier1_rewards
})

MOAT_BOUNTIES:AddBounty("An Explosive Ending", {
    roles = "innocent traitor detective",
    tier = 3,
    desc = "With # explosion, eliminate # terrorists rightfully. Can be completed as any role.",
    vars = {1, math.random(4, 6)},
    runfunc = function(mods, bountyid, idd)
        hook.Add("EntityTakeDamage", "moat_explosive_ending", function(targ, dmg)
            local att = dmg:GetAttacker()

            if (targ:IsPlayer() and IsValid(att) and att:IsPlayer() and targ ~= att and WasRightfulKill(att, targ) and dmg:IsExplosionDamage() and dmg:GetDamage() >= targ:Health()) then
                if (att.LastExplosiveKill and att.LastExplosiveKill > CurTime() - 2) then
                    att.TotalExplosiveKills = (att.TotalExplosiveKills or 0) + 1

                    if (att.TotalExplosiveKills >= mods[2]) then
                        MOAT_BOUNTIES:IncreaseProgress(att, bountyid, mods[1], idd)
                    end
                else
                    att.TotalExplosiveKills = 1
                end

                att.LastExplosiveKill = CurTime()
            end
        end)
    end,
    rewards = tier3_rewards_str,
    rewardtbl = tier3_rewards
})

function MOAT_BOUNTIES:GetBountyVariables(bounty_id)
    local tbl = {}
    local possible_vars = self.Bounties[bounty_id].vars

    for i = 1, #possible_vars do
        tbl[i] = possible_vars[i]
    end

    return tbl
end

local used = {}

function MOAT_BOUNTIES:GetRandomBounty(tier_)
    local bounty_tbl = {}

    if (tier_ ~= 1) then
        for k, v in RandomPairs(self.Bounties) do
            if (v.tier == tier_) and (not used[k]) and (v.name ~= "Quickswitching killer") then
                bounty_tbl.id = k
                bounty_tbl.mods = self:GetBountyVariables(k)
                used[k] = true
                break
            end
        end
    else
        for k, v in RandomPairs(self.Bounties) do
            --removing soon
            if (v.tier == tier_) and (not used[k]) and (v.name ~= "Marathon Walker") and (v.name ~= "Bunny Roleplayer") then
                bounty_tbl.id = k
                bounty_tbl.mods = self:GetBountyVariables(k)
                used[k] = true
                break
            end
        end
    end

    return sql.SQLStr(util.TableToJSON(bounty_tbl), true)
end

function MOAT_BOUNTIES.ResetBounties()
end

function MOAT_BOUNTIES.DiscordBounties()
    local bstr, medals = "", {"", "", ""}

    local dailies = {}

    local colors = {16740864, 13421772, 16768616}

    for i = 1, 12 do
        local bounty = MOAT_BOUNTIES.ActiveBounties[i].bnty
        local mods = MOAT_BOUNTIES.ActiveBounties[i].mods
        local bounty_desc = bounty.desc
        local n = 0

        for _ = 1, #mods do
            bounty_desc = bounty_desc:gsub("#", function()
                n = n + 1

                return "[" .. (mods[n]) .. "](https://google.com)"
            end)
        end

        local embed = {
            author = {
                name = bounty.name .. " | " .. util.NiceDate() .. " | Global Daily Bounty",
                icon_url = medals[bounty.tier],
                url = "https:///google.com"
            },
            color = colors[bounty.tier],
            description = bounty_desc,
            footer = {
                text = bounty.rewards
            }
        }

        if (http and http.Loaded) then
            timer.Simple(1 * i, function()
                discord.Embed("Bounties", embed)
            end)
        else
            hook("HTTPLoaded", function()
                timer.Simple(1 * i, function()
                    discord.Embed("Bounties", embed)
                end)
            end)
        end
    end
end

function MOAT_BOUNTIES.InitializeBounties()
end

function MOAT_BOUNTIES:SendBountyToPlayer(ply, bounty, mods, current_progress)
    local bounty_desc = bounty.desc
    local c = 0

    for i = 1, #mods do
        bounty_desc = bounty_desc:gsub("#", function()
            c = c + 1

            return mods[c]
        end)
    end

    net.Start("moat_bounty_send")
    net.WriteUInt(bounty.tier, 4)
    net.WriteString(bounty.name)
    net.WriteString(bounty_desc)
    net.WriteString(bounty.rewards)
    net.WriteUInt(current_progress, 16)
    net.WriteUInt(mods[1], 16)
    net.WriteUInt(bounty.id, 16)
    net.Send(ply)
end

net.Receive("moat_bounty_reload", function(l, ply)
    if (ply:IsValid()) then
        MOAT_BOUNTIES.PlayerInitialSpawn(ply)
    end
end)

concommand.Add("moat_reset_bounties", function(ply, cmd, args)
    if (not moat.isdev(ply)) then return end
    MOAT_BOUNTIES.ResetBounties()
end)

function m_DropIndiCrate(ply, amt)
    for i = 1, amt do
        ply:m_DropInventoryItem("Independence Crate")
    end
end

net.Receive("bounty.refresh", function(_, ply)
    if (ply.dailies_sent or ply:IsBot()) then return end
    ply.dailies_sent = true

    moat.mysql("SELECT * FROM moat_lottery_players WHERE steamid = '" .. ply:SteamID64() .. "';", function(d)
        print"lottery_sent"
        net.Start("lottery.firstjoin")
        net.WriteTable(lottery_stats)
        net.WriteBool(#d > 0)

        if #d > 0 then
            net.WriteInt(d[1].ticket, 32)
        end

        net.Send(ply)

        if (not lottery_stats.loaded) then
            lottery_updatetotal()
            lottery_updateamount()
            lottery_updatepopular()
            lottery_updatelast()
        end
    end)

    timer.Simple(30, function()
        if (not IsValid(ply)) then return end

        moat.mysql("SELECT * FROM moat_lottery_winners WHERE steamid = '" .. ply:SteamID64() .. "';", function(d)
            if #d < 1 then return end
            if not IsValid(ply) then return end
            ply:m_GiveIC(d[1].amount)
            net.Start("lottery.Win")
            net.WriteInt(d[1].amount, 32)
            net.Send(ply)
            moat.mysql("DELETE FROM moat_lottery_winners WHERE steamid = '" .. ply:SteamID64() .. "';")
        end)
    end)

    moat.mysql("SELECT score FROM bounties_players WHERE steamid = '" .. ply:SteamID64() .. "';", function(d)
        if #d > 0 then
            ply.Bounties = util.JSONToTable(d[1].score)
        else
            ply.Bounties = {
                ID = MOAT_BOUNTIES.ActiveBounties.ID
            }
        end

        for k, v in pairs(MOAT_BOUNTIES.ActiveBounties) do
            if not isnumber(k) then continue end
            local cur_progress = 0

            if istable(ply.Bounties) then
                if ply.Bounties[v.id] and ply.Bounties.ID == MOAT_BOUNTIES.ActiveBounties.ID then
                    cur_progress = ply.Bounties[v.id][1]
                end
            end

            -- print "bounties_sent"
            MOAT_BOUNTIES:SendBountyToPlayer(ply, v.bnty, v.mods, cur_progress)
        end
    end)

    moat.mysql("INSERT INTO moat_contractplayers_v2 (steamid, score) VALUES (" .. ply:SteamID64() .. ", 0) ON DUPLICATE KEY UPDATE score=score;")

    moat.mysql("SELECT * FROM moat_contractplayers_v2 ORDER BY score DESC LIMIT 50", function(top)
        top_cache = top
        -- print "contracts_select"
        if (not IsValid(ply)) then return end

        moat.mysql("call selectContract('" .. ply:SteamID64() .. "');", function(p)
            if #p < 1 then return end
            -- print "contracts_data"
            -- PrintTable(p)
            if (not contract_loaded) then return end
            if (not IsValid(ply)) then return end

            -- print "contracts_sent"
            timer.Simple(0, function()
                net.Start("moat.contracts")
                net.WriteBool(true)
                net.WriteString(contract_loaded)
                net.WriteString(moat_contracts_v2[contract_loaded].desc)
                net.WriteString(moat_contracts_v2[contract_loaded].adj)
                net.WriteString(moat_contracts_v2[contract_loaded].short)
                net.WriteUInt(p[1].players, 16)
                net.WriteUInt(p[1].position, 16)
                net.WriteUInt(p[1].myscore, 16)
                net.WriteBool(true)
                net.WriteTable(top)
                net.Send(ply)
            end)
        end)
    end)

    moat.mysql("SELECT place FROM moat_contractwinners_v2 WHERE steamid = " .. ply:SteamID64() .. ";", function(d)
        if #d < 1 then return end

        timer.Simple(30, function()
            if not IsValid(ply) then return end
            reward_ply(ply, d[1].place)
            moat.mysql("DELETE FROM moat_contractwinners_v2 WHERE steamid = " .. ply:SteamID64() .. ";")
        end)
    end)

    timer.Simple(30, function()
        if (not IsValid(ply)) then return end
        if (ply:GetNW2Int("MOAT_STATS_LVL", -1) < 100) then return end

        moat.mysql("SELECT steamid FROM moat_veterangamers WHERE steamid = " .. ply:SteamID64() .. ";", function(d)
            if #d > 0 then return end
            ply:m_DropInventoryItem("Tesla Effect")
            moat.mysql("INSERT INTO moat_veterangamers (steamid) VALUES (" .. ply:SteamID64() .. ");")
        end)
    end)
end)