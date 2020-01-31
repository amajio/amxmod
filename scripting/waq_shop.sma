//////////////////////////////////////////////////
//////////////Sklep HNS by Waq 1.1////////////////
//////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>

#define PLUGIN "Sklep HNS"
#define VERSION "1.1"
#define AUTHOR "Waq"

#define Klawisze (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)

new const gszPrefixShop[] = "HNS SHOP";
//new const IP[] = "TUTAJ PODAJ SWOJE IP";

new szName[32];
new gmsgScoreInfo;
new costFragHE, costFragSB, costFragFB, costFragHP, costFragRespawn, costFragLosRespawn, costFragRandom;
new bHE, bSB, bFB, bHP, bRespawn, bLosRespawn, bRandom;
new gbHe[33], gbSmoke[33], gbFlash[33], gbHp[33], gbRespawn[33], gbLosRespawn[33], gbLotto[33];
new ileHP;
new bool:gbSpeed[33], bool:gbSpeedMin[33], bool:gbCamo[33], bool:gbInvi[33], bool:gbBigJump[33];

new SideJump[33], Float:SideJumpDelay[33]

new CTModels[] = {"urban", "gsg9","gign", "sas"}     
new TModels[] = {"terror", "leet","artic", "guerilla"}    

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	/*new ip[22];
	get_user_ip(0, ip, charsmax(ip));
	if(!equal(IP, ip))
	{
		set_fail_state("Ten Sklep niemoze byc kopiowany ~ Waq");
	}
	*/
	register_clcmd("say buy","Menu");
	register_clcmd("say /buy","Menu");
	register_clcmd("say_team buy","Menu");
	register_clcmd("say_team /buy","Menu");
	register_clcmd("say shop","Menu");
	register_clcmd("say /shop","Menu");
	register_clcmd("say_team shop","Menu");
	register_clcmd("say_team /shop","Menu");
	
	costFragHE=		register_cvar("shop_he_cost", "6");
	costFragSB=		register_cvar("shop_smoke_cost", "6");
	costFragFB=		register_cvar("shop_flash_cost", "3");
	costFragHP=		register_cvar("shop_hp_cost", "10");
	costFragRespawn=	register_cvar("shop_respawn_cost", "12");
	costFragLosRespawn=	register_cvar("shop_los_respawn_cost", "4");
	costFragRandom=		register_cvar("shop_lotto_cost", "4");
	
	ileHP=			register_cvar("shop_ile_hp", "100");
	
	bHE=			register_cvar("shop_he","1");
	bSB=			register_cvar("shop_smoke","1");
	bFB=			register_cvar("shop_flash","2");
	bHP=			register_cvar("shop_hp","1");
	bRespawn=		register_cvar("shop_respawn","1");
	bLosRespawn=		register_cvar("shop_los_respawn","3");
	bRandom=		register_cvar("shop_lotto","3");
	
	gmsgScoreInfo=		get_user_msgid("ScoreInfo");
	register_concmd("shop_give_frag", "cmd_give_frag", ADMIN_IMMUNITY, "<target> <amount>");
	
	register_menucmd	(register_menuid("Menu_klawiszy"), Klawisze, "Uzyj_Menu");
	
	register_event		("HLTV", "eventRoundInit", "a", "1=0", "2=0");
	register_event		("HLTV", "eventRoundInit2", "a", "1=0", "2=0");
	
	register_event		("DeathMsg", "Hook_Deathmessage", "a");
	register_event		("DeathMsg", "Hook_Deathmessage2", "a");
	
	register_event		("CurWeapon","eventCurWeapon","be","1=1");
}

