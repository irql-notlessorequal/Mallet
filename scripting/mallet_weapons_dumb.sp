#include <tf2>
#include <tf2_stocks>

#include "mallet_defines.sp"
#include "mallet_weapons_wearable.sp"
#include "mallet_econ.sp"

static Handle hGiveNamedItem = INVALID_HANDLE;

public bool InitializeWeaponsDumb()
{
	GameData hGameConf = new GameData("tf2.mallet");

	if (hGameConf == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to find the game data handle!")
		return false;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CBasePlayer::GiveNamedItem");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Plain);
	hGiveNamedItem = EndPrepSDKCall();

	if (hGiveNamedItem == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CBasePlayer::GiveNamedItem!")
		return false;
	}

	delete hGameConf;
	return true;
}

UNEXPORT bool GetCompatibleSaxxyWeapon(const TFClassType type, char weaponName[24])
{
	if (type == TFClass_Scout)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_bat");
		return true;
	}
	else if (type == TFClass_Sniper)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_club");
		return true;
	}
	else if (type == TFClass_Soldier)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_shovel");
		return true;
	}
	else if (type == TFClass_DemoMan)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_bottle");
		return true;
	}
	else if (type == TFClass_Engineer)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_wrench");
		return true;
	}
	else if (type == TFClass_Pyro)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_fireaxe");
		return true;
	}
	else if (type == TFClass_Heavy)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_fists");
		return true;
	}
	else if (type == TFClass_Spy)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_knife");
		return true;
	}
	else if (type == TFClass_Medic)
	{
		strcopy(weaponName, sizeof weaponName, "tf_weapon_bonesaw");
		return true;
	}
	else
	{
		return false;
	}
}

/* native int MalletCreateWeaponDumb(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot) */
public int Native_CreateWeaponDumb(Handle plugin, int numParams)
{
	/* Require the full six params for now, until we're confident enough to break ABI. */
	if (numParams != 6)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int client = GetNativeCell(1);
	int weaponId = GetNativeCell(2);

	char weaponName[64];
	GetNativeString(3, weaponName, 64);

	int weaponSlot = GetNativeCell(6);

	return InternalCreateWeaponDumb(client, weaponId, weaponName, weaponSlot);
}

int InternalCreateWeaponDumb(int client, int weaponId, const char[] weaponName, int weaponSlot)
{
	if (StrEqual(weaponName, "tf_wearable_demoshield", false))
	{
		return GiveWearable(client, weaponId, weaponName);
	}

	if (StrEqual(weaponName, "saxxy", false))
	{
		/* "saxxy" doesn't exist, convert to an actual weapon. */
		TFClassType classType = TF2_GetPlayerClass(client);

		char newWeaponName[24];
		GetCompatibleSaxxyWeapon(classType, newWeaponName);

		return InternalCreateWeaponDumb(client, weaponId, newWeaponName, weaponSlot);
	}

	/**
	 * Creating a weapon entity tends to create plenty of issues, including but not limited to:
	 * - Not fucking working
	 * - Free A-posing
	 * - Not working
	 * - See above.
	 */
	int weapon = SDKCall(hGiveNamedItem, client, weaponName, 0);

	if (weapon <= 0)
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}

	/* Set up the entity. */
	SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", weaponId);
	SetEntProp(weapon, Prop_Send, "m_bValidatedAttachedEntity", true);

	/* Setting "m_bInitialized" doesn't work, and won't ever work. */

	if (StrEqual(weaponName, "tf_weapon_builder", false) || StrEqual(weaponName, "tf_weapon_sapper", false))
	{
		SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
		if (weaponSlot == TFWeaponSlot_Secondary)
		{
			SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
		}
		else
		{
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
		}
	}

	return weapon;
}