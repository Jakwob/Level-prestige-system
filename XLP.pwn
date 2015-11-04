/*

       $$$$$\           $$\                               $$\      ™
       \__$$ |          $$ |                              $$ |
          $$ | $$$$$$\  $$ |  $$\ $$\  $$\  $$\  $$$$$$\  $$$$$$$\
          $$ | \____$$\ $$ | $$  |$$ | $$ | $$ |$$  __$$\ $$  __$$\
    $$\   $$ | $$$$$$$ |$$$$$$  / $$ | $$ | $$ |$$ /  $$ |$$ |  $$ |
    $$ |  $$ |$$  __$$ |$$  _$$<  $$ | $$ | $$ |$$ |  $$ |$$ |  $$ |
    \$$$$$$  |\$$$$$$$ |$$ | \$$\ \$$$$$\$$$$  |\$$$$$$  |$$$$$$$  |
     \______/  \_______|\__|  \__| \_____\____/  \______/ \_______/
				   _____________________________
				  |      Created By Jakwob™     |
                  |  Do not claim its your own  |
                  |________©2015 Jakwob™________|
						  Version 1.3.1
*/

#define FILTERSCRIPT

#include <a_samp>
#include <zcmd>
#include <YSI\y_ini>
#include <sscanf2>

#define UserLevels "Levels/%s.ini"
#define SCM SendClientMessage

enum
{
	DIALOG_RANKHELP,
	DIALOG_MYRANK
}

enum RankInfo
{
	xp,
	level,
    prestige
}
new rInfo[MAX_PLAYERS][RankInfo];
new PlayerText:RanksTD;
new bool:debugmode;

public OnFilterScriptInit()
{
	debugmode = false; // Change to true for permanent debugmode
	return 1;
}

public OnFilterScriptExit()
{
	debugmode = false; // Change to true for permanent debugmode
	return 1;
}

stock LevelsPath(playerid)
{
    new str[128],name[MAX_PLAYER_NAME];
    GetPlayerName(playerid,name,sizeof(name));
    format(str,sizeof(str),UserLevels,name);
    return str;
}
forward loadaccount_user(playerid, name[], value[]);
public loadaccount_user(playerid, name[], value[])
{
    INI_Int("XP",rInfo[playerid][xp]);
    INI_Int("Level",rInfo[playerid][level]);
    INI_Int("Prestige",rInfo[playerid][prestige]);
	if(debugmode == true)
	{
		printf("[debug] %s file loaded", GetName(playerid));
	}
    return 1;
}

public OnPlayerConnect(playerid)
{
	INI_ParseFile(LevelsPath(playerid),"loadaccount_%s",.bExtra = true, .extra = playerid);
	
	new string[125];
 	format(string,sizeof string,"~g~XP ~y~%d~n~~g~Level ~y~%d~n~~g~Prestige ~y~%d",rInfo[playerid][xp], rInfo[playerid][level], rInfo[playerid][prestige]);
	PlayerTextDrawSetString(playerid, RanksTD, string);
	RanksTD = CreatePlayerTextDraw(playerid,500.000000, 100.000000, string);
	PlayerTextDrawBackgroundColor(playerid,RanksTD, 255);
	PlayerTextDrawFont(playerid,RanksTD, 3);
	PlayerTextDrawLetterSize(playerid,RanksTD, 0.500000, 1.000000);
	PlayerTextDrawColor(playerid,RanksTD, -1);
	PlayerTextDrawSetOutline(playerid,RanksTD, 1);
	PlayerTextDrawSetProportional(playerid,RanksTD, 1);
	PlayerTextDrawSetSelectable(playerid,RanksTD, 0);
	return 1;
}

public OnPlayerSpawn(playerid)
{
    PlayerTextDrawShow(playerid, RanksTD);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new INI:file = INI_Open(LevelsPath(playerid));
 	INI_SetTag(file,"Player Levels");
    INI_WriteInt(file,"XP",rInfo[playerid][xp]);
    INI_WriteInt(file,"Level",rInfo[playerid][level]);
    INI_WriteInt(file,"Prestige",rInfo[playerid][prestige]);
    INI_Close(file);
	if(debugmode == true)
	{
		printf("[debug] %s file saved", GetName(playerid));
	}
    
    PlayerTextDrawHide(playerid, RanksTD);
	PlayerTextDrawDestroy(playerid, RanksTD);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	rInfo[killerid][xp] += 1;
	PlayerTextDrawHide(playerid, RanksTD);
	return 1;
}

