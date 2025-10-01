local storage = minetest.get_mod_storage()
chat_channels = {}
-- Privileges
minetest.register_privilege("channel", { description = "Create/delete channels" })
minetest.register_privilege("chatstyle", { description = "Customize chat name style" })
minetest.register_privilege("announce", { description = "Send global announcements" })

local privs_to_grant = {}
for priv in string.gmatch(minetest.settings:get("rules.privs_to_grant") or "shout,interact,home,lumberjack,channel,chatstyle", "([^,]+)") do
    table.insert(privs_to_grant, priv)
end

-- Font styles
local font_styles = {}

font_styles.superscript = function(text)
  local map = {
    a = "ᵃ", b = "ᵇ", c = "ᶜ", d = "ᵈ", e = "ᵉ", f = "ᶠ", g = "ᵍ",
    h = "ʰ", i = "ᶦ", j = "ʲ", k = "ᵏ", l = "ˡ", m = "ᵐ", n = "ⁿ",
    o = "ᵒ", p = "ᵖ", q = "q", r = "ʳ", s = "ˢ", t = "ᵗ", u = "ᵘ",
    v = "ᵛ", w = "ʷ", x = "ˣ", y = "ʸ", z = "ᶻ", [" "] = " "
  }
  return text:lower():gsub(".", function(c) return map[c] or c end)
end

font_styles.smallcaps = function(text)
  local map = {
    a = "ᴀ", b = "ʙ", c = "ᴄ", d = "ᴅ", e = "ᴇ", f = "ғ", g = "ɢ",
    h = "ʜ", i = "ɪ", j = "ᴊ", k = "ᴋ", l = "ʟ", m = "ᴍ", n = "ɴ",
    o = "ᴏ", p = "ᴘ", q = "ǫ", r = "ʀ", s = "s", t = "ᴛ", u = "ᴜ",
    v = "ᴠ", w = "ᴡ", x = "x", y = "ʏ", z = "ᴢ", [" "] = " "
  }
  return text:lower():gsub(".", function(c) return map[c] or c end)
end

font_styles.upsidedown = function(text)
  local map = {
    a = "ɐ", b = "q", c = "ɔ", d = "p", e = "ǝ", f = "ɟ", g = "ƃ",
    h = "ɥ",i = "ᴉ", j = "ɾ", k = "ʞ", l = "ʃ", m = "ɯ", n = "u",
    o = "o", p = "d", q = "b", r = "ɹ", s = "s", t = "ʇ", u = "n",
    v = "ʌ", w = "ʍ", x = "x", y = "ʎ", z = "z", [" "] = " "
  }
  return text:lower():gsub(".", function(c) return map[c] or c end):reverse()
end

