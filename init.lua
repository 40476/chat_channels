local storage = minetest.get_mod_storage()

-- Privileges
minetest.register_privilege("channel", { description = "Create/delete channels" })
minetest.register_privilege("chatstyle", { description = "Customize chat name style" })
minetest.register_privilege("announce", { description = "Send global announcements" })

-- Font styles
local font_styles = {}

font_styles.superscript = function(text)
  local map = { a = "ᵃ", b = "ᵇ", c = "ᶜ", d = "ᵈ", e = "ᵉ", f = "ᶠ", g = "ᵍ", h = "ʰ", i = "ᶦ", j = "ʲ", k = "ᵏ", l =
  "ˡ", m = "ᵐ", n = "ⁿ", o = "ᵒ", p = "ᵖ", q = "q", r = "ʳ", s = "ˢ", t = "ᵗ", u = "ᵘ", v = "ᵛ", w = "ʷ", x = "ˣ", y =
  "ʸ", z = "ᶻ", [" "] = " " }
  return text:lower():gsub(".", function(c) return map[c] or c end)
end

font_styles.smallcaps = function(text)
  local map = { a = "ᴀ", b = "ʙ", c = "ᴄ", d = "ᴅ", e = "ᴇ", f = "ғ", g = "ɢ", h = "ʜ", i = "ɪ", j = "ᴊ", k = "ᴋ", l =
  "ʟ", m = "ᴍ", n = "ɴ", o = "ᴏ", p = "ᴘ", q = "ǫ", r = "ʀ", s = "s", t = "ᴛ", u = "ᴜ", v = "ᴠ", w = "ᴡ", x = "x", y =
  "ʏ", z = "ᴢ", [" "] = " " }
  return text:lower():gsub(".", function(c) return map[c] or c end)
end

font_styles.upsidedown = function(text)
  local map = { a = "ɐ", b = "q", c = "ɔ", d = "p", e = "ǝ", f = "ɟ", g = "ƃ", h = "ɥ", i = "ᴉ", j = "ɾ", k = "ʞ", l =
  "ʃ", m = "ɯ", n = "u", o = "o", p = "d", q = "b", r = "ɹ", s = "s", t = "ʇ", u = "n", v = "ʌ", w = "ʍ", x = "x", y =
  "ʎ", z = "z", [" "] = " " }
  return text:lower():gsub(".", function(c) return map[c] or c end):reverse()
end

font_styles.fullwidth = function(text)
  return text:gsub(".", function(c)
    local byte = c:byte()
    if byte >= 33 and byte <= 126 then
      return utf8.char(0xFF00 + byte - 0x20)
    else
      return c
    end
  end)
end

font_styles.strikethrough = function(text)
  return text:gsub(".", function(c) return c .. "̶" end)
end

font_styles.boldunicode = function(text)
  local map = font_styles.smallcaps
  return map(text:upper())
end

font_styles.asianstyle = function(text)
  local map = { a = "卂", b = "乃", c = "匚", d = "刀", e = "乇", f = "千", g = "G", h = "卄", i = "丨", j = "ﾌ", k = "Ҝ", l =
  "ㄥ", m = "爪", n = "几", o = "ㄖ", p = "卩", q = "Ɋ", r = "尺", s = "丂", t = "ㄒ", u = "ㄩ", v = "V", w = "山", x = "乂", y =
  "ㄚ", z = "乙", [" "] = " " }
  return text:lower():gsub(".", function(c) return map[c] or c end)
end

-- Storage helpers
local function save_channels(channels)
  storage:set_string("channels", minetest.serialize(channels))
end

local function get_channels()
    local raw = storage:get_string("channels")
    local channels = raw ~= "" and minetest.deserialize(raw) or {}
    for name, ch in pairs(channels) do
        ch.members = ch.members or {}
        ch.banned = ch.banned or {}
        ch.private = ch.private or false
        ch.owner = ch.owner or "__system"
    end
    if not channels["global"] then
        channels["global"] = {owner="__system", private=false, members={}, banned={}}
    end
    save_channels(channels)
    return channels
