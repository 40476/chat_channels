# 🗨️ Minetest Chat Channels Mod

Welcome to the **Chat Channels Mod**, where your Minetest server finally gets the social structure it deserves. Tired of everyone yelling into the same global void? Want to banish your annoying little brother to his own channel? Dreaming of chat messages in upside-down Unicode? You're in the right place.

## 📦 Features

- **Custom Chat Channels**: Create, delete, join, leave, kick, invite, banish, and whisper sweet nothings in private.
- **Font Styles**: Because plain text is for peasants.
- **Color Customization**: Make your name pop like a neon sign in a medieval tavern.
- **Global Announcements**: For when you absolutely must tell everyone the server is on fire.
- **Persistent Storage**: Your chaos is saved forever. You're welcome.

## 🛡️ Privileges

To prevent total anarchy, we’ve added some privileges:

| Privilege   | Description                            |
|-------------|----------------------------------------|
| `channel`   | Create and delete channels             |
| `chatstyle` | Customize your chat name style         |
| `announce`  | Send global announcements              |

If you don’t have these, go beg your server admin. Or bribe them. We don’t judge.

## 🎨 Font Styles

Because normal letters are boring. Choose from:

- `superscript`: For when you want your words to float like your ego.
- `smallcaps`: Pretend you're shouting in a classy way.
- `upsidedown`: Perfect for confusing everyone.
- `fullwidth`: Ｌｏｏｋ　ｌｉｋｅ　ｙｏｕ’ｒｅ　ｓｐｅａｋｉｎｇ　ｆｒｏｍ　ｔｈｅ　Ｍａｔｒｉｘ．
- `strikethrough`: ~Say things you don’t mean~.
- `boldunicode`: Because CAPS LOCK is too mainstream.
- `asianstyle`: Aesthetic overload.

## 💬 Commands

### `/chat style <action> [target]`

Customize your chat style:

- `list`: Shows available fonts.
- `font <name>`: Sets your font style.
- `color <#RRGGBB>`: Sets your name color.
- `reset`: Clears your style back to boring default.

### `/chat <channel> <action> [target]`

Manage your chat channels like a true dictator:

- `create`: Make a new channel.
- `delete`: Destroy it like your ex’s mixtape.
- `join`: Join a channel.
- `leave`: Rage quit.
- `invite <player>`: Let someone in.
- `kick <player>`: Yeet someone out.
- `banish <player>`: Yeet and lock the door.
- `unban <player>`: Regret your decisions.
- `mode <private|public>`: Toggle channel privacy.
- `setactive`: Make a channel your main squeeze.
- `list`: See all channels or members of one.

### `/announce <message>`

Broadcast your wisdom to the masses. Requires `announce` privilege. Use responsibly. Or don’t.

## 🧠 How It Works

- Player data and channels are stored using Minetest’s mod storage. Yes, it’s persistent. No, you can’t pretend you didn’t say that.
- On first join, players are automatically added to the `global` channel. It’s like a default friend you can’t unfriend.
- Messages are routed to your active channel. If you’re not in one, you’re basically talking to yourself.

## 🧪 Future Ideas

- GUI support (because typing is hard).
- Channel emojis (because feelings matter).
- Moderation logs (for when drama inevitably unfolds).

## 🧙‍♂️ Final Thoughts

This mod turns your Minetest server into a social experiment. Will players form cliques? Will someone create a channel called “The Cool Kids” and ban everyone else? Probably. But at least now you can do it in style.

---

Made with love, sarcasm, and way too much Unicode.
