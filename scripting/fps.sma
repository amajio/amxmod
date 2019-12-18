#include <amxmodx>
#include <Colorchat>

#define PluginName    "Prevent fps_override"
#define PluginVersion "0.1"
#define PluginAuthor  "HamletEagle"

public plugin_init()
{
	register_plugin
	(
	.plugin_name = PluginName,
	.version     = PluginVersion,
	.author      = PluginAuthor
	)
	set_task(10.0, "QueryClientCvar", .flags = "b")
}
 
public QueryClientCvar()
{
	new Players[32], Num, id
	get_players(Players, Num, "ch")
	for(new i; i < Num; i++)
	{
		id = Players[i]
		if (is_user_alive(id))
		{
			query_client_cvar(id, "fps_override", "fpsOverride_CallBack")
		}
	}
}

public fpsOverride_CallBack(id, const Cvar[], const Value[], const Param[])
{
	if(str_to_num(Value) != 0)
	{
		new szName[32]
		get_user_name(id, szName, charsmax(szName))
		client_print_color(0,RED,"^3[DETECTED] ^1=> ^4%s ^3was using fps override ,KICK!!",szName)
		server_cmd("amx_kick #%i ^"fps_override 1 not allowed^"", get_user_userid(id))
	}
}
