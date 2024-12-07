#include <tf2>
#include <tf2_stocks>

#include "mallet_defines.sp"
#include "mallet_weapons_wearable.sp"
#include "mallet_econ.sp"

/* native int MalletCreateWeaponDumb(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot) */
EXPERIMENTAL public int Native_CreateWeaponDumb(Handle plugin, int numParams)
{
	if (numParams != 6)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int client = GetNativeCell(1);
	int weaponId = GetNativeCell(2);

	char weaponName[64];
	GetNativeString(3, weaponName, 64);

	int level = GetNativeCell(4);
	int quality = GetNativeCell(5);
	int weaponSlot = GetNativeCell(6);

	return InternalCreateWeaponDumb(client, weaponId, weaponName, level, quality, weaponSlot);
}

int InternalCreateWeaponDumb(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot)
{
	if (StrEqual(weaponName, "tf_wearable_demoshield", false))
	{
		return GiveWearable(client, weaponId, weaponName);
	}

	if (StrEqual(weaponName, "saxxy", false))
	{
		/* "saxxy" doesn't exist, convert to an actual weapon. */
		TFClassType classType = TF2_GetPlayerClass(client);

		char newWeaponName[64];
		TranslateWeaponEntForClass(newWeaponName, 64, classType);

		return InternalCreateWeaponDumb(client, weaponId, newWeaponName, level, quality, weaponSlot);
	}

	int weapon = CreateEntityByName(weaponName);
	if (!IsValidEntity(weapon))
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	/* Set up the entity. */
	SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", weaponId);
	SetEntProp(weapon, Prop_Send, "m_bInitialized", 1);

	/* Apply misc. data */
	SetEntProp(weapon, Prop_Send, "m_iEntityLevel", level);
	SetEntProp(weapon, Prop_Send, "m_iEntityQuality", quality);

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

	if (!DispatchSpawn(weapon))
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}
	else
	{
		return weapon;
	}
}