public OnPlayerUpdate(playerid)
{
	LevelUp(playerid);
	return 1;
}

CMD:myrank(playerid, params[])
{
    new str[300];
    format(str, sizeof(str), "XP: %d\nLevel: %d\nPrestige: %d\n", rInfo[playerid][xp], rInfo[playerid][level],rInfo[playerid][prestige]);
	ShowPlayerDialog(playerid, DIALOG_MYRANK, DIALOG_STYLE_MSGBOX, "Your Rank", str, "Close", "");
	if(debugmode == true)
	{
		printf("[debug] %s has used /myrank", GetName(playerid));
	}
	return 1;
}

CMD:rankhelp(playerid, params[])
{
	new str[300], str1[1000];
	format(str, sizeof(str), "\n{FFFFFF}** {FF9900}XP {FFFFFF}**\n");
	strcat(str1, str);
	format(str, sizeof(str), "\nXP can be gained by many methods.\nKilling Players - 1 XP\n'Example' - 4 XP\n'Example' - 2 XP\n");
	strcat(str1, str);
	format(str, sizeof(str), "\n{FFFFFF}** {FF9900}Leveling up {FFFFFF}**\n");
	strcat(str1, str);
	format(str, sizeof(str), "\nUpon leveling up you will recieve a cash bonus each time you level up.\n");
	strcat(str1, str);
	format(str, sizeof(str), "\n{FFFFFF}** {FF9900}Prestige {FFFFFF}**\n");
	strcat(str1, str);
	format(str, sizeof(str), "\nWhen you reach the maximum level you will Prestige\nYou will recieve a huge cash bonus of $1 million each time you prestige.\n");
	strcat(str1, str);
	ShowPlayerDialog(playerid, DIALOG_RANKHELP, DIALOG_STYLE_MSGBOX, "Rank Help", str1, "Close", "");
	if(debugmode == true)
	{
		printf("[debug] %s has used /rankhelp", GetName(playerid));
	}
	return 1;
}

CMD:givexp(playerid, params[])
{
	new amount, ID, str[128];
	if(!IsPlayerAdmin(playerid))return SCM(playerid, -1, "ERROR: You need to be an admin to use this command!");
 	if(sscanf(params, "ui", ID, amount)) return SCM(playerid, -1, "USAGE: /givexp <playerid> <1-99>");
    if(amount < 1 || amount > 99) return SCM(playerid, -1, "ERROR: Invalid XP ammount. Number must be between 1 and 99.");
    if(!IsPlayerConnected(ID))return SCM(playerid,-1,"ERROR: Player is not connected.");
    {
		format(str, sizeof(str), "%s Has given you %d XP", GetName(playerid), amount);
        SCM(ID, -1, str);
		format(str, sizeof(str), "You have given you %s %d XP", GetName(ID), amount);
        SCM(playerid, -1, str);
		rInfo[ID][xp] += amount;
		UpdateRankTD(playerid);
		if(debugmode == true)
		{
			printf("[debug] %s has given %s %d xp", GetName(playerid), GetName(ID), amount);
		}
	}
	return 1;
}

CMD:givelvl(playerid, params[])
{
	new amount, ID, str[128];
	if(!IsPlayerAdmin(playerid))return SCM(playerid, -1, "ERROR: You need to be an admin to use this command!");
 	if(sscanf(params, "ui", ID, amount)) return SCM(playerid, -1, "USAGE: /givelevel <playerid> <1-99>");
    if(amount < 1 || amount > 99) return SCM(playerid, -1, "ERROR: Invalid XP ammount. Number must be between 1 and 99.");
    if(!IsPlayerConnected(ID))return SCM(playerid,-1,"ERROR: Player is not connected.");
    {
		format(str, sizeof(str), "%s Has given you %d levels", GetName(playerid), amount);
        SCM(ID, -1, str);
		format(str, sizeof(str), "You have given you %s %d levels", GetName(ID), amount);
        SCM(playerid, -1, str);
		rInfo[ID][level] += amount;
		UpdateRankTD(playerid);
		if(debugmode == true)
		{
			printf("[debug] %s has given %s %d levels", GetName(playerid), GetName(ID), amount);
		}
	}
	return 1;
}

