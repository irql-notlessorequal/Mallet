#include "mallet_attributes.h"
#include "components/MalletUtils.h"
#include "smsdk_ext.h"
#include "sourcehook.h"

class CEconItemSchema;
typedef CEconItemSchema* (*FUNC_GET_ECON_ITEM_SCHEMA)(void);

static void* GEconItemSchema = nullptr;
SH_DECL_MANUALHOOK0(CEconEntity_GetAttributeList, 0, 0, 0, void*);
SH_DECL_MANUALHOOK0(CTFPlayer_GetAttributeList, 0, 0, 0, void*);
/* */
SH_DECL_MANUALHOOK1(MHook_SDKGetAttributeDef, 0, 0, 0, void*, int);
SH_DECL_MANUALHOOK2_void(MHook_SetRuntimeAttributeValue, 0, 0, 0, void*, float);

bool MalletAttributes::load(SourceMod::IGameConfig *g_pGameConf)
{
	/* TODO */
	return false;
}

static inline bool IsReferenceAPlayer(int reference)
{
	return 1 <= reference <= playerhelpers->GetMaxClients();
}

static inline CEconItemSchema* GetItemSchema()
{
	FUNC_GET_ECON_ITEM_SCHEMA schema = (FUNC_GET_ECON_ITEM_SCHEMA)GEconItemSchema;
	return schema();
}

static inline void* GetEntityAttributeList(CBaseEntity* entity, bool isPlayer)
{
	if (isPlayer)
	{
		return SH_MCALL(entity, CTFPlayer_GetAttributeList)();
	}
	else
	{
		return SH_MCALL(entity, CEconEntity_GetAttributeList)();
	}
}

static inline void* GetAttributeDefinitionByID(int id)
{
	CEconItemSchema* pSchema = GetItemSchema();
	if (!pSchema)
		return nullptr;

	return SH_MCALL(pSchema, MHook_SDKGetAttributeDef)(id);
}

cell_t MalletAttributes::MalletSetAttribute(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 3)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	CBaseEntity* entity;
	if (!MalletUtils::GetAndCheckValidEntity(params[1], &entity))
	{
		return pContext->ThrowNativeError("Got an invalid entity...");
	}

	int iDefIndex = params[2];
	if (iDefIndex <= 0)
	{
		return pContext->ThrowNativeError("Requested an invalid attribute.");
	}

	float flValue = static_cast<float>(params[3]);

	/**
	 * Hopefully I can get away
	 * with using raw pointers...
	 */
	void* pEntAttributeList = GetEntityAttributeList(entity, IsReferenceAPlayer(params[1]));
	if (!pEntAttributeList)
	{
		return pContext->ThrowNativeError("GetEntityAttributeList returned NULL.");
	}

	void* pAttribDef = GetAttributeDefinitionByID(iDefIndex);
	if (!pAttribDef)
	{
		return pContext->ThrowNativeError("GetAttributeDefinitionByID returned NULL.");
	}

	SH_MCALL(pEntAttributeList, MHook_SetRuntimeAttributeValue)(pAttribDef, flValue);
	return true;
}
