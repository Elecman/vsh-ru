#define YetiModel			"models/freak_fortress_2/yeti3/yeti.mdl"

/// Yeti voicelines
#define YetiBegin			"player/taunt_yeti_appear_snow.wav"
#define YetiWin				"player/taunt_yeti_roar_second.wav"
#define YetiRage			"player/taunt_yeti_roar_beginning.wav"


#define YetiTheme "imperia_music/yeti_bgm12.mp3"

#define YETIRAGETIME		30.0

methodmap CYeti < BaseBoss {
	public CYeti(const int ind, bool uid=false) {
		return view_as<CYeti>( BaseBoss(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		char start_snd[PLATFORM_MAX_PATH];
		Format(start_snd, PLATFORM_MAX_PATH, YetiBegin);		
		this.PlayVoiceClip(start_snd, VSH2_VOICE_INTRO);
	}
	
	public void PlayBgm(int client)
	{
		strcopy(snd, PLATFORM_MAX_PATH, YetiTheme);
		EmitSoundToClient(client, snd);
		//CPrintToChat(client, "{olive}[VSH REX]{default} Сейчас играет: {lightblue}Hoarfrost Depths {default}- {orange}Yeti Theme{default}");
	}
	
	public void Think()
	{
		if( !IsPlayerAlive(this.index) )
			return;
		
		this.SpeedThink(358.0);
		this.GlowThink(0.1);
		
		if( this.SuperJumpThink(3.5, HALE_JUMPCHARGE) ) {
			//252 ; 0
			TF2_AddCondition(this.index, TFCond_CritOnFirstBlood, 5.0);
			this.flCharge = -300.0;
		}
		
		if( OnlyScoutsLeft(VSH2Team_Red) )
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		
		this.WeighDownThink(HALE_WEIGHDOWN_TIME);
		
		int flags = GetEntityFlags(this.index);
		
		if( flags & FL_ONGROUND ) {
			this.iClimbs = 0;
			}
		
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		if( this.flRAGE >= 100.0 )
			ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Прыжок: %i%% | Ярость: НАКОПЛЕНА - Позовите Медика (клавиша: E) для активации", this.bSuperCharge ? 1000 : RoundFloat(jmp) * 4);
		else ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Прыжок: %i%% | Ярость: %0.1f", this.bSuperCharge ? 1000 : RoundFloat(jmp) * 4, this.flRAGE);
	}
	public void SetModel() {
		SetVariantString(YetiModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		char ded_snd[PLATFORM_MAX_PATH];
		Format(ded_snd, PLATFORM_MAX_PATH, YetiWin);
		this.PlayVoiceClip(ded_snd, VSH2_VOICE_LOSE);
	}
	
	public void Equip() {
		this.SetName("Снежный Человек");
		this.RemoveAllItems();
		char attribs[128];
		Format(attribs, sizeof(attribs), "2; 3.0; 259; 1.0; 252 ; 0.50; 337 ; 10; 338 ; 10; 214; %d", GetRandomInt(999, 9999));
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_fists", 5, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility() {
		TF2_AddCondition(this.index, view_as<TFCond>(42), 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel(); /// should reset Hale's animation
		}
		this.DoFreeze(HALERAGEDIST, YETIRAGETIME);
		char rage_snd[PLATFORM_MAX_PATH];
		Format(rage_snd, PLATFORM_MAX_PATH, YetiRage);
		this.PlayVoiceClip(rage_snd, VSH2_VOICE_RAGE);
	}
	public void KilledPlayer(const BaseBoss victim, Event event)
	{
	}
	
	public void Stabbed() {
	}
	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Снежный Человек:\nСупер Прыжок: Даёт криты и резист.\nЯpocть Заморозка игроков.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("3aкpыть");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
	public void LastPlayerSoundClip() {		
	}
	
	public void PlayWinSound() {
		char victory[PLATFORM_MAX_PATH];
		Format(victory, PLATFORM_MAX_PATH, YetiWin);
		this.PlayVoiceClip(victory, VSH2_VOICE_WIN);
	}
};

public CYeti ToCYeti (const BaseBoss guy)
{
	return view_as< CYeti >(guy);
}

public void AddYetiToDownloads()
{
	PrepareModel(YetiModel);
	
	PrepareSound(YetiBegin);
	PrepareSound(YetiRage);
	PrepareSound(YetiWin);	

	PrepareSound(YetiTheme);
	PrecacheSound(YetiTheme);
}

public void AddYetiToMenu(Menu& menu)
{
	char bossid[5]; IntToString(VSH2Boss_Yeti, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Снежный Человек.");
}