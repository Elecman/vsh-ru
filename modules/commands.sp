public void SkipBossPanelNotify(const int client/*, bool newchoice = true*/)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsValidClient(client) || IsFakeClient(client) || IsVoteInProgress() )
		return;
	
	Panel panel = new Panel();
	char strNotify[256];
	
	panel.SetTitle("[VSH2] Вы следующий босс!");
	Format(strNotify, sizeof(strNotify), "Вы скоро станете боссом! Напишите /halenext чтоб проверить/обнулить ваши очки очереди.");

	panel.DrawItem(strNotify);
	panel.Send(client, SkipHalePanelH, 30); /// in commands.sp
	delete panel;
}

public Action QueuePanelCmd(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Вы можете использовать эту команду только в игре.");
		return Plugin_Handled;
	}
	QueuePanel(client);
	return Plugin_Handled;
}

public Action ResetQueue(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Вы можете использовать эту команду только в игре.");
		return Plugin_Handled;
	}
	BaseBoss(client).iQueue = 0;
	CPrintToChat(client, "{olive}[VSH 2]{default} Ваши очки очереди были изменены на 0!");
	return Plugin_Handled;
}


public void QueuePanel(const int client)
{
	Panel panel = new Panel();
	char strBossList[MAXMESSAGE];
	Format(strBossList, MAXMESSAGE, "VSH2 Boss Queue:");
	panel.SetTitle(strBossList);
	
	BaseBoss Boss = VSHGameMode.GetRandomBoss(false);
	if( Boss ) {
		Format(strBossList, sizeof(strBossList), "%N - %i", Boss.index, Boss.iQueue);
		panel.DrawItem(strBossList);
	}
	else panel.DrawItem("None");
	
	BaseBoss[] b = new BaseBoss[MaxClients];
	VSHGameMode.GetQueue(b);
	for( int i; i<8; ++i ) {
		if( b[i] ) {
			Format(strBossList, 128, "%N - %i", b[i].index, b[i].iQueue);
			panel.DrawItem(strBossList);
		}
		else panel.DrawItem("-");
	}
	
	Format(strBossList, 64, "Ваши очки очереди: %i (0 - обнулить)", BaseBoss(client).iQueue );
	panel.DrawItem(strBossList);
	panel.Send(client, QueuePanelH, 9001);
	delete panel;
}
public int QueuePanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if( action==MenuAction_Select && param2==10 )
		TurnToZeroPanel(param1);
	return false;
}
public void TurnToZeroPanel(const int client)
{
	Panel panel = new Panel();
	char strPanel[128];
	//SetGlobalTransTarget(client);
	Format(strPanel, 128, "Вы уверены, что хотите обнулить очки очереди до 0?");
	panel.SetTitle(strPanel);
	Format(strPanel, 128, "Да");
	panel.DrawItem(strPanel);
	Format(strPanel, 128, "Нет");
	panel.DrawItem(strPanel);
	panel.Send(client, TurnToZeroPanelH, 9001);
	delete panel;
}
public int TurnToZeroPanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if( action==MenuAction_Select && param2==1 ) {
		BaseBoss player = BaseBoss(param1);
		if( player.iQueue ) {
			player.iQueue = 0;
			CPrintToChat(param1, "{olive}[VSH 2]{default} Вы обнулили очки очереди до {olive}0{default}");
			BaseBoss next = VSHGameMode.FindNextBoss();
			if( next )
				SkipBossPanelNotify(next.index);
		}
	}
}

/** FINALLY THE PANEL TRAIN HAS ENDED! */
public int SkipHalePanelH(Menu menu, MenuAction action, int client, int param2)
{
	/*
	if( IsValidAdmin(client, "b") )
		SetBossMenu(client, -1);
	else CommandSetSkill(client, -1);
	*/
}