end


local function get_player_data(name)
  local raw = storage:get_string("player:" .. name)
  local data = raw ~= "" and minetest.deserialize(raw) or {}
  data.channels = data.channels or {}
  data.active = data.active or nil
  data.font = data.font or nil
  data.first_joined = data.first_joined or false
  return data
end

local function save_player_data(name, data)
  storage:set_string("player:" .. name, minetest.serialize(data))
end

local function get_rank(name)
  local privs = minetest.get_player_privs(name)
  if privs.server then
    return "Admin"
  elseif privs.privs then
    return "Mod"
  elseif privs.fly or privs.fast then
    return "VIP"
  else
    return "Player"
  end
end

-- Chat handler
local function send_to_active_channel(sender, message)
    local pdata = get_player_data(sender)
    local chname = pdata.active
    if not chname then return end

    local channels = get_channels()
    local ch = channels[chname]
    if not ch then return end

    -- Defensive fallback
    ch.banned = ch.banned or {}

    if ch.banned[sender] then return end

    local rank = get_rank(sender)
    local color = pdata.color or "#FFFFFF"
    local font = pdata.font
    if font and font_styles[font] then
        message = font_styles[font](message)
    end

    local formatted = string.format("[%s] [%s] [%s]: %s",
    chname,
    rank,
    minetest.colorize(color, sender),
    message
)


    for _, player in ipairs(minetest.get_connected_players()) do
        local pname = player:get_player_name()
        local pdata2 = get_player_data(pname)
        if pdata2.channels[chname] then
            minetest.chat_send_player(pname, formatted)
        end
    end
end


minetest.register_on_chat_message(function(name, message)
  send_to_active_channel(name, message)
  return true
end)

minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  local pdata = get_player_data(name)

  if not pdata.first_joined then
    pdata.channels["global"] = true
    pdata.active = "global"
    pdata.first_joined = true
    save_player_data(name, pdata)

    minetest.chat_send_player(name, "📢 Welcome! Use /chat channel <name> <action> [target] to manage channels.")
    minetest.chat_send_player(name, "Examples: /chat channel teamchat join, /chat channel teamchat invite player1")
  end
end)

-- Announce
minetest.register_chatcommand("announce", {
  params = "<message>",
  description = "Send a message to all players",
  privs = { announce = true },
  func = function(name, param)
    local rank = get_rank(name)
    local msg = string.format("[ANNOUNCE] [%s] [%s]: %s", rank, name, param)
    for _, player in ipairs(minetest.get_connected_players()) do
      minetest.chat_send_player(player:get_player_name(), msg)
    end
    return true
  end
})

