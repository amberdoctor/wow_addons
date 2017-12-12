isboxer.Character.Name = "Diomedës-Thrall";
isboxer.Character.ActualName = "Diomedës";
isboxer.Character.QualifiedName = "Diomedës-Thrall";

function isboxer.Character_LoadBinds()
	if (isboxer.CharacterSet.Name=="Philomela Ana Dio Lyssia Ubuy") then
		isboxer.SetMacro("FTLAssist","BACKSPACE","/assist [nomod:alt,mod:lshift,nomod:ctrl]Philomela;[nomod:alt,mod:rshift,nomod:ctrl]Anastasoula;[nomod:alt,nomod:shift,mod:lctrl]Diomedës;[mod:lalt,nomod:shift,nomod:ctrl]Lyssiá;[nomod:alt,mod:lshift,mod:lctrl]Ubuy\n",1,1,1,1);

		isboxer.SetMacro("FTLFocus","NONE","/focus [nomod:alt,mod:lshift,nomod:ctrl]Philomela;[nomod:alt,mod:rshift,nomod:ctrl]Anastasoula;[nomod:alt,nomod:shift,mod:lctrl]Diomedës;[mod:lalt,nomod:shift,nomod:ctrl]Lyssiá;[nomod:alt,mod:lshift,mod:lctrl]Ubuy\n",1,1,1,1);

		isboxer.SetMacro("FTLFollow","F11","/jamba-follow snw\n/follow [nomod:alt,mod:lshift,nomod:ctrl]Philomela;[nomod:alt,mod:rshift,nomod:ctrl]Anastasoula;[nomod:alt,nomod:shift,mod:lctrl]Diomedës;[mod:lalt,nomod:shift,nomod:ctrl]Lyssiá;[nomod:alt,mod:lshift,mod:lctrl]Ubuy\n",1,1,1,1);

		isboxer.SetMacro("FTLTarget","]","/targetexact [nomod:alt,mod:lshift,nomod:ctrl]Philomela;[nomod:alt,mod:rshift,nomod:ctrl]Anastasoula;[nomod:alt,nomod:shift,mod:lctrl]Diomedës;[mod:lalt,nomod:shift,nomod:ctrl]Lyssiá;[nomod:alt,mod:lshift,mod:lctrl]Ubuy\n",1,1,1,1);

		isboxer.SetMacro("InviteTeam","ALT-CTRL-SHIFT-I","/invite Philomela\n/invite Anastasoula\n/invite Lyssiá\n/invite Ubuy\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOn","ALT-SHIFT-N","/console autointeract 1\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOff","ALT-CTRL-N","/console autointeract 0\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaMaster","CTRL-SHIFT-F12","/jamba-team iammaster all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOn","ALT-SHIFT-F12","/jamba-follow strobeonme all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOff","ALT-CTRL-SHIFT-F12","/jamba-follow strobeoff all\n",nil,nil,nil,1);

		isboxer.ClearMembers();
		isboxer.AddMember("Philomela-Thrall");
		isboxer.AddMember("Anastasoula-Thrall");
		isboxer.AddMember("Diomedës-Thrall");
		isboxer.AddMember("Lyssiá-Thrall");
		isboxer.AddMember("Ubuy-Thrall");
		isboxer.SetMaster("Philomela-Thrall");
		return
	end
end
isboxer.Character.LoadBinds = isboxer.Character_LoadBinds;

isboxer.Output("Character 'Diomedës-Thrall' activated");
