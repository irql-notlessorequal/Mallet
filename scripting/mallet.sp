#pragma semicolon 1
#pragma newdecls required

#include "mallet_conversions.sp"
#include "mallet_weapons.sp"
#include "mallet_weapons_db.sp"
#include "mallet_attribute_db.sp"
#include "mallet_attribute_locale.sp"
#include "mallet_attributes.sp"
#include "mallet_players.sp"
#include "mallet_loadout.sp"
#include "mallet_econ.sp"
#include "mallet_holidays.sp"

#if defined _X64

#if defined _X64_IMPLEMENTATION_PORT64
#define _X64_OK 1
#elseif defined _X64_IMPLEMENTATION_MEMORY_POINTER
#define _X64_OK 1
#elseif defined _X64_IMPLEMENTATION_VIRTUAL_ADDRESS
#error "This implementation is currently not supported."
#else
#error "No x64 implementation set! Set either _X64_IMPLEMENTATION_PORT64, _X64_IMPLEMENTATION_MEMORY_POINTER or _X64_IMPLEMENTATION_VIRTUAL_ADDRESS as a build time macro!"
#endif

#endif

public Plugin myinfo = {
	name	= "Mallet",
	author	= "IRQL_NOT_LESS_OR_EQUAL",
	description	= "A general purpose utility library for Team Fortress 2",
	version	= "2025-01-15",
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
	CreateNative("MalletIsX64", Native_IsX64);
	CreateNative("MalletAPIVersion", Native_APIVersion);

	/* Conversions */
	CreateNative("MalletConvertClassFromString", Native_ConvertClassFromString);
	CreateNative("MalletConvertSlotFromString", Native_ConvertSlotFromString);
	CreateNative("MalletConvertTeamFromString", Native_ConvertTeamFromString);

	/* Econ */
#if defined (MALLET_ENABLE_TF2ECON_COMPAT)
	CreateNative("TF2Econ_TranslateWeaponEntForClass", Native_TranslateWeaponEntForClass);
#endif
	CreateNative("MalletTranslateWeaponEntForClass", Native_TranslateWeaponEntForClass);

	/* Weapons */
	CreateNative("MalletCreateWeaponDumb", Native_CreateWeaponDumb);
	CreateNative("MalletRemoveWeapon", Native_RemoveWeapon);
	CreateNative("MalletGetWearableOwner", Native_GetWearableOwner);
	CreateNative("MalletIsWeapon", Native_IsWeapon);

	/* Weapons (Econ) */
	CreateNative("MalletCreateWeaponEcon", Native_CreateWeaponEcon);

	/* Weapons (Wearables) */
	CreateNative("MalletCreateWearable", Native_CreateWearable);
	CreateNative("MalletEquipWearable", Native_EquipWearable);
	CreateNative("MalletIsWearable", Native_IsWearable);
	CreateNative("MalletRemoveWearable", Native_RemoveWearable);

	/* WeaponsDB */
	CreateNative("MalletGetWeaponIndex", Native_GetWeaponIndex);

	/* AttributeDB */
	CreateNative("MalletGetAttributeClass", Native_GetAttributeClass);
	CreateNative("MalletGetRandomAttribute", Native_GetRandomAttribute);

	/* AttributeLocale */
	CreateNative("MalletGetRawAttributeDescription", Native_GetRawAttributeDescription);
	CreateNative("MalletGetAttributeDescription", Native_GetAttributeDescription);

	/* Attributes */
	CreateNative("MalletSetAttribute", Native_SetAttribute);
	CreateNative("MalletDeleteAllAttributes", Native_DeleteAllAttributes);

	/* Players */
	CreateNative("MalletIsValidPlayer", Native_IsValidPlayer);

	/* Loadout */
	CreateNative("MalletGetItemLoadoutSlot", Native_GetItemLoadoutSlot);

	/* Holidays */
	CreateNative("MalletIsHolidayActive", Native_IsHolidayActive);
	
	RegPluginLibrary("mallet");
	return APLRes_Success;
}

public int Native_IsReady(Handle plugin, int numParams) {
	return MALLET_IS_READY;
}

public int Native_IsX64(Handle plugin, int numParams)
{
#if defined _X64
	return 1;
#else
	return 0;
#endif
}

public int Native_APIVersion(Handle plugin, int numParams)
{
	/* This value should be bumped every time a breaking change or major change is introduced... */
	return 4;
}

public void OnPluginStart()
{
#if defined MALLET_DEBUG
	PrintToServer("[Mallet] [OnPluginStart] Initializing...");
#endif

	if (!InitializeAttributes())
	{
		SetFailState("[OnPluginStart] InitializeAttributes() returned FALSE.");
		return;
	}

#if defined MALLET_DEBUG
	PrintToServer("[Mallet] [OnPluginStart] Successfully loaded attributes.");
#endif

	if (!InitializeEcon())
	{
		SetFailState("[OnPluginStart] InitializeEcon() returned FALSE.");
		return;
	}

#if defined MALLET_DEBUG
	PrintToServer("[Mallet] [OnPluginStart] Successfully loaded econ.");
#endif

	if (!InitializeWeapons())
	{
		SetFailState("[OnPluginStart] InitializeWeapons() returned FALSE.");
		return;
	}

#if defined MALLET_DEBUG
	PrintToServer("[Mallet] [OnPluginStart] Successfully loaded weapons.");
#endif

	if (!InitializeLoadout())
	{
		SetFailState("[OnPluginStart] InitializeLoadout() returned FALSE.");
		return;
	}

#if defined MALLET_DEBUG
	PrintToServer("[Mallet] [OnPluginStart] Successfully loaded loadout.");
#endif

	if (!InitializeHolidays())
	{
		SetFailState("[OnPluginStart] InitializeHolidays() returned FALSE.");
		return;
	}

#if defined MALLET_DEBUG
	PrintToServer("[Mallet] [OnPluginStart] Successfully loaded holidays.");
#endif

	MALLET_IS_READY = true;	
#if defined MALLET_DEBUG
	PrintToServer("[Mallet] [OnPluginStart] Mallet is ready.");
#endif
}