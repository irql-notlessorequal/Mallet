#include "mallet_weapons.h"
#include "components/MalletUtils.h"
#include "hl2sdk-tf2/public/server_class.h"
#include "smsdk_ext.h"

cell_t MalletWeapons::MalletCreateWeapon(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) < 6 || PARAM_COUNT(params) > 7)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	int client = params[1];
	int weaponId = params[2];

	char* weaponName;
	int err;
	if ((err = pContext->LocalToString(params[3], &weaponName)) != SP_ERROR_NONE)
	{
		return pContext->ThrowNativeErrorEx(err, NULL);
	}

	int level = params[4];
	int quality = params[5];
	int weaponSlot = params[6];

	int flags = 0;
	if (PARAM_COUNT(params) == 7)
	{
		flags = params[7];
	}

	if ((flags & MALLET_WEAPON_FLAG_FORCE_DUMB))
	{
		return MalletWeapons::Internal_MalletCreateWeapon_Dumb(pContext, client, weaponId, weaponName, level, quality, weaponSlot, flags);
	}
	else
	{
		return MalletWeapons::Internal_MalletCreateWeapon_Econ(pContext, client, weaponId, weaponName, level, quality, weaponSlot, flags);
	}
}

cell_t MalletWeapons::MalletIsWeapon(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	/**
     * TODO
     */
	return MALLET_ERROR_GENERAL_ERROR;
}

cell_t MalletWeapons::MalletSwapWeapon(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 3)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	CBaseEntity* client;
	if (!MalletUtils::GetAndCheckValidClient(params[1], &client))
	{
		return pContext->ThrowNativeError("Invalid client reference (%i)", params[1]);
	}

	CBaseEntity* weapon;
	if (!MalletUtils::GetAndCheckValidEntity(params[2], &weapon))
	{
		return pContext->ThrowNativeError("Invalid weapon reference (%i)", params[2]);
	}

	int offset;
	int bit_count;
	sm_sendprop_info_t info;
	SendProp *pProp;

	ServerClass *pServerClass = gamehelpers->FindEntityServerClass(client);
	if (!pServerClass)
	{
		return pContext->ThrowNativeError("FindEntityServerClass returned NULL..");
	}

	if (!gamehelpers->FindSendPropInfo(pServerClass->GetName(), "m_hMyWeapons", &info))
	{
		return pContext->ThrowNativeError("Failed to find 'm_hMyWeapons' in the client entity.");
	}

	offset = info.actual_offset;
	pProp = info.prop;
	bit_count = pProp->m_nBits;

	CBaseHandle *hndl = (CBaseHandle *)((uint8_t *)client + offset);
	if (!hndl)
	{
		return pContext->ThrowNativeError("Failed to access the 'm_hMyWeapons' address..");
	}

	MalletWeapons::MalletEquipWeapon(client, weapon);
	/* TODO: SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weaponEntity); */

	return hndl->GetEntryIndex();
}

cell_t MalletWeapons::MalletGetItemOwner(IPluginContext *pContext, const cell_t *params)
{
	return pContext->ThrowNativeError("TODO");
}