minetest.register_chatcommand("chat", {
  params = "<channel> <action> [target]",
  description = "Manage chat channels and styles",
  func = function(name, param)
    local args = param:split(" ")
    if #args < 2 then return false, "Usage: /chat <channel|style> <action> [target]" end

    local chname = args[1]
    local action = args[2]
    local target = args[3]
    local channels = get_channels()
    local pdata = get_player_data(name)
    local ch = channels[chname]
    local privs = minetest.get_player_privs(name)
    local is_mod = privs.privs or privs.server

    -- 🎨 Chat Style Customization
    if chname == "style" then
      if action == "list" then
        local styles = {}
        for k, _ in pairs(font_styles) do
          table.insert(styles, k)
        end
        return true, "Available fonts: " .. table.concat(styles, ", ")

      elseif action == "font" and target then
        local font = target:lower()
        if not font_styles[font] then
          return false, "Unknown font. Use /chat style list to see options."
        end
        pdata.font = font
        save_player_data(name, pdata)
        return true, "Font style set to: " .. font

      elseif action == "color" and target then
        if not target:match("^#%x%x%x%x%x%x$") then
          return false, "Invalid color. Use format: #RRGGBB"
        end
        pdata.color = target
        save_player_data(name, pdata)
        return true, "Chat name color set to: " .. target

      elseif action == "reset" then
        pdata.font = nil
        pdata.color = nil
        save_player_data(name, pdata)
        return true, "Chat style reset to default."

      else
        return false, "Usage: /chat style font <name>, color <#RRGGBB>, list, reset"
      end
    end

    -- 📡 Channel Management
    if action == "create" then
      if not privs.channel then return false, "Missing 'channel' privilege." end
      if channels[chname] then return false, "Channel exists." end
      channels[chname] = { owner = name, private = false, members = {}, banned = {} }
      save_channels(channels)
      return true, "Channel created."

    elseif action == "delete" then
      if not ch then return false, "Channel doesn't exist." end
      if ch.owner ~= name and not privs.server then return false, "Only owner or server can delete." end
      channels[chname] = nil
      save_channels(channels)
      return true, "Channel deleted."

    elseif action == "join" then
      if not ch then return false, "Channel doesn't exist." end
      if ch.private and not ch.members[name] and not is_mod then
        return false, "Invite-only channel."
      end
      if ch.banned and ch.banned[name] then
        return false, "You are banned from this channel."
      end
      pdata.channels[chname] = true
      pdata.active = chname
      save_player_data(name, pdata)
      return true, "Joined and set active channel: " .. chname

    elseif action == "leave" then
      pdata.channels[chname] = nil
      if pdata.active == chname then pdata.active = nil end
      save_player_data(name, pdata)
      return true, "Left channel: " .. chname

    elseif action == "invite" and target then
      if not ch then return false, "Channel doesn't exist." end
      if ch.owner ~= name then return false, "Only owner can invite." end
      ch.members[target] = true
      save_channels(channels)
      return true, "Invited " .. target .. " to " .. chname

    elseif action == "kick" and target then
      if not ch then return false, "Channel doesn't exist." end
      if ch.owner ~= name then return false, "Only owner can kick." end
      ch.members[target] = nil
      local pdata2 = get_player_data(target)
      pdata2.channels[chname] = nil
      if pdata2.active == chname then pdata2.active = nil end
      save_player_data(target, pdata2)
      save_channels(channels)
      return true, "Kicked " .. target .. " from " .. chname

    elseif action == "banish" and target then
      if not ch then return false, "Channel doesn't exist." end
      if ch.owner ~= name then return false, "Only owner can banish." end
      ch.banned[target] = true
      ch.members[target] = nil
      local pdata2 = get_player_data(target)
      pdata2.channels[chname] = nil
      if pdata2.active == chname then pdata2.active = nil end
      save_player_data(target, pdata2)
      save_channels(channels)
      return true, "Banned " .. target .. " from " .. chname

    elseif action == "mode" and target then
      if not ch then return false, "Channel doesn't exist." end
      if ch.owner ~= name then return false, "Only owner can change mode." end
      if target == "private" then
        ch.private = true
        save_channels(channels)
        return true, "Channel set to private."
      elseif target == "public" then
        ch.private = false
        save_channels(channels)
        return true, "Channel set to public."
      else
        return false, "Mode must be 'private' or 'public'."
      end

    elseif action == "setactive" then
      if not pdata.channels[chname] then
        return false, "You're not in that channel."
      end
      pdata.active = chname
      save_player_data(name, pdata)
      return true, "Active channel set to: " .. chname

    elseif action == "list" then
      if not target then
        local names = {}
        for cname, _ in pairs(channels) do
          table.insert(names, cname)
        end
        return true, "Channels: " .. table.concat(names, ", ")
      else
        local ch = channels[target]
        if not ch then return false, "Channel doesn't exist." end
        local members = {}
        for pname, _ in pairs(ch.members or {}) do
          table.insert(members, "[" .. pname .. "]")
        end
        local banned = {}
        for pname, _ in pairs(ch.banned or {}) do
          table.insert(banned, "[" .. pname .. "]")
        end
        return true,
          "Members: " .. table.concat(members, ", ") ..
          "\nBanned: " .. table.concat(banned, ", ")
      end
    end

    return false, "Unknown command or missing arguments."
  end
})
