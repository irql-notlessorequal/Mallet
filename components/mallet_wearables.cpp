#include "mallet_wearables.h"
#include "MalletUtils.h"
#include "smsdk_ext.h"
#include "sourcehook.h"
#include "hl2sdk-tf2/public/server_class.h"

variant_t g_Variant_t;
int iAcceptInput = -1;
int iRemoveWearable = -1;
int iEquipWearable = -1;
int iIsWearable = -1;

SH_DECL_MANUALHOOK5(MHook_AcceptInput, 0, 0, 0, bool, const char*, CBaseEntity*, CBaseEntity*, variant_t, int);
SH_DECL_MANUALHOOK1_void(MHook_RemoveWearable, 0, 0, 0, CBaseEntity*);
SH_DECL_MANUALHOOK1_void(MHook_EquipWearable, 0, 0, 0, CBaseEntity*);
SH_DECL_MANUALHOOK0(MHook_IsWearable, 0, 0, 0, bool);

bool MalletWearables::TypeIsWearable(const char *name)
{
	return
		strcmp(name, "tf_wearable") == 0 ||
		strcmp(name, "tf_wearable_demoshield") == 0 ||
		strcmp(name, "tf_wearable_razorback") == 0 ||
		strcmp(name, "tf_powerup_bottle") == 0;
}

bool MalletWearables::load(SourceMod::IGameConfig *g_pGameConf)
{
	if (!g_pGameConf->GetOffset("CBaseEntity::IsWearable", &iIsWearable))
	{
		ConMsg("\"CBaseEntity::IsWearable\" couldn't be found!\n");
		return false;
	}
	else
	{
		SH_MANUALHOOK_RECONFIGURE(MHook_IsWearable, iIsWearable, 0, 0);
	}

	return false;
}

cell_t MalletWearables::MalletIsWearable(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	int entity = params[1];
	if (!MalletUtils::IsValidEntity(entity))
	{
		return pContext->ThrowNativeError("Got an invalid entity...");
	}

	return SH_MCALL(gamehelpers->ReferenceToEntity(entity), MHook_IsWearable)();
}

static inline CBaseEntity* InternalCreateWearable(int client, int weaponId, const char* weaponName)
{
	CBaseEntity* entity = servertools->CreateEntityByName(weaponName);
	if (!entity)
	{
		return nullptr;
	}

	servertools->SetKeyValue(entity, "m_iItemDefinitionIndex", weaponId);

	/**
	 * TODO:
	 * We don't call PrecacheModel() here, this'll likely cause problems
	 * later down the line.
	 */
	switch (weaponId)
	{
		/* The Chargin' Targe */
		case 131:
		{
			servertools->SetKeyValue(entity, "m_nModelIndexOverrides", "models/weapons/c_models/c_targe/c_targe.mdl");
			break;
		}

		/* The Splendid Screen */
		case 406:
		{
			servertools->SetKeyValue(entity, "m_nModelIndexOverrides", "models/weapons/c_models/c_persian_shield/c_persian_shield_all.mdl");
			break;
		}

		/* The Tide Turner */
		case 1099:
		{
			servertools->SetKeyValue(entity, "m_nModelIndexOverrides", "models/workshop/weapons/c_models/c_wheel_shield/c_wheel_shield.mdl");
			break;
		}

		/* Festive Targe */
		case 1044:
		{
			servertools->SetKeyValue(entity, "m_nModelIndexOverrides", "models/weapons/c_models/c_targe/c_targe_xmas.mdl");
			break;
		}

		default: break;
	}

	servertools->SetKeyValue(entity, "m_hOwnerEntity", client);
	servertools->SetKeyValue(entity, "m_bInitialized", true);
	servertools->SetKeyValue(entity, "m_bValidatedAttachedEntity", true);

	/**
	 * DispatchSpawn always returns TRUE
	 * in SourceMod since the Orange Box, lol.
	 */
	servertools->DispatchSpawn(entity);

	return entity;
}

cell_t MalletWearables::MalletCreateWearable(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 3)
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

	CBaseEntity* wearable = InternalCreateWearable(client, weaponId, weaponName);
	if (!wearable)
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	/**
	 * Do NOT equip the wearable, we require the user to
	 * call `MalletEquipWearable` if they wish to do so.
	 */
	return gamehelpers->EntityToReference(wearable);
}

cell_t MalletWearables::MalletEquipWearable(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 2)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	CBaseEntity* client;
	if (!MalletUtils::GetAndCheckValidClient(params[1], &client))
	{
		return pContext->ThrowNativeError("Invalid client reference (%i)", params[1]);
	}

	CBaseEntity* entity;
	if (!MalletUtils::GetAndCheckValidEntity(params[2], &entity))
	{
		return pContext->ThrowNativeError("Invalid entity reference (%i)", params[2]);
	}

	SH_MCALL(client, MHook_EquipWearable)(entity);
	return true;
}

cell_t MalletWearables::MalletRemoveWearable(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 2)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	CBaseEntity* client;
	if (!MalletUtils::GetAndCheckValidClient(params[1], &client))
	{
		return pContext->ThrowNativeError("Invalid client reference (%i)", params[1]);
	}

	CBaseEntity* entity;
	if (!MalletUtils::GetAndCheckValidEntity(params[2], &entity))
	{
		return pContext->ThrowNativeError("Invalid entity reference (%i)", params[2]);
	}

	SH_MCALL(client, MHook_RemoveWearable)(entity);
	return true;
}

static inline bool AcceptEntityInput(CBaseEntity* entity, const char* command)
{
	return SH_MCALL(entity, MHook_AcceptInput)(command, NULL, NULL, g_Variant_t, 0);
}

static inline void IterateAndRemoveFor(CBaseEntity* client, const char* name)
{
	CBaseEntity* wearable = nullptr;
	while ((wearable = servertools->FindEntityByClassname(wearable, name)) != nullptr)
	{
		int offset;
		int bit_count;

		sm_sendprop_info_t info;
		SendProp *pProp;

		ServerClass *pServerClass = gamehelpers->FindEntityServerClass(wearable);
		if (!pServerClass)
		{
			continue;
		}

		if (!gamehelpers->FindSendPropInfo(pServerClass->GetName(), "m_hOwnerEntity", &info))
		{
			continue;
		}

		offset = info.actual_offset;
		pProp = info.prop;
		bit_count = pProp->m_nBits;

		CBaseHandle *hndl = (CBaseHandle *)((uint8_t *)wearable + offset);
		CBaseEntity *pHandleEntity = gamehelpers->ReferenceToEntity(hndl->GetEntryIndex());

		if (!pHandleEntity || *hndl != reinterpret_cast<IHandleEntity *>(pHandleEntity)->GetRefEHandle())
		{
			continue;
		}

		if (pHandleEntity == client)
		{
			SH_MCALL(client, MHook_RemoveWearable)(wearable);
			AcceptEntityInput(wearable, "Kill");
		}
	}
}

cell_t MalletWearables::MalletRemoveAllWearables(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	CBaseEntity* client;
	if (!MalletUtils::GetAndCheckValidClient(params[1], &client))
	{
		return pContext->ThrowNativeError("Invalid client reference (%i)", params[1]);
	}

	IterateAndRemoveFor(client, "tf_wearable*");
	IterateAndRemoveFor(client, "tf_powerup_bottle");
	IterateAndRemoveFor(client, "tf_weapon_spellbook");

	return true;
}
