isboxer.Character.Name = "Phîlo-Thrall";
isboxer.Character.ActualName = "Phîlo";
isboxer.Character.QualifiedName = "Phîlo-Thrall";

function isboxer.Character_LoadBinds()
	if (isboxer.CharacterSet.Name=="Philo kishi Luscinia Tydeus Ubuy") then
		isboxer.SetMacro("FTLAssist","BACKSPACE","/assist [nomod:alt,mod:lshift,nomod:ctrl]Phîlo;[nomod:alt,mod:rshift,nomod:ctrl]Kishikaisei;[nomod:alt,nomod:shift,mod:lctrl]Tydeus;[mod:lalt,nomod:shift,nomod:ctrl]Luscinia;[nomod:alt,mod:lshift,mod:lctrl]Ubuy\n",1,1,1,1);

		isboxer.SetMacro("FTLFocus","NONE","/focus [nomod:alt,mod:lshift,nomod:ctrl]Phîlo;[nomod:alt,mod:rshift,nomod:ctrl]Kishikaisei;[nomod:alt,nomod:shift,mod:lctrl]Tydeus;[mod:lalt,nomod:shift,nomod:ctrl]Luscinia;[nomod:alt,mod:lshift,mod:lctrl]Ubuy\n",1,1,1,1);

		isboxer.SetMacro("FTLFollow","F11","/jamba-follow snw\n/follow [nomod:alt,mod:lshift,nomod:ctrl]Phîlo;[nomod:alt,mod:rshift,nomod:ctrl]Kishikaisei;[nomod:alt,nomod:shift,mod:lctrl]Tydeus;[mod:lalt,nomod:shift,nomod:ctrl]Luscinia;[nomod:alt,mod:lshift,mod:lctrl]Ubuy\n",1,1,1,1);

		isboxer.SetMacro("FTLTarget","]","/targetexact [nomod:alt,mod:lshift,nomod:ctrl]Phîlo;[nomod:alt,mod:rshift,nomod:ctrl]Kishikaisei;[nomod:alt,nomod:shift,mod:lctrl]Tydeus;[mod:lalt,nomod:shift,nomod:ctrl]Luscinia;[nomod:alt,mod:lshift,mod:lctrl]Ubuy\n",1,1,1,1);

		isboxer.SetMacro("InviteTeam","ALT-CTRL-SHIFT-I","/invite Kishikaisei\n/invite Tydeus\n/invite Luscinia\n/invite Ubuy\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOn","ALT-SHIFT-N","/console autointeract 1\n",nil,nil,nil,1);

		isboxer.SetMacro("CTMOff","ALT-CTRL-N","/console autointeract 0\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaMaster","CTRL-SHIFT-F12","/jamba-team iammaster all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOn","ALT-SHIFT-F12","/jamba-follow strobeonme all\n",nil,nil,nil,1);

		isboxer.SetMacro("JambaStrobeOff","ALT-CTRL-SHIFT-F12","/jamba-follow strobeoff all\n",nil,nil,nil,1);

		isboxer.SetMacro("","ALT-SHIFT-Z","/cast Crimson Water Strider\n",nil,nil,nil,1);

		isboxer.ClearMembers();
		isboxer.AddMember("Phîlo-Thrall");
		isboxer.AddMember("Kishikaisei-Thrall");
		isboxer.AddMember("Tydeus-Thrall");
		isboxer.AddMember("Luscinia-Thrall");
		isboxer.AddMember("Ubuy-Thrall");
		isboxer.SetMaster("Phîlo-Thrall");
		return
	end
end
isboxer.Character.LoadBinds = isboxer.Character_LoadBinds;

isboxer.Output("Character 'Phîlo-Thrall' activated");
