#include <tf2>
#include <tf2_stocks>

#include "mallet_utils.sp"

static Handle hSDKEquipWearable = INVALID_HANDLE;
static Handle hSDKRemoveWearable = INVALID_HANDLE;
static Handle hSDKIsWearable = INVALID_HANDLE;

public bool InitializeWeaponsWearable()
{
	GameData gamedata = new GameData("sm-tf2.games");
	GameData hGameConf = new GameData("tf2.mallet");

	if (gamedata == INVALID_HANDLE || hGameConf == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to find the game data handle!")
		return false;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(gamedata.GetOffset("RemoveWearable") - 1);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);

	hSDKEquipWearable = EndPrepSDKCall();

	if (hSDKEquipWearable == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CTFPlayer::EquipWearable!")
		return false;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(gamedata.GetOffset("RemoveWearable"));
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	hSDKRemoveWearable = EndPrepSDKCall();

	if (hSDKRemoveWearable == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CTFPlayer::RemoveWearable!")
		return false;
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CBaseEntity::IsWearable");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	hSDKIsWearable = EndPrepSDKCall();

	if (hSDKIsWearable == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CBaseEntity::IsWearable!")
		return false;
	}

	delete gamedata;
	delete hGameConf;
	return true;
}

int GiveWearable(int clientIdx, int weaponId, const char[] weaponName)
{
	int ent = CreateEntityByName(weaponName);
	if (!IsValidEntity(ent))
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	SetEntProp(ent, Prop_Send, "m_hOwnerEntity", clientIdx);
	SetEntProp(ent, Prop_Send, "m_nModelIndexOverrides", PrecacheModel("models/weapons/c_models/c_persian_shield/c_persian_shield_all.mdl"));
	SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", weaponId);
	SetEntProp(ent, Prop_Send, "m_bInitialized", true);
	
	if (!DispatchSpawn(ent))
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}
	else
	{
		SDKCall(hSDKEquipWearable, clientIdx, ent);
		return ent;
	}
}

int InternalCreateWearable(int client, int weaponId, const char[] weaponName)
{
	int ent = CreateEntityByName(weaponName);
	if (!IsValidEntity(ent))
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(ent, Prop_Send, "m_nModelIndexOverrides", PrecacheModel("models/weapons/c_models/c_persian_shield/c_persian_shield_all.mdl"));
	SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", weaponId);
	SetEntProp(ent, Prop_Send, "m_bInitialized", true);
	
	if (!DispatchSpawn(ent))
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}
	else
	{
		return ent;
	}
}

int InternalEquipWearable(int client, int entity)
{
	if (!IsValidEntity(entity))
	{
		return MALLET_ERROR_INVALID_ENTITY;
	}

	SDKCall(hSDKEquipWearable, client, entity);
	return 1;
}

bool TypeIsWearable(const char[] name)
{
	return StrEqual(name, "tf_wearable") || StrEqual(name, "tf_wearable_demoshield")
		|| StrEqual(name, "tf_wearable_razorback") || StrEqual(name, "tf_powerup_bottle");
}

/* native int MalletIsWearable(int entity) */
public int Native_IsWearable(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	
	return Internal_IsWearable(entity);
}

bool Internal_IsWearable(int entity)
{
	if (entity <= MaxClients || !IsValidEntity(entity))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is an invalid entity", entity);
	}
	
	return SDKCall(hSDKIsWearable, entity);
}

void InternalRemoveWearable(int client, int wearable)
{
	SDKCall(hSDKRemoveWearable, client, wearable);
}

bool InternalRemoveAllWearables(int client)
{
	/**
	 * Apparently AcceptEntityInput(KILL) on tf_wearable shouldn't work
	 * but it does?
	 * 
	 * /shrug
	 */

	int wearable = -1;
	while ((wearable = FindEntityByClassname(wearable, "tf_wearable*")) != -1)
	{
		if (IsValidEntity(wearable))
		{
			int player = GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity");
			if (client == player)
			{
				InternalRemoveWearable(client, wearable);
				AcceptEntityInput(wearable, "Kill");
			}
		}
	}

	while ((wearable = FindEntityByClassname(wearable, "tf_powerup_bottle")) != -1)
	{
		if (IsValidEntity(wearable))
		{
			int player = GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity");
			if (client == player)
			{
				InternalRemoveWearable(client, wearable);
				AcceptEntityInput(wearable, "Kill");
			}
		}
	}

	while ((wearable = FindEntityByClassname(wearable, "tf_weapon_spellbook")) != -1)
	{
		if (IsValidEntity(wearable))
		{
			int player = GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity");
			if (client == player)
			{
				InternalRemoveWearable(client, wearable);
				AcceptEntityInput(wearable, "Kill");
			}
		}
	}

	return true;
}

/* native int MalletRemoveWearable(int client, int wearable) */
public int Native_RemoveWearable(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return -1;
	}
	
	int wearable = GetNativeCell(2);
	if (!Internal_IsWearable(wearable))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is not a wearable", wearable);
	}
	
	InternalRemoveWearable(client, wearable);
	return 1;
}

/* native int MalletCreateWearable(int client, int weaponId, const char[] weaponName) */
public int Native_CreateWearable(Handle plugin, int numParams)
{
	if (numParams != 3)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int client = GetNativeCell(1);
	int weaponId = GetNativeCell(2);

	char weaponName[64];
	GetNativeString(3, weaponName, 64);

	return InternalCreateWearable(client, weaponId, weaponName);
}

/* native int MalletEquipWearable(int client, int entity) */
public int Native_EquipWearable(Handle plugin, int numParams)
{
	if (numParams != 2)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}
	
	int client = GetNativeCell(1);
	int entity = GetNativeCell(2);
	return InternalEquipWearable(client, entity);
}

/* native int MalletGetWearableOwner(int weapon, int client) */
public int Native_GetWearableOwner(Handle plugin, int numParams)
{
	if (numParams != 2)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int weapon = GetNativeCell(1);
	int client = GetNativeCell(2);

	int iEntity = -1;
	while ((iEntity = FindEntityByClassname(iEntity, "tf_wearable_demoshield")) != -1)
	{
		if (client == GetEntPropEnt(iEntity, Prop_Data, "m_hOwnerEntity"))
		{
			return iEntity;
		}
	}

	return -1;	
}

/* native int MalletRemoveAllWearables(int client) */
public int Native_RemoveAllWearables(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int client = GetNativeCell(1);
	return InternalRemoveAllWearables(client);
}