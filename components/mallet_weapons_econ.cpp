#include "mallet_weapons_econ.h"

int iGiveNamedItem = -1;
SH_DECL_MANUALHOOK4(MHook_GiveNamedItem, 0, 0, 0, CBaseEntity *, char const *, int, CEconItemView *, bool);

void *g_pVTable = nullptr;
void *g_pVTable_Attributes = nullptr;

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
	}
	else if (p_bOnlyPlayers)
	{
		return NULL;
	}

	IServerUnknown *pUnk = edtEdict->GetUnknown();
	if (pUnk == NULL)
	{
		return NULL;
	}

	return pUnk->GetBaseEntity();
}

bool MalletWeapons::loadEcon(SourceMod::IGameConfig *g_pGameConf)
{
	if (!g_pGameConf->GetOffset("GiveNamedItem", &iGiveNamedItem))
	{
		g_pSM->LogMessage(myself, "\"GiveNamedItem\" couldn't be found!");
		return false;
	} else {
		SH_MANUALHOOK_RECONFIGURE(MHook_GiveNamedItem, iGiveNamedItem, 0, 0);
		g_pSM->LogMessage(myself, "\"GiveNamedItem\" offset = %d", iGiveNamedItem);
	}
}

cell_t MalletWeapons::Internal_MalletCreateWeapon_Econ(IPluginContext *pContext,
	int client, int weaponId, const char* weaponName, int level, int quality, int weaponSlot, int flags)
{
	CBaseEntity *pEntity;
	if ((pEntity = GetCBaseEntityFromIndex(client, true)) == nullptr)
	{
		return pContext->ThrowNativeError("Client index %d is not valid", client);
	}

	CEconItemView hCreatedItem;
	memset(&hCreatedItem, 0, sizeof(CEconItemView));

	/**
	 * Initialize the vtable pointers
	 */
	hCreatedItem.m_pVTable = g_pVTable;
	hCreatedItem.m_AttributeList.m_pVTable = g_pVTable_Attributes;
	hCreatedItem.m_NetworkedDynamicAttributesForDemos.m_pVTable = g_pVTable_Attributes;

	/**
	 * Configure the item.
	 */
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
		/**
		 * TODO: Equip the weapon onto the player.
		 */
		return gamehelpers->EntityToBCompatRef(ret);
	}
}