CMD:giveprestige(playerid, params[])
{
	new amount, ID, str[128];
	if(!IsPlayerAdmin(playerid))return SCM(playerid, -1, "ERROR: You need to be an admin to use this command!");
 	if(sscanf(params, "ui", ID, amount)) return SCM(playerid, -1, "USAGE: /giveprestige <playerid> <1-99>");
    if(amount < 1 || amount > 99) return SCM(playerid, -1, "ERROR: Invalid XP ammount. Number must be between 1 and 99.");
    if(!IsPlayerConnected(ID))return SCM(playerid,-1,"ERROR: Player is not connected.");
    {
		format(str, sizeof(str), "%s Has given you %d prestige", GetName(playerid), amount);
        SCM(ID, -1, str);
		format(str, sizeof(str), "You have given you %s %d prestiges", GetName(ID), amount);
        SCM(playerid, -1, str);
		rInfo[ID][prestige] += amount;
		UpdateRankTD(playerid);
		if(debugmode == true)
		{
			printf("[debug] %s has given %s %d prestige", GetName(playerid), GetName(ID), amount);
		}
	}
	return 1;
}

CMD:resetrank(playerid, params[])
{
	new ID, str[128];
	if(!IsPlayerAdmin(playerid))return SCM(playerid, -1, "ERROR: You need to be an admin to use this command!");
 	if(sscanf(params, "u", ID)) return SCM(playerid, -1, "USAGE: /resetrank <playerid>");
    if(!IsPlayerConnected(ID))return SCM(playerid,-1,"ERROR: Player is not connected.");
    {
		format(str, sizeof(str), "%s Has rest your rank", GetName(playerid));
        SCM(ID, -1, str);
		format(str, sizeof(str), "You have rest %s's Rank", GetName(ID));
        SCM(playerid, -1, str);
        rInfo[ID][xp] = 0;
        rInfo[ID][level] = 0;
		rInfo[ID][prestige] = 0;
		UpdateRankTD(playerid);
		if(debugmode == true)
		{
			printf("[debug] %s used /resetrank on %s", GetName(playerid), GetName(ID));
		}
	}
	return 1;
}

//Example of usages of xp/levels/prestige
CMD:veh(playerid, params[])
{
	if(rInfo[playerid][prestige] < 1) return SCM(playerid, -1, "You need to be Prestige level 1");
	{
		new Float:x,Float:y,Float:z, Float:a,veh;
		GetPlayerPos(playerid,x,y,z);
		GetPlayerFacingAngle(playerid, a);
		veh = CreateVehicle(402,x,y,z,a,-1,-1,-1);
		PutPlayerInVehicle(playerid,veh,0);
		if(debugmode == true)
		{
			printf("[debug] %s used /veh and spawned vehicle model 402", GetName(playerid));
		}
	}
	return 1;
}

CMD:rdm(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))return SCM(playerid, -1, "ERROR: You need to be an admin to use this command!");
	if(debugmode == false)
	{
	    SCM(playerid, -1, "[debug] Ranks Debug Mode Activated");
	    debugmode = true;
	    printf("[debug] %s has activated Ranks Debug Mode", GetName(playerid));
	}
	if(debugmode == true)
	{
	    SCM(playerid, -1, "[debug] Ranks Debug Mode Deactivated");
	    debugmode = false;
 	    printf("[debug] %s has deactivated Ranks Debug Mode", GetName(playerid));
	}
	return 1;
}

LevelUp(playerid)
{
	if(rInfo[playerid][xp] > 100)//Levels
	{
	    rInfo[playerid][level] ++;
	    rInfo[playerid][xp] = 0;
	    GivePlayerMoney(playerid, 50000);
	    UpdateRankTD(playerid);
 		if(debugmode == true)
		{
			printf("[debug] %s has leveled up to %d", GetName(playerid), rInfo[playerid][prestige]);
		}
	}
	if(rInfo[playerid][level] > 100)//Prestige levels
	{
	    rInfo[playerid][prestige] ++;
	    rInfo[playerid][xp] = 0;
	    rInfo[playerid][level] = 0;
	    GivePlayerMoney(playerid, 1000000);
	    UpdateRankTD(playerid);
 		if(debugmode == true)
		{
			printf("[debug] %s has prestiged up to %d", GetName(playerid), rInfo[playerid][prestige]);
		}
	}
}

UpdateRankTD(playerid)
{
	new str[125];
	format(str,sizeof str,"~g~XP ~y~%d~n~~g~Level ~y~%d~n~~g~Prestige ~y~%d",rInfo[playerid][xp], rInfo[playerid][level], rInfo[playerid][prestige]);
	PlayerTextDrawSetString(playerid, RanksTD, str);
}

GetName(playerid)
{
    new name[24];
    GetPlayerName(playerid, name, sizeof name);
    return name;
}
