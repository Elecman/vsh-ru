/// defines
/// defines
#define CBSModel		"models/player/new_saxton_hale/hunter/hunter_v1.mdl"
// #define CBSModelPrefix		"models/player/new_saxton_hale/hunter/hunter_v1"

/// Christian Brutal Sniper voicelines
#define CBS0			"vo/sniper_specialweapon08.mp3"
#define CBS1			"vo/taunts/sniper_taunts02.mp3"
#define CBS2			"vo/sniper_award"
#define CBS3			"vo/sniper_battlecry03.mp3"
#define CBS4			"vo/sniper_domination"
#define CBSJump1		"vo/sniper_specialcompleted02.mp3"

#define CBSRAGEDIST		700.0
#define CBS_MAX_ARROWS		12

#define CBSTheme "imperia_music/cbs_bgm1941.mp3"
#define CBSTheme2 "imperia_music/cbs_bgm1941.mp3"

//char snd[PLATFORM_MAX_PATH];



methodmap CChristian < BaseBoss {
	public CChristian(const int ind, bool uid=false) {
		return view_as<CChristian>( BaseBoss(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		this.PlayVoiceClip(CBS0, VSH2_VOICE_INTRO);
	}
	public void PlayBgm(int client)
	{
		strcopy(snd, PLATFORM_MAX_PATH, CBSTheme);
		EmitSoundToClient(client, snd);
	}
	public void PlayBgm2(int client)
	{
		strcopy(snd, PLATFORM_MAX_PATH, CBSTheme2);
		EmitSoundToClient(client, snd);
	}
	
	public void Think()
	{
		if( !IsPlayerAlive(this.index) )
			return;
		
		this.SpeedThink(HALESPEED);
		this.GlowThink(0.1);
		
		if( this.SuperJumpThink(2.5, HALE_JUMPCHARGE) ) {
			this.SuperJump(this.flCharge, -130.0);
			this.PlayVoiceClip(CBSJump1, VSH2_VOICE_ABILITY);
		}
		
		if( OnlyScoutsLeft(VSH2Team_Red) )
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		
		this.WeighDownThink(HALE_WEIGHDOWN_TIME);
		
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		if( this.flRAGE >= 100.0 )
			ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Прыжок: %i%% | Ярость: НАКОПЛЕНА - Позовите Медика (клавиша: E) для активации", this.bSuperCharge ? 1000 : RoundFloat(jmp) * 4);
		else ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Прыжок: %i%% | Ярость: %0.1f", this.bSuperCharge ? 1000 : RoundFloat(jmp) * 4, this.flRAGE);
	}
	public void SetModel() {
		SetVariantString(CBSModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		// char ded_snd[PLATFORM_MAX_PATH];
		//EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC);
	}
	
	public void Equip() {
		this.SetName("Святой Охотник");
		this.RemoveAllItems();
		char attribs[128];
		Format(attribs, sizeof(attribs), "2; 3.1; 259; 1.0; 252; 0.50; 737 ; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_club", 423, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility() {
		TF2_AddCondition(this.index, view_as<TFCond>(42), 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel();
		}
		this.DoGenericStun(CBSRAGEDIST);
		this.PlayVoiceClip(GetRandomInt(0, 1) ? CBS1 : CBS3, VSH2_VOICE_RAGE);
		
		TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Primary);
		int bow = this.SpawnWeapon("tf_weapon_compound_bow", 1005, 100, 5, "2; 1.8; 6; 0.7; 37; 0.0; 137; 1.15; 103 ; 1.50; 280; 19; 551 ; 1");
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", bow); /// 266; 1.0 - penetration
		
		int living = GetLivingPlayers(VSH2Team_Red);
		SetWeaponAmmo(bow, ((living >= CBS_MAX_ARROWS) ? CBS_MAX_ARROWS : living));
	}
	
	public void KilledPlayer(const BaseBoss victim, Event event)
	{
		int living = GetLivingPlayers(VSH2Team_Red);
		if( !GetRandomInt(0, 3) && living != 1 ) {
			switch( TF2_GetPlayerClass(victim.index) ) {
				case TFClass_Spy: {
					this.PlayVoiceClip("vo/sniper_dominationspy04.mp3", VSH2_VOICE_SPREE);
				}
			}
		}
		int weapon = GetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon");
		if( weapon == GetPlayerWeaponSlot(this.index, TFWeaponSlot_Melee) ) {
			TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Melee);
			int clubindex;
			switch( GetRandomInt(0, 2) ) {
				case 0: clubindex = 1071; 
				case 1: clubindex = 423; 
				case 2: clubindex = 30758;				
			}
			weapon = this.SpawnWeapon("tf_weapon_club", clubindex, 100, 5, "2; 3.1; 259; 1.0; 252; 0.50; 737 ; 1.0");
			
			SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", weapon);
		}

		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if( this.iKills == 3 && living != 1 ) {
			char spree_snd[PLATFORM_MAX_PATH];
			if( !GetRandomInt(0, 3) )
				Format(spree_snd, PLATFORM_MAX_PATH, CBS0);
			else if( !GetRandomInt(0, 3) )
				Format(spree_snd, PLATFORM_MAX_PATH, CBS1);
			else Format(spree_snd, PLATFORM_MAX_PATH, "%s%02i.mp3", CBS2, GetRandomInt(1, 9));
			this.PlayVoiceClip(spree_snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Бpyтaльный Cнaйпep:\nСупер Прыжок: cмoтpитe ввepx c зaжaтым ПКМ (зaтeм oтпycтитe).\nЯpocть (Oxoтник): дaёт вaм лyк и 9 cтpeл.\nOчeнь мaлeнький paдиyc oглyшeния.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("3aкpыть");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
	public void LastPlayerSoundClip() {
		char lastguy_snd[PLATFORM_MAX_PATH];
		if( !GetRandomInt(0, 2) )
			Format(lastguy_snd, PLATFORM_MAX_PATH, "%s", CBS0);
		else Format(lastguy_snd, PLATFORM_MAX_PATH, "%s%i.mp3", CBS4, GetRandomInt(1, 25));
		this.PlayVoiceClip(lastguy_snd, VSH2_VOICE_LASTGUY);
	}
};

public CChristian ToCChristian (const BaseBoss guy)
{
	return view_as<CChristian>(guy);
}

public void AddCBSToDownloads()
{
	PrepareModel(CBSModel);
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/bod_v1");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/bod_normal_v1");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/boroda_v1");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/boroda_normal_v1");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/eyeball_invun");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/eyeball_l");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/eyeball_r");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/hat_v1");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/hunter_v1");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/hunter_head_v1");
	PrepareMaterial("materials/models/player/new_saxton_hale/hunter/hunter_normal_v1");

	
	PrecacheSound(CBS0, true);
	PrecacheSound(CBS1, true);
	PrecacheSound(CBS3, true);
	PrecacheSound(CBSJump1, true);
	PrepareSound(CBSTheme);
	PrecacheSound(CBSTheme);
	PrepareSound(CBSTheme2);
	PrecacheSound(CBSTheme2);
	
	for( int i=1; i <= 25; i++ ) {
		char s[PLATFORM_MAX_PATH];
		if( i <= 9 ) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", CBS2, i);
			PrecacheSound(s, true);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", CBS4, i);
		PrecacheSound(s, true);
	}
	PrecacheSound("vo/sniper_dominationspy04.mp3", true);
}

public void AddCBSToMenu(Menu& menu)
{
	char bossid[5]; IntToString(VSH2Boss_CBS, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Святой Охотник.");
}
