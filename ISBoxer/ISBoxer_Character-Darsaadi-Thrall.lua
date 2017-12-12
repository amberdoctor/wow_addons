isboxer.Character.Name = "Darsaadi-Thrall";
isboxer.Character.ActualName = "Darsaadi";
isboxer.Character.QualifiedName = "Darsaadi-Thrall";

function isboxer.Character_LoadBinds()
	if (isboxer.CharacterSet.Name=="one of each") then
		isboxer.SetMacro("FTLAssist","BACKSPACE","/assist [nomod:alt,mod:lshift,nomod:ctrl]Philomela;[nomod:alt,mod:rshift,nomod:ctrl]Ashimagari;[nomod:alt,nomod:shift,mod:lctrl]Ubuy;[mod:lalt,nomod:shift,nomod:ctrl]Anastasoula;[nomod:alt,mod:lshift,mod:lctrl]Lorakain;[mod:lalt,mod:lshift,nomod:ctrl]Darsaadi;[nomod:alt,mod:rshift,mod:lctrl]Luscinia;[mod:lalt,mod:rshift,nomod:ctrl]Tydeüs\n",1,1,1,1);

		isboxer.SetMacro("FTLFocus","NONE","/focus [nomod:alt,mod:lshift,nomod:ctrl]Philomela;[nomod:alt,mod:rshift,nomod:ctrl]Ashimagari;[nomod:alt,nomod:shift,mod:lctrl]Ubuy;[mod:lalt,nomod:shift,nomod:ctrl]Anastasoula;[nomod:alt,mod:lshift,mod:lctrl]Lorakain;[mod:lalt,mod:lshift,nomod:ctrl]Darsaadi;[nomod:alt,mod:rshift,mod:lctrl]Luscinia;[mod:lalt,mod:rshift,nomod:ctrl]Tydeüs\n",1,1,1,1);

		isboxer.SetMacro("FTLFollow","F11","/jamba-follow snw\n/follow [nomod:alt,mod:lshift,nomod:ctrl]Philomela;[nomod:alt,mod:rshift,nomod:ctrl]Ashimagari;[nomod:alt,nomod:shift,mod:lctrl]Ubuy;[mod:lalt,nomod:shift,nomod:ctrl]Anastasoula;[nomod:alt,mod:lshift,mod:lctrl]Lorakain;[mod:lalt,mod:lshift,nomod:ctrl]Darsaadi;[nomod:alt,mod:rshift,mod:lctrl]Luscinia;[mod:lalt,mod:rshift,nomod:ctrl]Tydeüs\n",1,1,1,1);

		isboxer.SetMacro("FTLTarget","]","/targetexact [nomod:alt,mod:lshift,nomod:ctrl]Philomela;[nomod:alt,mod:rshift,nomod:ctrl]Ashimagari;[nomod:alt,nomod:shift,mod:lctrl]Ubuy;[mod:lalt,nomod:shift,nomod:ctrl]Anastasoula;[nomod:alt,mod:lshift,mod:lctrl]Lorakain;[mod:lalt,mod:lshift,nomod:ctrl]Darsaadi;[nomod:alt,mod:rshift,mod:lctrl]Luscinia;[mod:lalt,mod:rshift,nomod:ctrl]Tydeüs\n",1,1,1,1);

		isboxer.SetMacro("InviteTeam","ALT-CTRL-SHIFT-I","/invite Philomela\n/invite Ashimagari\n/invite Ubuy\n/invite Anastasoula\n/invite Lorakain\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOn","ALT-SHIFT-N","/console autointeract 1\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOff","ALT-CTRL-N","/console autointeract 0\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaMaster","CTRL-SHIFT-F12","/jamba-team iammaster all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOn","ALT-SHIFT-F12","/jamba-follow strobeonme all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOff","ALT-CTRL-SHIFT-F12","/jamba-follow strobeoff all\n",nil,nil,nil,1);

		isboxer.ClearMembers();
		isboxer.AddMember("Philomela-Thrall");
		isboxer.AddMember("Ashimagari-Thrall");
		isboxer.AddMember("Ubuy-Thrall");
		isboxer.AddMember("Anastasoula-Thrall");
		isboxer.AddMember("Lorakain-Thrall");
		isboxer.AddMember("Darsaadi-Thrall");
		isboxer.AddMember("Luscinia-Thrall");
		isboxer.AddMember("Tydeüs-Thrall");
		isboxer.SetMaster("Philomela-Thrall");
		return
	end
end
isboxer.Character.LoadBinds = isboxer.Character_LoadBinds;

isboxer.Output("Character 'Darsaadi-Thrall' activated");