public Action SetNextSpecial(int client, int args)
{
	if( g_vsh2.m_hCvars.Enabled.BoolValue ) {
		Menu bossmenu = new Menu(MenuHandler_PickBossSpecial);
		bossmenu.SetTitle("Меню Боссов: ");
		bossmenu.AddItem("-1", "Не выбран (Случайный Босс)");
		ManageMenu(bossmenu, client); /// in handler.sp
		bossmenu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public int MenuHandler_PickBossSpecial(Menu menu, MenuAction action, int client, int select)
{
	char bossname[MAX_BOSS_NAME_SIZE];
	char info1[16]; menu.GetItem(select, info1, sizeof(info1), _, bossname, sizeof(bossname));
	if( action == MenuAction_Select ) {
		g_vsh2.m_hGamemode.iSpecial = StringToInt(info1);
		CPrintToChat(client, "{olive}[VSH 2]{default} Следующий босс будет {olive}%s{default}!", bossname);
	} else if( action == MenuAction_End )
		delete menu;
}


public Action ChangeHealthBarColor(int client, int args)
{
	if( g_vsh2.m_hCvars.Enabled.BoolValue ) {
		char number[4]; GetCmdArg( 1, number, sizeof(number) );
		int type = StringToInt(number);
		g_vsh2.m_hGamemode.iHealthBar.iState = type;
		PrintToChat(client, "iHealthBar.iState = %i", g_vsh2.m_hGamemode.iHealthBar.iState);
	}
	return Plugin_Handled;
}

public Action Command_GetHPCmd(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	else if( g_vsh2.m_hGamemode.iRoundState != StateRunning )
		return Plugin_Handled;
	
	BaseBoss player = BaseBoss(client);
	ManageBossCheckHealth(player);    /// in handler.sp
	return Plugin_Handled;
}
public Action CommandBossSelect(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	else if( args < 1 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: boss_select <target>");
		return Plugin_Handled;
	}
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	if( !strcmp(targetname, "@me", false) && IsValidClient(client) ) {
		g_vsh2.m_hGamemode.hNextBoss = BaseBoss(client);
		CReplyToCommand(client, "{olive}[VSH 2]{default} Вы поставили себе следующего босса!");
	} else {
		int target = FindTarget(client, targetname);
		if( IsValidClient(target) ) {
			g_vsh2.m_hGamemode.hNextBoss = BaseBoss(target);
			CReplyToCommand(client, "{olive}[VSH 2]{default} %N назначен следующим Боссом!", g_vsh2.m_hGamemode.hNextBoss.index);
		}
		else g_vsh2.m_hGamemode.hNextBoss = view_as< BaseBoss >(0);
	}
	return Plugin_Handled;
}
public Action SetBossMenu(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	
	Menu bossmenu = new Menu(MenuHandler_PickBosses);
	bossmenu.SetTitle("Меню Боссов: ");
	bossmenu.AddItem("-1", "Не выбран (Случайный Босс)");
	ManageMenu(bossmenu, client); /// in handler.sp
	bossmenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuHandler_PickBosses(Menu menu, MenuAction action, int client, int select)
{
	char bossname[MAX_BOSS_NAME_SIZE];
	char info1[16]; menu.GetItem(select, info1, sizeof(info1), _, bossname, sizeof(bossname));
	if( action == MenuAction_Select ) {
		BaseBoss player = BaseBoss(client);
		player.iPresetType = StringToInt(info1);
		CPrintToChat(client, "{olive}[VSH 2]{default} Ваш Босс изменён на {olive}%s{default}!", bossname);
	} else if( action == MenuAction_End )
		delete menu;
}

public Action MusicTogglePanelCmd(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	MusicTogglePanel(client);
	return Plugin_Handled;
}
public void MusicTogglePanel(const int client)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsValidClient(client) )
		return;
	Panel panel = new Panel();
	panel.SetTitle("VSH2 Музыка");
	panel.DrawItem("Вкл?");
	panel.DrawItem("Выкл?");
	panel.Send(client, MusicTogglePanelH, 9001);
	delete panel;
}
public int MusicTogglePanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if( IsValidClient(param1) ) {
		if( action == MenuAction_Select ) {
			BaseBoss player = BaseBoss(param1);
			if( param2 == 1 ) {
				player.bNoMusic = false;
				CPrintToChat(param1, "{olive}[VSH 2]{default} Вы включили VSH2 музыку!");
			} else {
				player.bNoMusic = true;
				CPrintToChat(param1, "{olive}[VSH 2]{default} Вы выключили VSH2 музыку!");
				BaseBoss(param1).StopMusic();
			}
		}
	}
}