public cmd_give_frag( id, level,cid ) { 
	if( ! cmd_access ( id, level, cid, 3 ) ) 
		return PLUGIN_HANDLED; 
	
	new target[32], amount[21], reason[21]; 
	
	read_argv( 1, target, 31 ); 
	read_argv(2, amount, 20 ); 
	read_argv( 3, reason, 20 ); 
	
	new player = cmd_target( id, target, 8 ); 
	
	if( ! player )  
		return PLUGIN_HANDLED; 
	
	new admin_name[32], player_name[32]; 
	get_user_name( id, admin_name, 31 ); 
	get_user_name( player, player_name, 31 ); 
	
	new fragnum = str_to_num( amount ); 
	fm_set_user_frags(id, get_user_frags(id) + fragnum)
	refreshfrags(id)
	return PLUGIN_CONTINUE; 
} 

public client_putinserver(id){
	for(new i = 1; i<33; i++){
		gbHe[i] = 0;
		gbSmoke[i] = 0;
		gbFlash[i] = 0;
		gbHp[i] = 0;
		gbRespawn[i] = 0;
		gbLosRespawn[i] = 0;
		gbLotto[i] = 0;
		gbSpeed[i] = false;
		gbSpeedMin[i] = false;
		gbBigJump[i] = false;
	}
}

public eventRoundInit(){
	for(new i = 1; i<33; i++){
		gbHe[i] = 0;
		gbSmoke[i] = 0;
		gbFlash[i] = 0;
		gbHp[i] = 0;
		gbRespawn[i] = 0;
		gbLosRespawn[i] = 0;
		gbLotto[i] = 0;
		gbSpeed[i] = false;
		gbSpeedMin[i] = false;
		gbBigJump[i] = false;
	}
}

public eventRoundInit2(){
	new id = read_data( 2 );
	
	fm_set_user_gravity( id, 1.0 );	
	fm_set_user_maxspeed( id, 250.0 );
	if ( gbCamo[id] == true ) { 
		set_task( 1.0, "reset_model", id ) ;
	}
	else if ( gbInvi[id] == true ) {
		set_task( 1.0,"koniec_niewidzialnosci",id);
	}
}

public Hook_Deathmessage(){
	for(new i = 1; i<33; i++){
		gbSpeed[i] = false;
		gbSpeedMin[i] = false;
		gbBigJump[i] = false;
	}
}

public Hook_Deathmessage2(){
	new id = read_data( 2 )
	
	fm_set_user_gravity( id, 1.0 )
	fm_set_user_maxspeed( id, 250.0 )
	
	if ( gbCamo[id] == true ) { 
		set_task( 1.0, "reset_model", id ) 
	}
	else if ( gbInvi[id] == true ) {
		set_task( 1.0,"koniec_niewidzialnosci",id)
	}
}

public eventCurWeapon(id){
	if(gbSpeed[id]){
		set_pev(id, pev_maxspeed, 280.0);
	}
	if(gbSpeedMin[id]){
		set_pev(id, pev_maxspeed, 230.0);
	}
}

public Menu(id)
{
	if(cs_get_user_team(id) == CS_TEAM_SPECTATOR) return;
	new MenuText[512]
	new ma_fragi = get_user_frags(id);
	format(MenuText,511,"\yShop Ganiany \rby Waq^n\yYou have \r[\y%d Frags\r]^n^n\r1. \wBuy HE \r[\y%d Frags\r]^n\r2. \wBuy SMOKE \r[\y%d Frags\r]^n\r3. \wBuy FB \r[\y%d Frags\r]^n^n\r4. \wBuy +%d HP \r[\y%d Frags\r]^n\r5. \wBuy Respawn \r[\y%d Frags\r]^n^n\r6. \wRandom Respawn \r[\y%d Frags\r]^n\r7. \wLotto \r[\y%d Frags\r]^n^n\r0. \wExit",
	ma_fragi, get_pcvar_num(costFragHE),get_pcvar_num(costFragSB),get_pcvar_num(costFragFB),get_pcvar_num(ileHP),get_pcvar_num(costFragHP),get_pcvar_num(costFragRespawn),get_pcvar_num(costFragLosRespawn),get_pcvar_num(costFragRandom))
	show_menu(id, Klawisze, MenuText, -1, "Menu_klawiszy");
}

