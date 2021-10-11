/// defines
/// models
#define BunnyModel		"models/player/new_saxton_hale/rebunny/rebunny2optimazed.mdl"
// #define BunnyModelPrefix	"models/player/new_saxton_hale/rebunny/rebunny2optimazed"

#define EggModel		"models/player/saxton_hale/w_easteregg.mdl"
// #define EggModelPrefix		"models/player/saxton_hale/w_easteregg"
//#define ReloadEggModel	"models/player/saxton_hale/c_easter_cannonball.mdl"
//#define ReloadEggModelPrefix	"models/player/saxton_hale/c_easter_cannonball"
#define BUNNYAGEDIST 700.0	

/// materials
static const char BunnyMaterials[][] = {
	"materials/models/player/new_saxton_hale/rebunny/dec16_handy_canes_color",
	"materials/models/player/new_saxton_hale/rebunny/devil",
	"materials/models/player/new_saxton_hale/rebunny/devil_normal",
	"materials/models/player/new_saxton_hale/rebunny/hwn2020_handsome_devil_color",
    "materials/models/player/new_saxton_hale/rebunny/konveta",
	"materials/models/player/new_saxton_hale/rebunny/rebunny",
	"materials/models/player/new_saxton_hale/rebunny/rebunny_normal",
};

/// Easter Bunny voicelines
char BunnyWin[][] = {
	"vo/demoman_gibberish01.mp3",
	"vo/demoman_gibberish12.mp3",
	"vo/demoman_cheers02.mp3",
	"vo/demoman_cheers03.mp3",
	"vo/demoman_cheers06.mp3",
	"vo/demoman_cheers07.mp3",
	"vo/demoman_cheers08.mp3",
	"vo/taunts/demoman_taunts12.mp3"
};

char BunnyJump[][] = {
	"vo/demoman_gibberish07.mp3",
	"vo/demoman_gibberish08.mp3",
	"vo/demoman_laughshort01.mp3",
	"vo/demoman_positivevocalization04.mp3"
};

char BunnyRage[][] = {
	"vo/demoman_positivevocalization03.mp3",
	"vo/demoman_dominationscout05.mp3",
	"vo/demoman_cheers02.mp3"
};

char BunnyFail[][] = {
	"vo/demoman_gibberish04.mp3",
	"vo/demoman_gibberish10.mp3",
	"vo/demoman_jeers03.mp3",
	"vo/demoman_jeers06.mp3",
	"vo/demoman_jeers07.mp3",
	"vo/demoman_jeers08.mp3"
};

char BunnyKill[][] = {
	"vo/demoman_gibberish09.mp3",
	"vo/demoman_cheers02.mp3",
	"vo/demoman_cheers07.mp3",
	"vo/demoman_positivevocalization03.mp3"
};

char BunnySpree[][] = {
	"vo/demoman_gibberish05.mp3",
	"vo/demoman_gibberish06.mp3",
	"vo/demoman_gibberish09.mp3",
	"vo/demoman_gibberish11.mp3",
	"vo/demoman_gibberish13.mp3",
	"vo/demoman_autodejectedtie01.mp3"
};

char BunnyLast[][] = {
	"vo/taunts/demoman_taunts05.mp3",
	"vo/taunts/demoman_taunts04.mp3",
	"vo/demoman_specialcompleted07.mp3"
};

char BunnyPain[][] = {
	"vo/demoman_sf12_badmagic01.mp3",
	"vo/demoman_sf12_badmagic07.mp3",
	"vo/demoman_sf12_badmagic10.mp3"
};

char BunnyStart[][] = {
	"vo/demoman_gibberish03.mp3",
	"vo/demoman_gibberish11.mp3"
};

char BunnyRandomVoice[][] = {
	"vo/demoman_positivevocalization03.mp3",
	"vo/demoman_jeers08.mp3",
	"vo/demoman_gibberish03.mp3",
	"vo/demoman_cheers07.mp3",
	"vo/demoman_sf12_badmagic01.mp3",
	"vo/burp02.mp3",
	"vo/burp03.mp3",
	"vo/burp04.mp3",
	"vo/burp05.mp3",
	"vo/burp06.mp3",
	"vo/burp07.mp3"
};

#define EasterBunnyTheme "imperia_music/easterbunny_bgm194.mp3"
#define EasterBunnyTheme2 "imperia_music/easterbunny_bgm194.mp3"

