
/// defines
/*
#define VagineerModel		"models/player/new_saxton_hale/bionic/bionicv.mdl"
#define VagineerModelPrefix	"models/player/new_saxton_hale/bionic/bionicv"
*/

#define VagineerModel		"models/player/new_saxton_hale/bionic/bionicv.mdl"
// #define VagineerModelPrefix	"models/player/new_saxton_hale/bionic/bionicv"


/// Vagineer voicelines
#define VagineerLastA		"saxton_hale/shock_lasta.wav"
#define VagineerRageSound	"saxton_hale/shock_rage2.wav"
#define VagineerStart		"saxton_hale/shock_startt.wav"
#define VagineerKSpree		"saxton_hale/shock_kspreenew.wav"
#define VagineerKSpree2		"saxton_hale/shock_kspreenew.wav"
#define VagineerHit			"saxton_hale/shock_hit.wav"
#define VagineerRoundStart	"saxton_hale/shock_start.wav"
#define VagineerJump		"saxton_hale/shock_jump_"		/// 1-2
#define VagineerRageSound2	"saxton_hale/shock_ragesound_"		/// 1-2
#define VagineerKSpreeNew	"saxton_hale/shock_kspreeneww_"		/// 1-5
#define VagineerFail		"saxton_hale/shock_fail_"		/// 1-2

#define VAGRAGEDIST     700.0

#define VagineerTheme "imperia_music/vagineer_bgm2922.mp3"

//char snd[PLATFORM_MAX_PATH];