public Uzyj_Menu(id, key)
{	
	new ma_fragi = get_user_frags(id);
	switch(key)
	{
		case 0:
		{
			if(!is_user_alive(id)) {
				ColorChat(id, RED, "^x03[%s]^x01You must be alive !",gszPrefixShop)
				return PLUGIN_HANDLED
			}
			if (get_user_frags(id) < get_pcvar_num(costFragHE)) {
				ColorChat(id, RED, "^x03[%s]^x01 You don't have enough frags ! ^x03( %d / %d )",gszPrefixShop, ma_fragi, get_pcvar_num(costFragHE))
				return PLUGIN_HANDLED	
			}
			
			if(gbHe[id]==get_pcvar_num(bHE)){
				ColorChat(id, BLUE, "^x04[%s]^x01 You have reached your maximum to buy HE!",gszPrefixShop);
				return PLUGIN_HANDLED
			}
			gbHe[id]++
			
			fm_set_user_frags(id, get_user_frags(id) - get_pcvar_num(costFragHE))
			fm_give_item(id, "weapon_hegrenade")
			ColorChat(id, RED, "^x03[%s]^x01 have purchased:^x04 HE",gszPrefixShop)
			refreshfrags(id)
		}
		case 1:
		{
			if(!is_user_alive(id)) {
				ColorChat(id, RED, "^x03[%s]^x01You must be alive !",gszPrefixShop)
				return PLUGIN_HANDLED
			}
			if (get_user_frags(id) < get_pcvar_num(costFragSB)) {
				ColorChat(id, RED, "^x03[%s]^x01 You don't have enough frags ! ^x03( %d / %d )",gszPrefixShop, ma_fragi, get_pcvar_num(costFragSB))
				return PLUGIN_HANDLED	
			}
			
			if(gbSmoke[id]==get_pcvar_num(bSB)){
				ColorChat(id, BLUE, "^x04[%s]^x01 You have reached your maximum to buy Smoke!",gszPrefixShop);
				return PLUGIN_HANDLED
			}
			gbSmoke[id]++
			
			fm_set_user_frags(id, get_user_frags(id) - get_pcvar_num(costFragSB))
			fm_give_item(id, "weapon_smokegrenade")
			ColorChat(id, RED, "^x03[%s]^x01 have purchased:^x04 Smoke",gszPrefixShop)
			refreshfrags(id)
		}
		case 2: 
		{
			if(!is_user_alive(id)) {
				ColorChat(id, RED, "^x03[%s]^x01You must be alive !",gszPrefixShop)
				return PLUGIN_HANDLED
			}
			
			if (get_user_frags(id) < get_pcvar_num(costFragFB)) {
				ColorChat(id, RED, "^x03[%s]^x01 You don't have enough frags ! ^x03( %d / %d )",gszPrefixShop, ma_fragi, get_pcvar_num(costFragFB))
				return PLUGIN_HANDLED	
			}
			
			if(gbFlash[id]==get_pcvar_num(bFB)){
				ColorChat(id, BLUE, "^x04[%s]^x01 You have reached your maximum to buy Flash!",gszPrefixShop);
				return PLUGIN_HANDLED
			}
			gbFlash[id]++
			
			fm_set_user_frags(id, get_user_frags(id) - get_pcvar_num(costFragFB))
			fm_give_item(id, "weapon_flashbang")
			ColorChat(id, RED, "^x03[%s]^x01 have purchased:^x04 Flash Bang",gszPrefixShop)
			refreshfrags(id)
		}
		case 3:
		{	
			if(!is_user_alive(id)) {
				ColorChat(id, RED, "^x03[%s]^x01You must be alive !",gszPrefixShop)
				return PLUGIN_HANDLED
			}
			if (get_user_frags(id) < get_pcvar_num(costFragHP)) {
				ColorChat(id, RED, "^x03[%s]^x01 You don't have enough frags ! ^x03( %d / %d )",gszPrefixShop, ma_fragi, get_pcvar_num(costFragHP))
				return PLUGIN_HANDLED	
			}
			
			if(gbHp[id]==get_pcvar_num(bHP)){
				ColorChat(id, BLUE, "^x04[%s]^x01 You have reached your maximum to buy HP!",gszPrefixShop);
				return PLUGIN_HANDLED
			}
			gbHp[id]++
			
			fm_set_user_frags(id, get_user_frags(id) - get_pcvar_num(costFragHP))
			fm_set_user_health(id, get_user_health(id) + get_pcvar_num(ileHP))
			ColorChat(id, RED, "^x03[%s]^x01 have purchased:^x04 Additional %d HP",gszPrefixShop, get_pcvar_num(ileHP))
			refreshfrags(id)
		}
		case 4:
		{	
			if(is_user_alive(id)) {
				ColorChat(id, RED, "^x03[%s]^x01You must be dead !",gszPrefixShop)
				return PLUGIN_HANDLED
	}
			if (get_user_frags(id) < get_pcvar_num(costFragRespawn)) {
				ColorChat(id, RED, "^x03[%s]^x01 You don't have enough frags ! ^x03( %d / %d )",gszPrefixShop, ma_fragi, get_pcvar_num(costFragRespawn))
				return PLUGIN_HANDLED	
			}
			
			if(gbRespawn[id]==get_pcvar_num(bRespawn)){
				ColorChat(id, BLUE, "^x04[%s]^x01 You have reached your maximum to buy Respawn",gszPrefixShop);
				return PLUGIN_HANDLED
			}
			gbRespawn[id]++
			
			fm_set_user_frags(id, get_user_frags(id) - get_pcvar_num(costFragRespawn))
			set_task(0.5, "respawn_player",id);
			ColorChat(id, RED, "^x03[%s]^x01 have purchased:^x04 Respawn",gszPrefixShop)
			refreshfrags(id)
		}
		case 5:
		{	
			if(is_user_alive(id)) {
				ColorChat(id, RED, "^x03[%s]^x01You must be dead !",gszPrefixShop)
				return PLUGIN_HANDLED
			}
			if (get_user_frags(id) < get_pcvar_num(costFragLosRespawn)) {
				ColorChat(id, RED, "^x03[%s]^x01 You don't have enough frags ! ^x03( %d / %d )",gszPrefixShop, ma_fragi, get_pcvar_num(costFragLosRespawn))
				return PLUGIN_HANDLED	
			}
			
			if(gbLosRespawn[id]==get_pcvar_num(bLosRespawn)){
				ColorChat(id, BLUE, "^x04[%s]^x01 You have reached your maximum to draw Respawn!",gszPrefixShop);
				return PLUGIN_HANDLED
			}
			gbLosRespawn[id]++
			
			fm_set_user_frags(id, get_user_frags(id) - get_pcvar_num(costFragLosRespawn))
			los_respawn(id)
			refreshfrags(id)
		}
		case 6:
		{
			if(!is_user_alive(id)) {
				ColorChat(id, RED, "^x03[%s]^x01You must be alive !",gszPrefixShop)
				return PLUGIN_HANDLED
			}
			if (get_user_frags(id) < get_pcvar_num(costFragRandom)) {
				ColorChat(id, RED, "^x03[%s]^x01 You don't have enough frags ! ^x03( %d / %d )",gszPrefixShop, ma_fragi, get_pcvar_num(costFragRandom))
				return PLUGIN_HANDLED	
			}
			
			if(gbLotto[id]==get_pcvar_num(bRandom)){
				ColorChat(id, BLUE, "^x04[%s]^x01 You have reached your maximum to buy Lotto",gszPrefixShop);
				return PLUGIN_HANDLED
			}
			gbLotto[id]++
			
			fm_set_user_frags(id, get_user_frags(id) - get_pcvar_num(costFragRandom))
			Losowanko(id)
		}
	}
	return PLUGIN_CONTINUE
}
los_respawn(id){
	switch(random_num(1, 100)){
		case 1..20:{
			ColorChat(id, RED, "^x04[%s]^x01 You got ^x04 Respawn",gszPrefixShop);
			set_task(0.5, "respawn_player",id);
		}
		case 21..100:{
			ColorChat(id, RED, "^x04[%s]^x01 You got ^x04 Empty fate",gszPrefixShop);
		}
	}
}
public Losowanko(id)
{
	get_user_name(id, szName, 31);
	switch(random_num(1,174))
	{
		case 1..10:{ // PUSTY LOS
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [Empty fate]", szName)
		}
		case 11..20:{// 2x MNIEJ FRAGOW
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [Less frag]", szName)
			fm_set_user_frags(id, get_user_frags(id) / 2)
		}
		case 21..26:{// 280 MAXSPEED
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw ^x04 [Speed Run]", szName)
			gbSpeed[id]=true;
			fm_set_user_maxspeed(id, 280.0)
		}
		case 27..36:{// 1 FRAG
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [1 frag]", szName)
			fm_set_user_frags(id, get_user_frags(id) + 1)
		}
		case 37..40:{// SMIERC
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [Death]", szName)
			user_kill(id, 0)
		}
		case 41..50:{// +10 FRAGOW
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [+10 frags]", szName)
			fm_set_user_frags(id, get_user_frags(id) + 10)
		}
		case 51..56:{// DUZA GRAWITACJA
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [High gravity]", szName)
			fm_set_user_gravity(id, 3.0);
		}
		case 57..66:{// +10 FRAGOW
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [+10 frags]", szName)
			fm_set_user_frags(id, get_user_frags(id) + 10)
		}
		case 67..72:{// 1 FRAG
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [1 frag]", szName)
			fm_set_user_frags(id, get_user_frags(id) + 1)
		}
		case 73..75:{// AWP
			fm_give_item(id, "weapon_awp");
			cs_set_user_bpammo(id, CSW_AWP, 0);
			cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_awp", id), 1); 
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [AWP]", szName)
		}
		case 76..80:{// Smoke
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [Smoke]", szName)
			fm_give_item(id, "weapon_smokegrenade")
		}
		case 81..90:{// -50 fragow
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [-50 frags]", szName)
			fm_set_user_frags(id, get_user_frags(id) - 50)
		}
		case 91..94:{// 2 razy wiecej fragow
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [Twice frags]", szName)
			fm_set_user_frags(id, get_user_frags(id) * 2)
		}
		case 95..97:{// mala grawitacja
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [Little gravity]", szName)
			fm_set_user_gravity(id, 0.8);
		}
		case 98..110:{// 1hp
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [1 HP]", szName)
			fm_set_user_health ( id, 1)
		}
		case 111..115:{// pusty los
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [Empty fate]", szName)
		}
		case 116..118:{// niewidzialnosc
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [Invisibility]", szName)
			fm_set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 10)
			gbInvi[id] = true
		}
		case 119..124:{// 20 hp
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [20HP]", szName)
			fm_set_user_health(id, 20)
		}
		case 125..127:{// scout
			fm_give_item(id, "weapon_scout");
			cs_set_user_bpammo(id, CSW_SCOUT, 0);
			cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_scout", id), 1); 
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [Scout]", szName)
		}
		case 128..132:{// God mode na 20 sec
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [GodMode in 20 Sec]", szName)
			fm_set_user_godmode(id, 1)
			set_task(20.0,"koniec_godmod",id)
		}
		case 133..140:{// 200 max speed
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [230 MaxSpeed]", szName)
			fm_set_user_maxspeed(id, 230.0)
			gbSpeedMin[id]=true
		}
		case 141..150:{// 1 FRAG
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [1 frag]", szName)
			fm_set_user_frags(id, get_user_frags(id) + 1)
		}
		case 151..153:{// 1 FRAG
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [50 frags]", szName)
			fm_set_user_frags(id, get_user_frags(id) + 50)
			}	
		case 154..159:{// HE
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [Grenade HE]", szName)
			fm_give_item(id, "weapon_hegrenade")
		}
		case 160..162:{// 200HP
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [200 HP]", szName)
			fm_set_user_health ( id, 200)
		}
		case 163..167:{// Slap
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw [Slap]", szName)
			m_slap(id)
		}
		case 168..170:{// Camouflage
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [Camouflage]", szName)
			new CsTeams:team = cs_get_user_team(id)
			if (team == CS_TEAM_CT) {  
				cs_set_user_model(id, TModels)      
				gbCamo[id] = true
			}  
		
			else if (team == CS_TEAM_T) {  
				cs_set_user_model(id, CTModels) 
				gbCamo[id] = true
			} 
		}
		case 171..174:{// Big Jump
			ColorChat(0, RED, "^x01Player: ^x03%s^x01 draw^x04 [BIG JUMP]", szName)
			gbBigJump[id] = true
		}
	
	}
	refreshfrags(id)
	return PLUGIN_HANDLED
}

