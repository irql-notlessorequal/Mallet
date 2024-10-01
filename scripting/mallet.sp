#pragma semicolon 1
#pragma newdecls required

#include "mallet_conversions.sp"
#include "mallet_weapons.sp"
#include "mallet_weapons_db.sp"
#include "mallet_attribute_db.sp"
#include "mallet_attributes.sp"
#include "mallet_players.sp"

public Plugin myinfo = {
	name	= "Mallet",
	author	= "IRQL_NOT_LESS_OR_EQUAL",
	description	= "A general purpose utility library for Team Fortress 2",
	version	= "2024-09-07",
	url		= "https://github.com/irql-notlessorequal/Mallet"
};

static bool MALLET_IS_READY = false;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	char game[8];
	GetGameFolderName(game, sizeof(game));
	
	if (strncmp(game, "tf", 2, false) != 0)
	{
		strcopy(error, err_max, "Incompatible game loaded.");
		return APLRes_Failure;
	}

	CreateNative("MalletIsReady", Native_IsReady);

	/* Conversions */
	CreateNative("MalletConvertClassFromString", Native_ConvertClassFromString);
	CreateNative("MalletConvertSlotFromString", Native_ConvertSlotFromString);
	CreateNative("MalletConvertTeamFromString", Native_ConvertTeamFromString);

	/* Weapons */
	CreateNative("MalletCreateWeapon", Native_CreateWeapon);
	CreateNative("MalletCreateWearable", Native_CreateWearable);
	CreateNative("MalletEquipWearable", Native_EquipWearable);
	CreateNative("MalletIsWearable", Native_IsWearable);
	CreateNative("MalletRemoveWearable", Native_RemoveWearable);
	CreateNative("MalletRemoveWeapon", Native_RemoveWeapon);
	CreateNative("MalletGetWearableOwner", Native_GetWearableOwner);

	/* AttributeDB */
	CreateNative("MalletGetAttributeLocalization", Native_GetAttributeLocalization);

	/* Attributes */
	CreateNative("MalletSetAttribute", Native_SetAttribute);
	CreateNative("MalletDeleteAllAttributes", Native_DeleteAllAttributes);

	/* Players */
	CreateNative("MalletIsValidPlayer", Native_IsValidPlayer);
	
	RegPluginLibrary("mallet");
	return APLRes_Success;
}

public int Native_IsReady(Handle plugin, int numParams) {
	return MALLET_IS_READY;
}

public void OnPluginStart()
{
	if (!InitializeAttributes())
	{
		SetFailState("[OnPluginStart] InitializeAttributes() returned FALSE.");
		return;
	}

	if (!InitializeWeapons())
	{
		SetFailState("[OnPluginStart] InitializeWeapons() returned FALSE.");
		return;
	}

	if (!InitializeWeaponsDB())
	{
		SetFailState("[OnPluginStart] InitializeWeaponsDB() returned FALSE.");
		return;
	}

	MALLET_IS_READY = true;	
}