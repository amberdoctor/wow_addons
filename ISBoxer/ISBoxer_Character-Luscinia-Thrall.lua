isboxer.Character.Name = "Luscinia-Thrall";
isboxer.Character.ActualName = "Luscinia";
isboxer.Character.QualifiedName = "Luscinia-Thrall";

function isboxer.Character_LoadBinds()
	if (isboxer.CharacterSet.Name=="lusc tyd") then
		isboxer.SetMacro("FTLAssist","BACKSPACE","/assist [nomod:alt,mod:lshift,nomod:ctrl]Luscinia;[nomod:alt,mod:rshift,nomod:ctrl]Tydeüs\n",1,1,1,1);

		isboxer.SetMacro("FTLFocus","NONE","/focus [nomod:alt,mod:lshift,nomod:ctrl]Luscinia;[nomod:alt,mod:rshift,nomod:ctrl]Tydeüs\n",1,1,1,1);

		isboxer.SetMacro("FTLFollow","F11","/jamba-follow snw\n/follow [nomod:alt,mod:lshift,nomod:ctrl]Luscinia;[nomod:alt,mod:rshift,nomod:ctrl]Tydeüs\n",1,1,1,1);

		isboxer.SetMacro("FTLTarget","]","/targetexact [nomod:alt,mod:lshift,nomod:ctrl]Luscinia;[nomod:alt,mod:rshift,nomod:ctrl]Tydeüs\n",1,1,1,1);

		isboxer.SetMacro("InviteTeam","ALT-CTRL-SHIFT-I","/invite Tydeüs\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOn","ALT-SHIFT-N","/console autointeract 1\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOff","ALT-CTRL-N","/console autointeract 0\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaMaster","CTRL-SHIFT-F12","/jamba-team iammaster all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOn","ALT-SHIFT-F12","/jamba-follow strobeonme all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOff","ALT-CTRL-SHIFT-F12","/jamba-follow strobeoff all\n",nil,nil,nil,1);

		isboxer.ClearMembers();
		isboxer.AddMember("Luscinia-Thrall");
		isboxer.AddMember("Tydeüs-Thrall");
		isboxer.SetMaster("Luscinia-Thrall");
		return
	end
end
isboxer.Character.LoadBinds = isboxer.Character_LoadBinds;

isboxer.Output("Character 'Luscinia-Thrall' activated");
