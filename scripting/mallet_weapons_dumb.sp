#include <tf2>
#include <tf2_stocks>

#include "mallet_defines.sp"
#include "mallet_weapons_wearable.sp"
#include "mallet_econ.sp"

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

		char newWeaponName[24];
		GetCompatibleSaxxyWeapon(classType, newWeaponName);

		return InternalCreateWeaponDumb(client, weaponId, newWeaponName, level, quality, weaponSlot);
	}

	int weapon = CreateEntityByName(weaponName);
	if (!IsValidEntity(weapon))
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	char entityClass[64];
	GetEntityNetClass(weapon, entityClass, sizeof(entityClass));

	/**
	 * Set up the entity. 
	 * 
	 * No I don't care that this breaks TOS. I expect users of this function not to be brain dead.
	 * I am asking for a lot aren't I?
	 */
	SetEntData(weapon, FindSendPropInfo(entityClass, "m_iItemDefinitionIndex"), weaponId);	
	SetEntData(weapon, FindSendPropInfo(entityClass, "m_bInitialized"), true);

	/* TODO(rake): Does this have a 'FindSendPropInfo' equivalent? */
	SetEntProp(weapon, Prop_Send, "m_bValidatedAttachedEntity", true);

	/* Apply misc. data */
	int internal_level = 1;
	int internal_quality = 6;

	if (level)
	{
		internal_level = level;
	}

	if (quality)
	{
		internal_quality = quality;
	}

	SetEntData(weapon, FindSendPropInfo(entityClass, "m_iEntityLevel"), internal_level);
	SetEntData(weapon, FindSendPropInfo(entityClass, "m_iEntityQuality"), internal_quality);

	if (!DispatchSpawn(weapon))
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}
	else
	{
		switch (weaponId)
		{
			/* The Red-Tape Recorder */
			case 810:
			{
				SetEntData(weapon, FindSendPropInfo(entityClass, "m_iObjectType"), 3);
				SetEntData(weapon, FindDataMapInfo(weapon, "m_iSubType"), 3);
				static int buildables[4] = {0, 0, 0, 1};
				SetEntDataArray(weapon, FindSendPropInfo(entityClass, "m_aBuildableObjectTypes"), buildables, 4);
			}

			/* The Vaccinator */
			case 998:
			{
				SetEntData(weapon, FindSendPropInfo(entityClass, "m_nChargeResistType"), 0);
			}

			/* Dragon's Fury */
			case 1178:
			{
				int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;
				int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
				SetEntData(client, iAmmoTable + iOffset, 40, 4);
			}

			/* The Flare Gun */
			/* The Detonator */
			/* The Scorch Shot */
			case 39, 351, 740:
			{
				int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;
				int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
				SetEntData(client, iAmmoTable + iOffset, 16, 4);	
			}
		}

		/* TODO(rake): Move this into the switch statement above. */
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
}