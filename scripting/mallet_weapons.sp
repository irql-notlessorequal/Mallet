#include <tf2>
#include <tf2_stocks>

#define MALLET_ERROR_GENERAL_ERROR  -1
#define MALLET_ERROR_INVALID_ENTITY -2
#define MALLET_ERROR_INVALID_ENTITY_CLASS -3
#define MALLET_ERROR_FAILED_TO_SPAWN -4

static Handle hSDKEquipWearable = INVALID_HANDLE;
static Handle hSDKRemoveWearable = INVALID_HANDLE;
static Handle hSDKIsWearable = INVALID_HANDLE;
static Handle hGiveNamedItem = INVALID_HANDLE;
static Handle hSDKIsWeapon = INVALID_HANDLE;

public bool InitializeWeapons() {

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

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CBaseEntity::IsBaseCombatWeapon");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	hSDKIsWeapon = EndPrepSDKCall();

	if (hSDKIsWeapon == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CBaseEntity::IsBaseCombatWeapon!")
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

	delete gamedata;
	delete hGameConf;
	return true;
}

bool GetCompatibleSaxxyWeapon(const TFClassType type, char weaponName[24])
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
		/* I'm not sure that this is correct... */
		strcopy(weaponName, sizeof weaponName, "tf_weapon_fireaxe");
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

int GiveWearable(int clientIdx, int weaponId, const char[] weaponName)
{
	int ent = CreateEntityByName(weaponName);
	if (ent == -1)
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	SetEntProp(ent, Prop_Send, "m_hOwnerEntity", clientIdx);
	SetEntProp(ent, Prop_Send, "m_nModelIndexOverrides", PrecacheModel("models/weapons/c_models/c_persian_shield/c_persian_shield_all.mdl"));
	SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", weaponId);
	
	if (!DispatchSpawn(ent))
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}

	SDKCall(hSDKEquipWearable, clientIdx, ent);
	return ent;
}

int InternalCreateWearable(int client, int weaponId, const char[] weaponName)
{
	int ent = CreateEntityByName(weaponName);
	if (ent == -1)
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(ent, Prop_Send, "m_nModelIndexOverrides", PrecacheModel("models/weapons/c_models/c_persian_shield/c_persian_shield_all.mdl"));
	SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", weaponId);
	
	if (!DispatchSpawn(ent))
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}

	return ent;
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

int InternalCreateWeapon(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot)
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

		return InternalCreateWeapon(client, weaponId, newWeaponName, level, quality, weaponSlot);
	}

#if defined(MALLET_EXPERIMENTAL_WEAPON_SPAWN_LOGIC)
	int weapon = SDKCall(hGiveNamedItem, client, weaponName, 0);
#else
	int weapon = CreateEntityByName(weaponName);
#endif
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

#if defined(MALLET_EXPERIMENTAL_WEAPON_SPAWN_LOGIC)
	return weapon;
#else
	if (!DispatchSpawn(weapon))
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}
	else
	{
		return weapon;
	}
#endif
}

void InternalRemoveExtraWearables(int weaponEntity)
{
	int hExtraWearable = GetEntPropEnt(weaponEntity, Prop_Send, "m_hExtraWearable");

	if (hExtraWearable != -1)
	{
		TF2_RemoveWearable(GetEntPropEnt(hExtraWearable, Prop_Send, "m_hOwnerEntity"), hExtraWearable);
		SetEntPropEnt(weaponEntity, Prop_Send, "m_hExtraWearable", -1);
	}

	int hExtraWearableViewModel = GetEntPropEnt(weaponEntity, Prop_Send, "m_hExtraWearableViewModel");

	if (hExtraWearableViewModel != -1)
	{
		TF2_RemoveWearable(GetEntPropEnt(hExtraWearableViewModel, Prop_Send, "m_hOwnerEntity"), hExtraWearableViewModel);
		SetEntPropEnt(weaponEntity, Prop_Send, "m_hExtraWearableViewModel", -1);
	}
}

int InternalGetPlayerWearable(int client, int index)
{
	return -1;
}

int InternalGetWearableCount(int client)
{
	return 0;
}

int InternalRemoveItem(int client, int entity)
{
	if (Internal_IsWeapon(entity))
	{
		if (!RemovePlayerItem(client, entity))
		{
			return 0;
		}

		InternalRemoveExtraWearables(entity);
	}
	else if (Internal_IsWearable(entity))
	{
		TF2_RemoveWearable(client, entity);
	}

	MalletRemoveEntity(entity);
	return 1;
}

public int InternalRemoveAllWeapons(int client)
{
	for (int i = 0; i < GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons"); ++i)
	{
		int weaponEntity = GetPropEnt(Prop_Send, "m_hMyWeapons", i);

		if (weaponEntity == -1)
		{
			continue;
		}

		InternalRemoveItem(client, weaponEntity);
	}

	for (int i = InternalGetWearableCount(client) - 1; i >= 0; i--)
	{
		int wearableEntity = InternalGetPlayerWearable(client, i);

		if (wearableEntity == -1)
		{
			continue;
		}

		InternalRemoveItem(client, wearableEntity);
	}

	return 1;
}

/* native int MalletRemoveAllWeapon(int client) */
public int Native_RemoveAllWeapons(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return -1;
	}

	return InternalRemoveAllWeapons(client);
}

/* native int MalletRemoveWeapon(int client, int wearable) */
public int Native_RemoveWeapon(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return -1;
	}

	int entity = GetNativeCell(2);

	return InternalRemoveItem(client, entity);
}

/* native int MalletIsWeapon(int entity) */
public int Native_IsWeapon(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	
	return Internal_IsWeapon(entity);
}

bool Internal_IsWeapon(int entity)
{
	if (entity <= MaxClients || !IsValidEntity(entity))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%d is an invalid entity", entity);
	}

	return SDKCall(hSDKIsWeapon, entity);
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
	
	SDKCall(hSDKRemoveWearable, client, wearable);
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

/* native int MalletCreateWeapon(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot) */
public int Native_CreateWeapon(Handle plugin, int numParams)
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

	return InternalCreateWeapon(client, weaponId, weaponName, level, quality, weaponSlot);
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