font_styles.owo = function(input)
    -- Check for nil or non-string input
    if type(input) ~= "string" then
        return "nuuu that's not text! >w<"
    end

    local output = input

    -- Basic OwO replacements
    output = output:gsub("r", "w")
    output = output:gsub("l", "w")
    output = output:gsub("R", "W")
    output = output:gsub("L", "W")

    -- Extra absurd replacements
    output = output:gsub("ove", "uv")
    output = output:gsub("the", "da")
    output = output:gsub("you", "u")
    output = output:gsub("!", "!!1! >w<")
    output = output:gsub("?", "?? ;;w;;")

    -- Random stutter for absurdity
    local words = {}
    for word in output:gmatch("%S+") do
        if math.random() < 0.3 then
            word = word:sub(1, 1) .. "-" .. word
        end
        table.insert(words, word)
    end
    output = table.concat(words, " ")

    -- Add random OwO faces
    local faces = { "owo", "UwU", ">w<", "^w^", ";;w;;", "x3", ":3", "@w@" }
    local face = faces[math.random(#faces)]
    output = output .. " " .. face .. " " .. face

    return output
end

font_styles.catgirl = function(input)
    -- Input validation
    if type(input) ~= "string" then
        return "*tilts head* Nya? That's not text, baka! >.<"
    end

    local output = input

    -- Classic OwO substitutions
    output = output:gsub("r", "w")
    output = output:gsub("l", "w")
    output = output:gsub("R", "W")
    output = output:gsub("L", "W")
    output = output:gsub("n", "ny")
    output = output:gsub("N", "NY")
    output = output:gsub("na", "nya")
    output = output:gsub("nyu", "nyu~")
    output = output:gsub("ove", "uv")
    output = output:gsub("you", "y-you" .. (" >///<"):rep(math.random(1, 2)))

    -- Add extra stuttering occasionally
    local words = {}
    for word in output:gmatch("%S+") do
        if math.random() < 0.3 then
            word = word:sub(1, 1) .. "-" .. word
        end
        table.insert(words, word)
    end
    output = table.concat(words, " ")

    -- Add suffixes randomly for cuteness overload
    local suffixes = { "nya", "nya~", "meow", "mew~", "purr~", "~" }
    local suffix = suffixes[math.random(#suffixes)]
    output = output .. " " .. suffix .. " " .. ("^w^"):rep(math.random(1, 3))

    -- Random catgirl exclamations
    local exclamations = {
        "*paws at you*", "*purrs*", "*nuzzles*", "*ears twitch*", "*mrow*",
        "*tilts head*", "*licks lips*", "*giggles*", "*ears flatten*", "*hisses softly*"
    }
    if math.random() < 0.4 then
        local exclamation = exclamations[math.random(#exclamations)]
        output = exclamation .. " " .. output
    end

    return output
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
  local map = {
    a = "卂", b = "乃", c = "匚", d = "刀", e = "乇", f = "千", g = "G",
    h = "卄", i = "丨", j = "ﾌ", k = "Ҝ", l = "ㄥ", m = "爪", n = "几",
    o = "ㄖ", p = "卩", q = "Ɋ", r = "尺", s = "丂", t = "ㄒ", u = "ㄩ",
    v = "V", w = "山", x = "乂", y = "ㄚ", z = "乙", [" "] = " "
  }
  return text:lower():gsub(".", function(c) return map[c] or c end)
end

-- Storage helpers
local function save_channels(channels)
  storage:set_string("channels", minetest.serialize(channels))
end

local function load_rules()
    local f = io.open(minetest.get_worldpath() .. "/rules.txt", "r")
    if f then
        local content = f:read("*all")
        f:close()
        if content ~= "" then
            return content
        end
    end
end

local function save_rules(content)
    local f = io.open(minetest.get_worldpath() .. "/rules.txt", "w")
    if f then
        f:write(content)
        f:close()
    end
end

-- Rules
local function show_rules(name, editable)
    local formspec = {
        "formspec_version[4]",
        "size[10,8]",
        "textarea[0.3,0.3;9.5,6.5;;Server Rules;" .. minetest.formspec_escape(load_rules()) .. "]",
        "button_exit[4,7.2;2,0.8;done;Done]"
    }
    if editable then
        formspec[#formspec+1] = "button[7.8,7.2;2,0.8;edit;Edit]"
    end
    minetest.show_formspec(name, "rules:main", table.concat(formspec))
end

-- Formatting
local function trim_luanti_color_codes(text)
    -- Pattern explanation:
    -- \27 matches the escape character (ASCII 27)
    -- %(c@#......%)%] matches the literal string "(c@#" followed by 6 hex digits and ")"
    return text:gsub("\27%(c@#%x%x%x%x%x%x%)", "")
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
    channels["global"] = { owner = "__system", private = false, members = {}, banned = {} }
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
local function send_to_active_channel(sender, message, channel, is_matrix)
  local og_msg = message
  local is_mod_sender = not minetest.get_player_by_name(sender)
  local pdata = is_mod_sender and {} or get_player_data(sender)
  local chname = channel or pdata.active
  if not chname then
    print("[chat] No channel specified or active for sender:", sender)
    return
  end

  local channels = get_channels()
  local ch = channels[chname]
  if not ch then
    print("[chat] Channel '" .. chname .. "' does not exist.")
    return
  end

  ch.banned = ch.banned or {}
  if not is_mod_sender and ch.banned[sender] then
    print("[chat] Sender '" .. sender .. "' is banned from channel:", chname)
    return
  end

  local rank = is_mod_sender and "MOD" or get_rank(sender)
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

  if is_matrix == 2 then
    for _, player in ipairs(minetest.get_connected_players()) do
      local pname = player:get_player_name()
      local pdata2 = get_player_data(pname)
      if pdata2.channels[chname] then
        minetest.chat_send_player(pname, formatted)
      end
    end
  elseif is_matrix == 1 then
    return formatted
  elseif is_matrix == 0 then
    for _, player in ipairs(minetest.get_connected_players()) do
      local pname = player:get_player_name()
      local pdata2 = get_player_data(pname)
      if pdata2.channels[chname] then
        minetest.chat_send_player(pname, og_msg)
      end
    end
  end
end

minetest.register_on_chat_message(function(name, message)
  local active_channel = get_player_data(name).active or "global"

  -- Format the message once, for both in-game and Matrix use
  local formatted_message = send_to_active_channel(name, message, nil, 1)

  -- Send to in-game players (non-matrix)
  send_to_active_channel(name, formatted_message, nil, 0)

  -- Send to Matrix if available
  if matrix_bridge and matrix_bridge.send_raw and formatted_message and active_channel == "global" then
    matrix_bridge.send_raw(trim_luanti_color_codes(formatted_message))
  end

  -- Allow challenge_respond if present
  if type(challenge_respond) == "function" then
    challenge_respond(name, message)
  end

  -- Prevent default handling
  return true
end)


minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  local pdata = get_player_data(name)

  if not pdata.first_joined then
    minetest.chat_send_player(name, "📢 Welcome! Use /chat channel <name> <action> [target] to manage channels.")
    minetest.chat_send_player(name, "Examples: /chat channel teamchat join, /chat channel teamchat invite player1")
    show_rules(name, false)
  end
end)

function chat_channels.send(mod, channel, message)
  send_to_active_channel(mod, message, channel,2)
end

function chat_channels.create(channel)
  local channels = get_channels()
  if channels[channel] then return false, "Channel exists." end
  channels[channel] = { owner = "server=", private = false, members = {}, banned = {} }
  save_channels(channels)
end



minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "rules:main" then return end
    local name = player:get_player_name()
    local privs = minetest.get_player_privs(name)
    local pdata = get_player_data(name)
    
    if fields.edit and privs.server then
        minetest.show_formspec(name, "rules:edit",
            "formspec_version[4]" ..
            "size[10,8]" ..
            "textarea[0.3,0.3;9.5,6.5;edit_rules;Edit Rules;" ..
            minetest.formspec_escape(load_rules()) .. "]" ..
            "button_exit[4,7.2;2,0.8;save;Save]")
    end
    
    if not fields.done and not pdata.first_joined then
      return minetest.kick_player(name,"Clearly, " .. name .. " doesn't understand the meaning of peace.")
    end
    if fields.save and privs.server then
        local fs = minetest.get_player_by_name(name)
        if fs then
             
            save_rules(fields.edit_rules or "No Rules yet.")
            minetest.chat_send_player(name, "Rules updated!")
        end
    elseif fields.done and not privs.server and pdata.first_joined then
      for i, v in pairs(privs_to_grant) do
        privs[v]=true
      end
      minetest.set_player_privs(name, privs)
      pdata.channels["global"] = true
      pdata.channels['challenges'] = true
      pdata.active = "global"
      pdata.first_joined = true
      save_player_data(name, pdata)
      chat_channels.send("chat_channels", "general", name .. " accepted the rules and has been granted privileges!")
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
  params = "<mode> <action> [target]",
  description = "Manage chat channels and styles",
  func = function(name, param)
    local args = param:split(" ")
    if #args < 2 then
      return false, "Usage: /chat <channel|style> <action> [target]"
    end

    local mode = args[1]:lower()
    local action = args[2]:lower()
    local target = args[3]
    local channels = get_channels()
    local pdata = get_player_data(name)
    local privs = minetest.get_player_privs(name)
    local is_mod = privs.privs or privs.server

    -- 🎨 Style Mode
    if mode == "style" then
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

    -- 📡 Channel Mode
    if mode == "channel" then
      if not target and action ~= "list" and action ~= "setactive" then
        return false, "Missing channel name or target."
      end

      local chname = target
      local ch = channels[chname]

      if action == "create" then
        if not privs.channel then return false, "Missing 'channel' privilege." end
        if channels[chname] then return false, "Channel exists." end
        channels[chname] = { owner = name, private = false, members = {}, banned = {} }
        save_channels(channels)
        return true, "Channel created: " .. chname

      elseif action == "delete" then
        if not ch then return false, "Channel doesn't exist." end
        if ch.owner ~= name and not privs.server then return false, "Only owner or server can delete." end
        channels[chname] = nil
        save_channels(channels)
        return true, "Channel deleted: " .. chname

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

      elseif action == "invite" then
        if not ch then return false, "Channel doesn't exist." end
        if ch.owner ~= name then return false, "Only owner can invite." end
        ch.members[target] = true
        save_channels(channels)
        return true, "Invited " .. target .. " to " .. chname

      elseif action == "kick" then
        if not ch then return false, "Channel doesn't exist." end
        if ch.owner ~= name then return false, "Only owner can kick." end
        ch.members[target] = nil
        local pdata2 = get_player_data(target)
        pdata2.channels[chname] = nil
        if pdata2.active == chname then pdata2.active = nil end
        save_player_data(target, pdata2)
        save_channels(channels)
        return true, "Kicked " .. target .. " from " .. chname

      elseif action == "banish" then
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

      elseif action == "mode" then
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
    end
    return false, "Unknown command or missing arguments."
  end
})

minetest.register_chatcommand("rules", {
  description = "View the server rules",
  func = function(name)
  local player = minetest.get_player_by_name(name)
  if not player then return end
    local privs = minetest.get_player_privs(name)
    show_rules(name, privs.server)
    end,
})

--Autocmplete wrote this all on it s own:
-- What I am doing here?
-- I am trying to ignore this file in vscode git extension.
-- But it is not working.
-- So I am adding a dummy line here to see if it works.
-- If it works, I will remove this line later.
-- If it does not work, I will remove the dummy line later.