methodmap CVagineer < BaseBoss {
	public CVagineer(const int ind, bool uid=false) {
		return view_as<CVagineer>( BaseBoss(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		char start_snd[PLATFORM_MAX_PATH];
		if( !GetRandomInt(0, 1) )
			strcopy(start_snd, PLATFORM_MAX_PATH, VagineerStart);
		else strcopy(start_snd, PLATFORM_MAX_PATH, VagineerRoundStart);
		this.PlayVoiceClip(start_snd, VSH2_VOICE_INTRO);
	}
	
	public void PlayBgm(int client)
	{
		strcopy(snd, PLATFORM_MAX_PATH, VagineerTheme);
		EmitSoundToClient(client, snd);
		//CPrintToChat(client, "{olive}[VSH REX]{default} Сейчас играет: {lightblue}Anonymous {default}- {orange}Hacker SoundTrack{default}");
	}
	
	public void Think()
	{
		if( !IsPlayerAlive(this.index) )
			return;
		
		this.SpeedThink(HALESPEED);
		this.GlowThink(0.1);
		
		if( this.SuperJumpThink(2.5, HALE_JUMPCHARGE) ) {
			this.SuperJump(this.flCharge, -130.0);
			
			char gottam_snd[PLATFORM_MAX_PATH];
			Format(gottam_snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
			this.PlayVoiceClip(gottam_snd, VSH2_VOICE_ABILITY);
		}
		
		if( OnlyScoutsLeft(VSH2Team_Red) )
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		
		this.WeighDownThink(HALE_WEIGHDOWN_TIME);
		
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		if( this.flRAGE >= 100.0 )
			ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Прыжок: %i%% | Ярость: НАКОПЛЕНА - Позовите Медика (клавиша: E) для активации", this.bSuperCharge ? 1000 : RoundFloat(jmp) * 4);
		else ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Прыжок: %i%% | Ярость: %0.1f", this.bSuperCharge ? 1000 : RoundFloat(jmp) * 4, this.flRAGE);
		
		if( TF2_IsPlayerInCondition(this.index, TFCond_Ubercharged) )
			SetEntProp(this.index, Prop_Data, "m_takedamage", 0);
		else SetEntProp(this.index, Prop_Data, "m_takedamage", 2);
	}
	
	public void SetModel() {
		SetVariantString(VagineerModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		char ded_snd[PLATFORM_MAX_PATH];
		Format(ded_snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
		this.PlayVoiceClip(ded_snd, VSH2_VOICE_LOSE);
	}
	
	public void Equip() {
		this.SetName("Био Шок");
		this.RemoveAllItems();
		char attribs[128];
		
		Format(attribs, sizeof(attribs), "2 ; 3.1; 259 ; 1.0; 252; 0.50; 137 ; 1.48; 436; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_robot_arm", 142, 100, 5, attribs);
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
		TF2_AddCondition(this.index, TFCond_Ubercharged, g_vsh2.m_hCvars.VagineerUberTime.FloatValue);
		this.DoGenericStun(VAGRAGEDIST);
		char rage_snd[PLATFORM_MAX_PATH];
		if( GetRandomInt(0, 2) )
			strcopy(rage_snd, PLATFORM_MAX_PATH, VagineerRageSound);
		else Format(rage_snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));
		this.PlayVoiceClip(rage_snd, VSH2_VOICE_RAGE);
	}
	
	public void KilledPlayer(const BaseBoss victim, Event event) {
		char wrench_hit_snd[PLATFORM_MAX_PATH];
		strcopy(wrench_hit_snd, PLATFORM_MAX_PATH, VagineerHit);
		this.PlayVoiceClip(wrench_hit_snd, VSH2_VOICE_SPREE);
		
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if( this.iKills == 3 && GetLivingPlayers(VSH2Team_Red) != 1 ) {
			char spree_snd[PLATFORM_MAX_PATH];
			switch( GetRandomInt(0, 4) ) {
				case 1, 3: strcopy(spree_snd, PLATFORM_MAX_PATH, VagineerKSpree);
				case 2: strcopy(spree_snd, PLATFORM_MAX_PATH, VagineerKSpree2);
				default: Format(spree_snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
			}
			this.PlayVoiceClip(spree_snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	
	public void Stabbed() {
		this.PlayVoiceClip("vo/engineer_positivevocalization01.mp3", VSH2_VOICE_STABBED);
	}
	
	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Опасность:\nСупер Прыжок: cмoтpитe ввepx c зaжaтым ПКМ (зaтeм oтпycтитe).\nЯpocть (Убep): oглушaeт игpoкoв вoкpуг вac, a тaк жe дaёт вaм Убep.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("3aкpыть");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
	public void LastPlayerSoundClip() {
		char lastguy_snd[PLATFORM_MAX_PATH];
		strcopy(lastguy_snd, PLATFORM_MAX_PATH, VagineerLastA);
		this.PlayVoiceClip(lastguy_snd, VSH2_VOICE_LASTGUY);
	}
	public void PlayWinSound() {
		char victory[PLATFORM_MAX_PATH];
		Format(victory, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
		this.PlayVoiceClip(victory, VSH2_VOICE_WIN);
	}
};

public CVagineer ToCVagineer (const BaseBoss guy)
{
	return view_as<CVagineer>(guy);
}

public void AddVagToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	int i;
	
	PrepareModel(VagineerModel);
	
	PrepareSound(VagineerLastA);
	PrepareSound(VagineerStart);
	PrepareSound(VagineerRageSound);
	PrepareSound(VagineerKSpree);
	PrepareSound(VagineerKSpree2);
	PrepareSound(VagineerHit);
	PrepareSound(VagineerRoundStart);
	
	PrepareSound(VagineerTheme);
	PrecacheSound(VagineerTheme);
	
	for( i=1; i <= 5; i++ ) {
		if( i <= 2 ) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, i);
			PrepareSound(s);
			
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, i);
			PrepareSound(s);
			
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, i);
			PrepareSound(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, i);
		PrepareSound(s);
	}
	
	PrecacheSound("vo/engineer_positivevocalization01.mp3", true);
}

public void AddVagToMenu(Menu& menu)
{
	char bossid[5]; IntToString(VSH2Boss_Vagineer, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Био Шок.");
}
