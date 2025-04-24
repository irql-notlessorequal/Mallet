#include "mallet_weapons_econ.h"

SH_DECL_MANUALHOOK4(MHook_GiveNamedItem, 0, 0, 0, CBaseEntity *, char const *, int, CEconItemView *, bool);

inline CBaseEntity *GetCBaseEntityFromIndex(int p_iEntity, bool p_bOnlyPlayers)
{
	edict_t *edtEdict = engine->PEntityOfEntIndex(p_iEntity);
	if (!edtEdict || edtEdict->IsFree())
	{
		return NULL;
	}
	
	if (p_iEntity > 0 && p_iEntity <= playerhelpers->GetMaxClients())
	{
		IGamePlayer *pPlayer = playerhelpers->GetGamePlayer(edtEdict);

		if (!pPlayer || !pPlayer->IsConnected())
		{
			return NULL;
		}
	} else if (p_bOnlyPlayers) {
		return NULL;
	}

	IServerUnknown *pUnk = edtEdict->GetUnknown();
	if (pUnk == NULL)
	{
		return NULL;
	}

	return pUnk->GetBaseEntity();
}

cell_t MalletWeapons::Internal_MalletCreateWeapon_Econ(IPluginContext *pContext,
	int client, int weaponId, const char* weaponName, int level, int quality, int weaponSlot, int flags)
{
	CBaseEntity *pEntity;
	if ((pEntity = GetCBaseEntityFromIndex(client, true)) == nullptr)
	{
		return pContext->ThrowNativeError("Client index %d is not valid", client);
	}

	TScriptedItemOverride *pScriptedItemOverride = nullptr;
	if (pScriptedItemOverride == nullptr)
	{
		return -1;
	}

	CEconItemView hCreatedItem;
	memset(&hCreatedItem, 0, sizeof(CEconItemView));

	hCreatedItem.m_iItemDefinitionIndex = weaponId;
	hCreatedItem.m_iEntityLevel = level;
	hCreatedItem.m_iEntityQuality = quality;
	hCreatedItem.m_bInitialized = true;

	if ((flags & MALLET_WEAPON_FLAG_PRESERVE_ATTRIBUTES))
	{
		hCreatedItem.m_bDoNotIterateStaticAttributes = true;
	}

	CBaseEntity *ret = SH_MCALL(pEntity, MHook_GiveNamedItem)
		(weaponName, 0, &hCreatedItem, (flags & MALLET_WEAPON_FLAG_FORCE_GENERATION));
	if (!ret)
	{
		return MALLET_ERROR_FAILED_TO_SPAWN;
	}
	else
	{
		return gamehelpers->EntityToBCompatRef(ret);
	}
}