//char snd[PLATFORM_MAX_PATH];

methodmap CBunny < BaseBoss {
	public CBunny(const int ind, bool uid=false) {
		return view_as<CBunny>( BaseBoss(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		char spawn_snd[PLATFORM_MAX_PATH];
		strcopy(spawn_snd, PLATFORM_MAX_PATH, BunnyStart[GetRandomInt(0, sizeof(BunnyStart)-1)]);
		this.PlayVoiceClip(spawn_snd, VSH2_VOICE_INTRO);
	}
	public void PlayBgm(int client)
	{
		strcopy(snd, PLATFORM_MAX_PATH, EasterBunnyTheme);
		EmitSoundToClient(client, snd);
	}
	public void PlayBgm2(int client)
	{
		strcopy(snd, PLATFORM_MAX_PATH, EasterBunnyTheme2);
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
			char jump_snd[PLATFORM_MAX_PATH];
			strcopy(jump_snd, PLATFORM_MAX_PATH, BunnyJump[GetRandomInt(0, sizeof(BunnyJump)-1)]);
			this.PlayVoiceClip(jump_snd, VSH2_VOICE_ABILITY);
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
		SetVariantString(BunnyModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		char death_snd[PLATFORM_MAX_PATH];
		strcopy(death_snd, PLATFORM_MAX_PATH, BunnyFail[GetRandomInt(0, sizeof(BunnyFail)-1)]);
		this.PlayVoiceClip(death_snd, VSH2_VOICE_LOSE);
		SpawnManyAmmoPacks(this.index, EggModel, 1);
	}
	
	public void Equip() {
		this.SetName("Дух Пасхи");
		this.RemoveAllItems();
		char attribs[128];
		Format(attribs, sizeof(attribs), "2; 3.0; 259; 1.0; 350 ; 1.0; 326; 1.2; 252 ; 0.50; 1006 ; 1.0; 613; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_bottle", 609, 100, 5, attribs);
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
		
		TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Primary);
		int weapon = this.SpawnWeapon("tf_weapon_cannon", 996, 100, 5, "2; 1.70; 2053 ; 1.0; 6; 0.10; 411; 150.0; 413; 1.0; 137; 1.48; 37; 0.0; 280; 17; 477; 1.0; 467; 1.0; 181; 2.0; 1007 ; 1.0");
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", weapon);
		SetEntProp(weapon, Prop_Send, "m_iClip1", 70);
		SetWeaponAmmo(weapon, 0);
		
		this.DoGenericStun(VAGRAGEDIST);
		char rage_snd[PLATFORM_MAX_PATH];
		strcopy(rage_snd, PLATFORM_MAX_PATH, BunnyRage[GetRandomInt(1, sizeof(BunnyRage)-1)]);
		this.PlayVoiceClip(rage_snd, VSH2_VOICE_RAGE);
	}
	
	public void KilledPlayer(const BaseBoss victim, Event event) {
		if( GetRandomInt(0, 3) ) {
			char kill_snd[PLATFORM_MAX_PATH];
			strcopy(kill_snd, PLATFORM_MAX_PATH, BunnyKill[GetRandomInt(0, sizeof(BunnyKill)-1)]);
			this.PlayVoiceClip(kill_snd, VSH2_VOICE_SPREE);
		}
		SpawnManyAmmoPacks(victim.index, EggModel, 1);
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if( this.iKills == 3 && GetLivingPlayers(VSH2Team_Red) != 1 ) {
			char spree_snd[PLATFORM_MAX_PATH];
			strcopy(spree_snd, PLATFORM_MAX_PATH, BunnySpree[GetRandomInt(0, sizeof(BunnySpree)-1)]);
			this.PlayVoiceClip(spree_snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	
	public void Stabbed() {
		char stab_snd[PLATFORM_MAX_PATH];
		strcopy(stab_snd, PLATFORM_MAX_PATH, BunnyPain[GetRandomInt(0, sizeof(BunnyPain)-1)]);
		this.PlayVoiceClip(stab_snd, VSH2_VOICE_STABBED);
	}
	
	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Пacxaльный Kpoлик:\nСупер Прыжок: cмoтpитe ввepx c зaжaтым ПКМ (зaтeм oтпycтитe).\nЯpocть (Пacxaльныe Яйцa): нaнocят ypoн игpoкaм в бoльшoм paдиyce.\nOглyшaeт игpoкoв.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("3aкpыть");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
	public void LastPlayerSoundClip() {
		char lastguy_snd[PLATFORM_MAX_PATH];
		strcopy(lastguy_snd, PLATFORM_MAX_PATH, BunnyLast[GetRandomInt(0, sizeof(BunnyLast)-1)]);
		this.PlayVoiceClip(lastguy_snd, VSH2_VOICE_LASTGUY);
	}
	public void PlayWinSound() {
		char victory[PLATFORM_MAX_PATH];
		strcopy(victory, PLATFORM_MAX_PATH, BunnyWin[GetRandomInt(0, sizeof(BunnyWin)-1)]);
		this.PlayVoiceClip(victory, VSH2_VOICE_WIN);
	}
};

public CBunny ToCBunny (const BaseBoss guy)
{
	return view_as<CBunny>(guy);
}

public void AddBunnyToDownloads()
{
	PrepareModel(BunnyModel);
	PrepareModel(EggModel);
	
	PrepareSound(EasterBunnyTheme);
	PrecacheSound(EasterBunnyTheme);
	PrepareSound(EasterBunnyTheme2);
	PrecacheSound(EasterBunnyTheme2);
	
	DownloadMaterialList(BunnyMaterials, sizeof(BunnyMaterials));
	PrepareMaterial("materials/models/props_easteregg/c_easteregg");
	CheckDownload("materials/models/props_easteregg/c_easteregg_gold.vmt");
	
	PrecacheSoundList(BunnyWin, sizeof(BunnyWin));
	PrecacheSoundList(BunnyJump, sizeof(BunnyJump));
	PrecacheSoundList(BunnyRage, sizeof(BunnyRage));
	PrecacheSoundList(BunnyFail, sizeof(BunnyFail));
	PrecacheSoundList(BunnyKill, sizeof(BunnyKill));
	PrecacheSoundList(BunnySpree, sizeof(BunnySpree));
	PrecacheSoundList(BunnyLast, sizeof(BunnyLast));
	PrecacheSoundList(BunnyPain, sizeof(BunnyPain));
	PrecacheSoundList(BunnyStart, sizeof(BunnyStart));
	PrecacheSoundList(BunnyRandomVoice, sizeof(BunnyRandomVoice));
}

public void AddBunnyToMenu(Menu& menu)
{
	char bossid[5]; IntToString(VSH2Boss_Bunny, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Дух Пасхи");
}

stock void SpawnManyAmmoPacks(const int client, const char[] model, int skin=0, int num=14, float offsz = 30.0)
{
	float pos[3], vel[3], ang[3];
	ang[0] = 90.0;
	ang[1] = 0.0;
	ang[2] = 0.0;
	GetClientAbsOrigin(client, pos);
	pos[2] += offsz;
	for( int i=0; i<num; i++ ) {
		vel[0] = GetRandomFloat(-400.0, 400.0);
		vel[1] = GetRandomFloat(-400.0, 400.0);
		vel[2] = GetRandomFloat(300.0, 500.0);
		pos[0] += GetRandomFloat(-5.0, 5.0);
		pos[1] += GetRandomFloat(-5.0, 5.0);
		int ent = CreateEntityByName("tf_ammo_pack");
		if( !IsValidEntity(ent) )
			continue;
		SetEntityModel(ent, model);
		DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); /// for safety, but it shouldn't act like a normal ammopack
		SetEntProp(ent, Prop_Send, "m_nSkin", skin);
		SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
		SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(ent, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(ent, Prop_Send, "m_iTeamNum", VSH2Team_Red);
		TeleportEntity(ent, pos, ang, vel);
		DispatchSpawn(ent);
		TeleportEntity(ent, pos, ang, vel);
		SetEntProp(ent, Prop_Data, "m_iHealth", 900);
		int offs = GetEntSendPropOffs(ent, "m_vecInitialVelocity", true);
		SetEntData(ent, offs-4, 1, _, true);
	}
}

public Action Timer_SetEggBomb(Handle timer, any ref)
{
	int entity = EntRefToEntIndex(ref);
	if( FileExists(EggModel, true) && IsModelPrecached(EggModel) && IsValidEntity(entity) ) {
		int att = AttachProjectileModel(entity, EggModel);
		SetEntProp(att, Prop_Send, "m_nSkin", 0);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 255, 255, 255, 0);
	}
	return Plugin_Continue;
}
