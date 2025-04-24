//
// Created by rake on 22.04.25.
//
#include "MalletUtils.h"

#include "IHandleSys.h"
#include <utlvector.h>

class CBasePlayer;
class CEconItem;
class ITexture;
class ITextureCompositor;

SH_DECL_MANUALHOOK4(MHook_GiveNamedItem, 0, 0, 0, CBaseEntity *, char const *, int, CEconItemView *, bool);

template< class T, class I = int >
class CUtlMemoryTF2Items : public CUtlMemory< T, I >
{
public:
	CUtlMemoryTF2Items( int nGrowSize = 0, int nInitSize = 0 ) { CUtlMemory< T, I >( nGrowSize, nInitSize ); }
    CUtlMemoryTF2Items( T* pMemory, int numElements ) { CUtlMemory< T, I >( pMemory, numElements ); }
    CUtlMemoryTF2Items( const T* pMemory, int numElements ) { CUtlMemory< T, I >( pMemory, numElements ); }
    //~CUtlMemoryTF2Items() { ~CUtlMemory< T, I >(); }

	void Purge()
	{
		if ( !CUtlMemory< T, I >::IsExternallyAllocated() )
		{
			if (CUtlMemory< T, I >::m_pMemory)
			{
				UTLMEMORY_TRACK_FREE();
				CUtlMemory< T, I >::m_pMemory = 0;
			}
			CUtlMemory< T, I >::m_nAllocationCount = 0;
		}
	}
};

class CEconItemAttribute
{
public:
	void *m_pVTable; //0

	uint16 m_iAttributeDefinitionIndex; //4
	float m_flValue; //8
	int32 m_nRefundableCurrency; //12
};

class CEconItemHandle
{
public:
	void *m_pVTable;

	CEconItem *m_pItem;

	int64 m_ulItemID;
	uint64 m_SteamID;
};

class CAttributeList
{
public:
	void *m_pVTable;

	CUtlVector<CEconItemAttribute, CUtlMemoryTF2Items<CEconItemAttribute> > m_Attributes;
	void *m_pAttributeManager;


public:
	CAttributeList& operator=( const CAttributeList &other )
	{
		m_pVTable = other.m_pVTable;

		m_Attributes = other.m_Attributes;
		m_pAttributeManager = other.m_pAttributeManager;

		return *this;
	}
};

class CEconItemView
{
public:
	void *m_pVTable; //0

	uint16 m_iItemDefinitionIndex; //4 // 8

	int32 m_iEntityQuality; //8 // 12
	uint32 m_iEntityLevel; //12 // 16

	uint64 m_iItemID; //16 // 24
	uint32 m_iItemIDHigh; //24 // 32
	uint32 m_iItemIDLow; //28 // 36

	uint32 m_iAccountID; //32 // 40

	uint32 m_iInventoryPosition; //36 // 44

	CEconItemHandle m_ItemHandle; //40 (44, 48, 52, 56, 60) // 48

	bool m_bColorInit; //64 // 80
	bool m_bPaintOverrideInit; //65 // 81
	bool m_bHasPaintOverride; //66 // 82
	//67

	float m_flOverrideIndex; //68 // 84
	uint32 m_unRGB; //72 // 88
	uint32 m_unAltRGB; //76 // 92

	int32 m_iTeamNumber; //80 // 96

	bool m_bInitialized; //84 // 100

	CAttributeList m_AttributeList; //88 (92, 96, 100, 104, 108, 112) // 104
	CAttributeList m_NetworkedDynamicAttributesForDemos; //116 (120, 124, 128, 132, 136, 140) // 152

	bool m_bDoNotIterateStaticAttributes; //144 // 200
};

#ifdef INTPTR_MAX == INT64_MAX
static_assert(sizeof(CEconItemView) == 208, "CEconItemView - incorrect size on this compiler");
static_assert(sizeof(CEconItemHandle) == 32, "CEconItemHandle - incorrect size on this compiler");
static_assert(sizeof(CAttributeList) == 48, "CAttributeList - incorrect size on this compiler");
#else
static_assert(sizeof(CEconItemView) == 148, "CEconItemView - incorrect size on this compiler");
static_assert(sizeof(CEconItemHandle) == 24, "CEconItemHandle - incorrect size on this compiler");
static_assert(sizeof(CAttributeList) == 28, "CAttributeList - incorrect size on this compiler");
#endif

struct TScriptedItemOverride
{
	uint8 m_bFlags;									// Flags to what we should override.
	char m_strWeaponClassname[256];					// Classname to override the GiveNamedItem call with.
	uint32 m_iItemDefinitionIndex;					// New Item Def. Index.
	uint8 m_iEntityQuality;							// New Item Quality Level.
	uint8 m_iEntityLevel;							// New Item Level.
	uint8 m_iCount;									// Count of Attributes.
	CEconItemAttribute m_Attributes[16];			// The actual attributes.
};

class TScriptedItemOverrideTypeHandler : public IHandleTypeDispatch
{
public:
	void OnHandleDestroy(HandleType_t type, void *object);
};

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

static cell_t Internal_MalletCreateWeapon_Econ(SourcePawn::IPluginContext *pContext,
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