public respawn_player(id){     
	if (!is_user_connected(id) || is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_SPECTATOR)         return;

	set_pev(id, pev_deadflag, DEAD_RESPAWNABLE)
	dllfunc(DLLFunc_Think, id)
	
	if (is_user_bot(id) && pev(id, pev_deadflag) == DEAD_RESPAWNABLE)
	{
		dllfunc(DLLFunc_Spawn, id)
	}
}

public refreshfrags(id){
	new ideaths=cs_get_user_deaths(id);
	new ifrags=pev(id, pev_frags);
	new kteam=_:cs_get_user_team(id);

	message_begin( MSG_ALL, gmsgScoreInfo, {0,0,0}, 0 );
	write_byte( id );
	write_short( ifrags );
	write_short( ideaths);
	write_short( 0 );
	write_short( kteam );
	message_end();
}

public reset_model(id) { 
	cs_reset_user_model(id)
	gbCamo[id] = false
}

public koniec_niewidzialnosci(id){
	fm_set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 255)
	gbInvi[id] = false
}

public koniec_godmod(id){
	fm_set_user_godmode(id, 0)
}

public m_slap(id){
	user_slap(id, 0)
	user_slap(id, 0)
	user_slap(id, 0)
	user_slap(id, 0)
	user_slap(id, 0)
}

public client_PreThink(id)
{
	if(is_user_connected(id) && gbBigJump[id])
	{
		new button = entity_get_int(id, EV_INT_button)

		new jump = (button & IN_JUMP)
		new flags = entity_get_int(id, EV_INT_flags)
		new onground = flags & FL_ONGROUND
		if( jump && onground)
			SideJump[id] = 1
	}
}

public client_PostThink(id) 
{
	if(is_user_connected(id) && gbBigJump[id])
	{
                new Float:gametime = get_gametime()
                new button = entity_get_int(id, EV_INT_button)
                
                new jump = (button & IN_JUMP)
                new Float:vel[3]
                new Float:delay=1.0
                new Float:pow=1.0
                new Float:hight=1000.0
                entity_get_vector(id,EV_VEC_velocity,vel)
                
                if( (gametime - SideJumpDelay[id] > delay) && SideJump[id] && jump ) {
                        
                        vel[0] *= pow
                        vel[1] *= pow
                        vel[2] = hight
                        
                        entity_set_vector(id,EV_VEC_velocity,vel)
                        SideJump[id] = 0
                        SideJumpDelay[id] = gametime
                }
                else
                        SideJump[id] = 0
        }
}