public Action ForceBossRealtime(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	
	if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Вы можете использовать эту команду только в игре.");
		return Plugin_Handled;
	} else if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: boss_force <target> <boss id>");
		return Plugin_Handled;
	} else if( g_vsh2.m_hGamemode.iRoundState > StateStarting ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can't force a boss after a round started...");
		return Plugin_Handled;
	}
	
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	char strBossid[32];  GetCmdArg(2, strBossid, sizeof(strBossid));
	
	int bosstype = StringToInt(strBossid);
	if( bosstype > MAXBOSS )
		bosstype = MAXBOSS;
	else if( bosstype < 0 )
		bosstype = GetRandomInt(VSH2Boss_Hale, MAXBOSS);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if( (target_count = ProcessTargetString(
		targetname,
		client,
		target_list,
		MAXPLAYERS,
		0,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	BaseBoss player;
	for( int i=0; i<target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			player = BaseBoss(target_list[i]);
			player.MakeBossAndSwitch(bosstype, true);
			CPrintToChat(player.index, "{olive}[VSH 2]{orange} an Admin has forced you to be a Boss!");
		}
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} Forced %s as a Boss", target_name);
	return Plugin_Handled;
}

public Action CommandAddPoints(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	
	if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: hale_addpoints <target> <points>");
		return Plugin_Handled;
	}
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	char s2[32];         GetCmdArg(2, s2, sizeof(s2));
	
	int points = StringToInt(s2);
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if( (target_count = ProcessTargetString(
		targetname,
		client,
		target_list,
		MAXPLAYERS,
		0,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	BaseBoss player;
	for( int i=0; i<target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			player = BaseBoss(target_list[i]);
			player.iQueue += points;
			LogAction(client, target_list[i], "\"%L\" Добавлены %d VSH2 очки очереди to \"%L\"", client, points, target_list[i]);
		}
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} Добавлены %d очки очереди to %s", points, target_name);
	return Plugin_Handled;
}

public Action CommandSetPoints(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	
	if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: hale_setpoints <target> <points>");
		return Plugin_Handled;
	}
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	char s2[32]; GetCmdArg(2, s2, sizeof(s2));
	int points = StringToInt(s2);
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if( (target_count = ProcessTargetString( targetname, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml)) <= 0 ) {
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	BaseBoss player;
	for( int i=0; i<target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			player = BaseBoss(target_list[i]);
			player.iQueue = points;
			LogAction(client, target_list[i], "\"%L\" set %d VSH2 queue points to \"%L\"", client, points, target_list[i]);
		}
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}

public Action HelpPanelCmd(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Вы можете использовать эту команду только в игре.");
		return Plugin_Handled;
	}
	//char strHelp[MAXMESSAGE];
	//Format(strHelp, MAXMESSAGE, "Добро пожаловать в vsh2");
	Menu help = new Menu(HelpMenuHandler);
	help.SetTitle("VSH2 Меню");
	help.AddItem("-1", "Показать здоровье босса.");
	help.AddItem("-1", "Информация о классе.");
	help.AddItem("-1", "Следующий босс.");
	help.AddItem("-1", "Обнулить очки очереди.");
	help.AddItem("-1", "Включить/выключить фоновую музыку.");
	Call_OnHelpMenu(BaseBoss(client), help);
	help.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int HelpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if( action==MenuAction_Select ) {
		switch( param2+1 ) {
			case 1: {
				if( g_vsh2.m_hGamemode.iRoundState==StateRunning ) {
					BaseBoss player = BaseBoss(param1);
					ManageBossCheckHealth(player);
				}
				else CPrintToChat(param1, "{olive}[VSH 2]{default} Нету активных боссов...");
			}
			case 2: {
				BaseBoss player = BaseBoss(param1);
				if( player.bIsBoss )
					ManageBossHelp(player);
				else if( !player.bIsMinion && GetClientTeam(param1)==VSH2Team_Red )
					player.HelpPanelClass();
			}
			case 3: QueuePanel(param1);
			case 4: TurnToZeroPanel(param1);
			case 5: MusicTogglePanelCmd(param1, -1);
			default: Call_OnHelpMenuSelect(BaseBoss(param1), menu, param2);
		}
	} else if( action == MenuAction_End )
		delete menu;
}

public Action MenuDoClassRush(int client, int args)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	}
	
	Menu rush = new Menu(MenuHandler_ClassRush);
	rush.SetTitle("VSH2 Class Rush Menu");
	rush.AddItem("1", "**** Scout ****");
	rush.AddItem("2", "**** Sniper ****");
	rush.AddItem("3", "**** Soldier ****");
	rush.AddItem("4", "**** Demoman ****");
	rush.AddItem("5", "**** Medic ****");
	rush.AddItem("6", "**** Heavy ****");
	rush.AddItem("7", "**** Pyro ****");
	rush.AddItem("8", "**** Spy ****");
	rush.AddItem("9", "**** Engineer ****");
	//rush.ExitBackButton = true;
	rush.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler_ClassRush(Menu menu, MenuAction action, int client, int pick)
{
	char classname[64];
	char info[10]; menu.GetItem(pick, info, sizeof(info), _, classname, sizeof(classname));
	if( action == MenuAction_Select ) {
		int classtype = StringToInt(info);
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || GetClientTeam(i) != VSH2Team_Red || !IsPlayerAlive(i) )
				continue;
			SetEntProp(i, Prop_Send, "m_iClass", classtype);
			TF2_RegeneratePlayer(i);
			SetPawnTimer(PrepPlayers, 0.2, BaseBoss(i));
			CPrintToChat(i, "{olive}[VSH 2]{default} You've been forced to {orange}%s{default}.", classname);
		}
		CPrintToChat(client, "{olive}[VSH 2]{default} Forced everybody to {orange}%s{default}.", classname);
	}
	else if( action == MenuAction_End )
		delete menu;
}
