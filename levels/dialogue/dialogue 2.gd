extends Dialogue
var d_n = "dialogue_name"
var d_s = "dialogue_set"

func _init():
	campaign_dialogue = [
	[
		{keys.PORTRAIT: "res://assets/portraits/necromancer.png",  keys.NAME:"Necromancer: Lord Montague", keys.DESCRIPTION: "[b]The Lich General has requested more corpses for his army. Get searching fool, lest you desire that I turn you into his next undead minion![/b]"},
		{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Goblin Slave: Grinkle",      keys.DESCRIPTION: "[b]B... but master,  Grinkle has already found all the corpses in the area... Grinkle has s..searched the entire battlefield for master...[/b]"},
		{keys.PORTRAIT: "res://assets/portraits/necromancer.png",  keys.NAME:"Lord Montague",              keys.DESCRIPTION: "[b]You dare?! Question my authority?? Pathetic creature... You're not worthy to even lick the hems of my cloak. Find me two fresh corpses by dawn or suffer the Consequences![/b]"},
		{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",                    keys.DESCRIPTION: "[b]Y... Yes master. Grinkle does as Grinkle is told...[/b]"},
	],
	[
		{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",                    keys.DESCRIPTION: "[b]N-n-no new corpses here... g-g-grinkle is in trouble :( [/b]"},
		{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",                    keys.DESCRIPTION: "[b]M-maybe Grinkle can find new corpses in the trees... [/b]"},
	]
]
	optional_dialogue =[
		{
			d_n:"Grinkle_finds_old_man",
			#if Grinkle is still alive and reaches the spot [x,y] on turn: T, trigger this:
			d_s:
			[
				{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",     keys.DESCRIPTION: "[b]Egad! A frail humie... [/b]"},
				{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",     keys.DESCRIPTION: "[b]i-if there's no more bodies.... Grinkle must make new bodies... [/b]"},
				{keys.PORTRAIT: "res://assets/portraits/old_man.png",      keys.NAME:"Old Man",     keys.DESCRIPTION: "[b][i]♫  Whistling  ♫[/i][p]What a nice day to be alive![/p][/b]"},
				{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",     keys.DESCRIPTION: "[b]s-sorry o-old man.... your life or Grinkles... Grinkle chooses Grinkle!!! [/b]"},
			]
		},

		{
			d_n:"Grinkle_finds_player",
			#if Grinkle is still alive and reaches the spot [x,y] on turn: T and the player has a unit within the squares [x1,y1],[x2,y2] trigger this:
			d_s:
			[
				{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",     keys.DESCRIPTION: "[b]Eeep! The humie army is here... [/b]"},
				{keys.PORTRAIT: "res://assets/portraits/old_man.png",      keys.NAME:"Player",      keys.DESCRIPTION: "[b]Halt![/b]"},
			]
		},
		
		{
			d_n:"Grinkle_kills_old_man",
			#After Grinkle finds the old man - he kills the old man but is still killed by Lord Montague
			d_s:
			[
				{keys.PORTRAIT: "res://assets/portraits/necromancer.png",  keys.NAME:"Lord Montague", keys.DESCRIPTION: "[b]Well? Did you find two fresh corpses?[/b]"},
				{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",       keys.DESCRIPTION: "[b]M-master! Grinkle did his best see? Grinkle did good yes?[/b]"},
				{keys.PORTRAIT: "res://assets/portraits/necromancer.png",  keys.NAME:"Lord Montague", keys.DESCRIPTION: "[b]Harrumph, I only see one corpse...[/b]"},
				{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",       keys.DESCRIPTION: "[b]B-but Master... there are no more corpses - this is the best that Grinkle can do! Grinkle even made a new corpse for master...[/b]"},
				{keys.PORTRAIT: "res://assets/portraits/necromancer.png",  keys.NAME:"Lord Montague", keys.DESCRIPTION: "[b]It seems you have outlived your usefulness then... I do confess an error most grievous - mine eyes, erstwhile deceived by doubt, now behold not one fallen soul, but two... Congratulations Grinkle, you've finally met my requirements.[/b]"},
				{keys.PORTRAIT: "res://assets/portraits/goblin_slave.png", keys.NAME:"Grinkle",       keys.DESCRIPTION: "[b]M-master? [p][font size=40]AAaaEEeeOoughghg!![/font][/p][/b]"},
			]
		}

	]
