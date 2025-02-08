static Handle hSDKIsWeapon = INVALID_HANDLE;

public bool InitializeWeaponsMisc()
{
	GameData hGameConf = new GameData("tf2.mallet");

	if (hGameConf == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to find the game data handle!")
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

	delete hGameConf;
	return true;
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

	RemoveEntity(entity);
	return 1;
}

public int InternalRemoveAllWeapons(int client)
{
	for (int i = 0; i < GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons"); ++i)
	{
		int weaponEntity = GetEntProp(client, Prop_Send, "m_hMyWeapons", _, i);

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

/* native int MalletSwapWeapon(int client, int weaponEntity, int slot) */
public int Native_SwapWeapon(Handle plugin, int numParams)
{
	if (numParams != 3)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return -1;
	}

	int weaponEntity = GetNativeCell(2);
	int slot = GetNativeCell(3);

	return InternalSwapWeapon(client, weaponEntity, slot);
}

int InternalSwapWeapon(int client, int weaponEntity, int slot)
{
	if (!IsValidEntity(weaponEntity))
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	int oldEntity = GetEntProp(client, Prop_Send, "m_hMyWeapons", _, slot);
	if (oldEntity == -1)
	{
		/**
		 * Technically this is the worldspawn entity,
		 * but you should be checking if the entity index is above zero anyways.
		 */
		return 0;
	}

	TF2_RemoveWeaponSlot(client, slot);
	EquipPlayerWeapon(client, weaponEntity);
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weaponEntity);

	return oldEntity;
}

/* native int MalletSwapWeaponAndPurge(int client, int weaponEntity, int slot) */
public int Native_SwapWeaponAndPurge(Handle plugin, int numParams)
{
	if (numParams != 3)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %d is invalid", client);
		return -1;
	}

	int weaponEntity = GetNativeCell(2);
	int slot = GetNativeCell(3);

	return InternalSwapWeaponAndPurge(client, weaponEntity, slot);
}

bool InternalSwapWeaponAndPurge(int client, int weaponEntity, int slot)
{
	int oldWeapon = InternalSwapWeapon(client, weaponEntity, slot);

	/* Sometimes we can *not* have a weapon, don't return false. */
	if (oldWeapon)
	{
		RemoveEntity(oldWeapon);
	}

	return true;
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