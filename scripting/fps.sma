/*    Copyleft 2015

    Query Client Cvar Test is free software;
    you can redistribute it and/or modify it under the terms of the
    GNU General Public License as published by the Free Software Foundation.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Query Client Cvar Test; if not, write to the
    Free Software Foundation, Inc., 59 Temple Place - Suite 330,
    Boston, MA 02111-1307, USA.
*/ 
#include <amxmodx>

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
    
    set_task(1.0, "QueryClientCvar", .flags = "b")
}

public QueryClientCvar()
{
    new Players[32], Num, id
    get_players(Players, Num, "ch")
    for(new i; i < Num; i++)
    {
        id = Players[i]
        query_client_cvar(id, "fps_override", "fpsOverride_CallBack")
    }
}


public fpsOverride_CallBack(id, const Cvar[], const Value[], const Param[])
{
    if(str_to_num(Value) != 0)
    {
		new szName[32]
		get_user_name(id, szName, charsmax(szName))
		client_print(0,print_chat,"%s => GOT KICK FPS OVERRIDE DETECTED!!",szName)
        server_cmd("amx_kick #%i ^"not allowed fps_override XD^"", get_user_userid(id))
    }
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1054\\ f0\\ fs16 \n\\ par }
*/
