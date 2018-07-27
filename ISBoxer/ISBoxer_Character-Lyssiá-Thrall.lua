isboxer.Character.Name = "Lyssiá-Thrall";
isboxer.Character.ActualName = "Lyssiá";
isboxer.Character.QualifiedName = "Lyssiá-Thrall";

function isboxer.Character_LoadBinds()
	if (isboxer.CharacterSet.Name=="3 alt guild") then
		isboxer.SetMacro("FTLAssist","BACKSPACE","/assist [nomod:alt,mod:lshift,nomod:ctrl]Lyssiá;[nomod:alt,mod:rshift,nomod:ctrl]Tydeüs;[nomod:alt,nomod:shift,mod:lctrl]Darsaadi\n",1,1,1,1);

		isboxer.SetMacro("FTLFocus","NONE","/focus [nomod:alt,mod:lshift,nomod:ctrl]Lyssiá;[nomod:alt,mod:rshift,nomod:ctrl]Tydeüs;[nomod:alt,nomod:shift,mod:lctrl]Darsaadi\n",1,1,1,1);

		isboxer.SetMacro("FTLFollow","F11","/jamba-follow snw\n/follow [nomod:alt,mod:lshift,nomod:ctrl]Lyssiá;[nomod:alt,mod:rshift,nomod:ctrl]Tydeüs;[nomod:alt,nomod:shift,mod:lctrl]Darsaadi\n",1,1,1,1);

		isboxer.SetMacro("FTLTarget","]","/targetexact [nomod:alt,mod:lshift,nomod:ctrl]Lyssiá;[nomod:alt,mod:rshift,nomod:ctrl]Tydeüs;[nomod:alt,nomod:shift,mod:lctrl]Darsaadi\n",1,1,1,1);

		isboxer.SetMacro("InviteTeam","ALT-CTRL-SHIFT-I","/invite Tydeüs\n/invite Darsaadi\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOn","ALT-SHIFT-N","/console autointeract 1\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOff","ALT-CTRL-N","/console autointeract 0\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaMaster","CTRL-SHIFT-F12","/jamba-team iammaster all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOn","ALT-SHIFT-F12","/jamba-follow strobeonme all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOff","ALT-CTRL-SHIFT-F12","/jamba-follow strobeoff all\n",nil,nil,nil,1);

		isboxer.SetMacro("","ALT-SHIFT-Z","/cast Crimson Water Strider\n",nil,nil,nil,1);

		isboxer.ClearMembers();
		isboxer.AddMember("Lyssiá-Thrall");
		isboxer.AddMember("Tydeüs-Thrall");
		isboxer.AddMember("Darsaadi-Thrall");
		isboxer.SetMaster("Lyssiá-Thrall");
		return
	end
	if (isboxer.CharacterSet.Name=="Dio Lys") then
		isboxer.SetMacro("FTLAssist","BACKSPACE","/assist [nomod:alt,mod:lshift,nomod:ctrl]Diomedes;[nomod:alt,mod:rshift,nomod:ctrl]Lyssiá\n",1,1,1,1);

		isboxer.SetMacro("FTLFocus","NONE","/focus [nomod:alt,mod:lshift,nomod:ctrl]Diomedes;[nomod:alt,mod:rshift,nomod:ctrl]Lyssiá\n",1,1,1,1);

		isboxer.SetMacro("FTLFollow","F11","/jamba-follow snw\n/follow [nomod:alt,mod:lshift,nomod:ctrl]Diomedes;[nomod:alt,mod:rshift,nomod:ctrl]Lyssiá\n",1,1,1,1);

		isboxer.SetMacro("FTLTarget","]","/targetexact [nomod:alt,mod:lshift,nomod:ctrl]Diomedes;[nomod:alt,mod:rshift,nomod:ctrl]Lyssiá\n",1,1,1,1);

		isboxer.SetMacro("InviteTeam","ALT-CTRL-SHIFT-I","/invite Diomedes\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOn","ALT-SHIFT-N","/console autointeract 1\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOff","ALT-CTRL-N","/console autointeract 0\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaMaster","CTRL-SHIFT-F12","/jamba-team iammaster all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOn","ALT-SHIFT-F12","/jamba-follow strobeonme all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOff","ALT-CTRL-SHIFT-F12","/jamba-follow strobeoff all\n",nil,nil,nil,1);

		isboxer.ClearMembers();
		isboxer.AddMember("Diomedes-Thrall");
		isboxer.AddMember("Lyssiá-Thrall");
		isboxer.SetMaster("Diomedes-Thrall");
		return
	end
end
isboxer.Character.LoadBinds = isboxer.Character_LoadBinds;

isboxer.Output("Character 'Lyssiá-Thrall' activated");
