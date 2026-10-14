
/**
 * Based upon FlamingSarge's "tf2attributes".
 * (https://github.com/FlaminSarge/tf2attributes/)
 * 
 * Very special thanks to "Malifox" on the AlliedModders Discord for help and a copy of a work-in-progress tf2attributes for x64.
 */

#include <sdktools>
#include <sourcemod>

#include "mallet_defines.inc"
#include "mallet_utils.inc"

Handle hSDKSetRuntimeValue = INVALID_HANDLE;
Handle hSDKGetAttributeDef = INVALID_HANDLE;
Handle hSDKGetAttributeDefByName = INVALID_HANDLE;
Handle hSDKGetAttributeList = INVALID_HANDLE;
Handle hSDKRemoveAttribute = INVALID_HANDLE;
Handle hSDKDestroyAllAttributes = INVALID_HANDLE;
Handle hSDKOnAttributeValuesChanged = INVALID_HANDLE;
Handle hSDKSchema = INVALID_HANDLE;

#define ATTRIBUTE_MANAGER (INTPTR_S + 3 * INTPTR_S + 8)

#if defined(MALLET_HAS_VIRTUALADDRESS)
#define SDKType_MalletPointer SDKType_Address
#else
#define SDKType_MalletPointer SDKType_PlainOldData
#endif

#if defined(_X64_IMPLEMENTATION_PORT64)
#include <port64>
#endif

public bool InitializeAttributes()
{
	Handle hGameConf = LoadGameConfigFile("tf2.mallet");
	if (hGameConf == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to find the gamedata config handle!");
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GEconItemSchema");
	PrepSDKCall_SetReturnInfo(SDKType_Pointer, SDKPass_Plain);	// Returns address of CEconItemSchema
	hSDKSchema = EndPrepSDKCall();
#else
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GEconItemSchema");
	PrepSDKCall_SetReturnInfo(SDKType_MalletPointer, SDKPass_Plain); // Returns address of CEconItemSchema
	hSDKSchema = EndPrepSDKCall();
#endif	
	if (hSDKSchema == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into GEconItemSchema!")
		return false;
	}

    /**
	 * This one was immune to x64 changes,
	 * however SourceMod was* deathly afraid of introducing
	 * new interfaces to handle 64-bit addresses, 
	 * so now it's my fucking problem.
	 */
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CAttributeList::SetRuntimeAttributeValue");
	PrepSDKCall_AddParameter(SDKType_MalletPointer, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	hSDKSetRuntimeValue = EndPrepSDKCall();
	
	if (hSDKSetRuntimeValue == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CAttributeList::SetRuntimeAttributeValue!")
		return false;
	}

	
#if defined(_X64_IMPLEMENTATION_PORT64)
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Pointer, SDKPass_Plain);	// Returns address of a CEconItemAttributeDefinition
	hSDKGetAttributeDef = EndPrepSDKCall();
#else
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_MalletPointer, SDKPass_Plain);  // Returns address of a CEconItemAttributeDefinition
	hSDKGetAttributeDef = EndPrepSDKCall();
#endif
	
	if (hSDKGetAttributeDef == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CEconItemSchema::GetAttributeDefinition!")
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinitionByName");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Pointer, SDKPass_Plain);	// Returns address of a CEconItemAttributeDefinition
#else
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinitionByName");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_MalletPointer, SDKPass_Plain);	// Returns address of a CEconItemAttributeDefinition
#endif
	hSDKGetAttributeDefByName = EndPrepSDKCall();

	if (hSDKGetAttributeDefByName == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CEconItemSchema::GetAttributeDefinitionByName");
		return false;
	}
	
#if defined(_X64_IMPLEMENTATION_PORT64)
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CEconEntity::GetAttributeList");
	PrepSDKCall_SetReturnInfo(SDKType_Pointer, SDKPass_Plain);
	hSDKGetAttributeList = EndPrepSDKCall();
#else
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CEconEntity::GetAttributeList");
	PrepSDKCall_SetReturnInfo(SDKType_MalletPointer, SDKPass_Plain);
	hSDKGetAttributeList = EndPrepSDKCall();
#endif

	if (hSDKGetAttributeList == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CEconEntity::GetAttributeList!")
		return false;
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CAttributeList::RemoveAttribute");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	hSDKRemoveAttribute = EndPrepSDKCall();

	if (hSDKRemoveAttribute == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CAttributeList::RemoveAttribute!");
		return false;
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CAttributeList::DestroyAllAttributes");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hSDKDestroyAllAttributes = EndPrepSDKCall();

	if (hSDKDestroyAllAttributes == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CAttributeList::DestroyAllAttributes!")
		return false;
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CAttributeManager::OnAttributeValuesChanged");
	hSDKOnAttributeValuesChanged = EndPrepSDKCall();

	if (hSDKOnAttributeValuesChanged == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CAttributeManager::OnAttributeValuesChanged!")
		return false;
	}

	delete hGameConf;
	return true;
}

#if defined(_X64_IMPLEMENTATION_PORT64)
static void GetItemSchema(any pSchema[2])
{
	SDKCall(hSDKSchema, pSchema);
}

/**
 * Sets this to entity address + the m_AttributeList offset.  This does not correspond to the CUtlVector instance
 * (which is offset by 0x08).
 */
void GetEntityAttributeList(any list[2], int entity)
{
	int address[2];

	/* Get our entity address. */
	Port64_GetEntityAddress(entity, address, 0);

	/* Call CEconEntity::GetAttributeList() and store the offset. */
	SDKCall(hSDKGetAttributeList, address, list);	
}

void GetByID(any econ[2], int id)
{
	int pSchema[2];
	GetItemSchema(pSchema);

	if (!pSchema[0])
		return;

	SDKCall(hSDKGetAttributeDef, pSchema, econ, id);
}

static void GetAttributeManager(any manager[2], any pEntAttributeList[2])
{
	Port64_LoadFromAddress(pEntAttributeList, ATTRIBUTE_MANAGER, NumberType_Int64, manager);
}
#else
static Address GetItemSchema()
{
#if defined(MALLET_HAS_VIRTUALADDRESS)
	Address pSchema;
	SDKCall(hSDKSchema, pSchema);
	return pSchema;
#else
	return SDKCall(hSDKSchema);
#endif
}

static Address GetAttributeDefinitionByID(int id)
{
#if defined MALLET_DEBUG
	PrintToServer("[Mallet] GetAttributeDefinitionByID(%d), fetching item schema...", id);
#endif

	Address pSchema = GetItemSchema();

#if defined MALLET_DEBUG
	PrintToServer("[Mallet] hSDKGetAttributeDef(0x%08X, %d)", pSchema, id);
#endif

	if (pSchema == Address_Null)
	{
		return Address_Null;
	} 
	else
	{
#if defined(MALLET_HAS_VIRTUALADDRESS)
		Address pAttrDef;
		SDKCall(hSDKGetAttributeDef, pSchema, pAttrDef, id);
		return pAttrDef;
#else
		return SDKCall(hSDKGetAttributeDef, pSchema, id);
#endif
	}	
}

/**
 * Returns the m_AttributeList offset.  This does not correspond to the CUtlVector instance
 * (which is offset by 0x04).
 */
static Address GetEntityAttributeList(int entity)
{
#if defined MALLET_DEBUG
	PrintToServer("[Mallet] GetEntityAttributeList(%d)", entity);
#endif
	int offsAttributeList = GetEntSendPropOffs(entity, "m_AttributeList", true);
	if (offsAttributeList > 0)
	{
		return GetEntityAddress(entity) + view_as<Address>(offsAttributeList);
	}
	else
	{
		return Address_Null;
	}
}

static Address GetAttributeManager(Address pEntAttributeList)
{
#if defined MALLET_DEBUG
	PrintToServer("[Mallet] GetAttributeManager(0x%08X)", pEntAttributeList);
#endif
	if (pEntAttributeList == Address_Null)
	{
		return Address_Null;
	}
	else
	{
#if defined(MALLET_HAS_VIRTUALADDRESS)
		return LoadAddressFromAddress(pEntAttributeList + ATTRIBUTE_MANAGER);
#else
		return LoadFromAddress(pEntAttributeList + view_as<Address>(ATTRIBUTE_MANAGER), NumberType_Int32);
#endif
	}
}
#endif

#if defined(_X64_IMPLEMENTATION_PORT64)
void InternalFlushAttributes(int pEntAttributeList[2])
#else
void InternalFlushAttributes(Address pEntAttributeList)
#endif
{
#if defined(_X64_IMPLEMENTATION_PORT64)
	int pAttributeManager[2];
	GetAttributeManager(pEntAttributeList, pAttributeManager);
	if (pAttributeManager[0])
#else
	Address pAttributeManager = GetAttributeManager(pEntAttributeList);
	if (pAttributeManager != Address_Null)
#endif
	{
		SDKCall(hSDKOnAttributeValuesChanged, pAttributeManager);
	}
}

bool InternalDeleteAllAttributes(int iEntity)
{
	if (!IsValidEntity(iEntity))
	{
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalDeleteAllAttributes: Rejecting call due to invalid entity %i.", iEntity);
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEntAttributeList[2];
	GetEntityAttributeList(pEntAttributeList, iEntity);

	if (!pEntAttributeList[0])
	{
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalDeleteAllAttributes: GetEntityAttributeList returned NULL.");
#endif
		return false;
	}

	SDKCall(hSDKDestroyAllAttributes, pEntAttributeList);
#else
	Address pEntAttributeList = GetEntityAttributeList(iEntity);

	if (pEntAttributeList == Address_Null)
	{
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalDeleteAllAttributes: GetEntityAttributeList returned NULL.");
#endif
		return false;
	}

	SDKCall(hSDKDestroyAllAttributes, pEntAttributeList);
#endif
	return true;
}

bool InternalSetAttribute(int iEntity, int iDefIndex, float flValue)
{
	if (!IsValidEntity(iEntity))
	{
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalSetAttribute: Rejecting call due to invalid entity %i.", iEntity);
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEntAttributeList[2];
	GetEntityAttributeList(pEntAttributeList, iEntity);

	if (!pEntAttributeList[0])
	{
#else
	Address pEntAttributeList = GetEntityAttributeList(iEntity);

	if (pEntAttributeList == Address_Null)
	{
#endif
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalSetAttribute: GetEntityAttributeList returned NULL.");
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEconItemAttributeDefinition[2];

	GetByID(pEconItemAttributeDefinition, iDefIndex);

	if (!pEconItemAttributeDefinition[0])
	{
#else
	Address pAttribDef = GetAttributeDefinitionByID(iDefIndex);
	if (pAttribDef == Address_Null)
	{
#endif
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalSetAttribute: GetAttributeDefinitionByID returned NULL.");
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	SDKCall(hSDKSetRuntimeValue, pEntAttributeList, pEconItemAttributeDefinition, flValue);
#else
	SDKCall(hSDKSetRuntimeValue, pEntAttributeList, pAttribDef, flValue);
#endif
	return true;
}

bool InternalRemoveAttribute(int iEntity, int iDefIndex)
{
	if (!IsValidEntity(iEntity))
	{
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalRemoveAttribute: Rejecting call due to invalid entity %i.", iEntity);
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEntAttributeList[2];
	GetEntityAttributeList(pEntAttributeList, iEntity);

	if (!pEntAttributeList[0])
	{
#else
	Address pEntAttributeList = GetEntityAttributeList(iEntity);

	if (pEntAttributeList == Address_Null)
	{
#endif
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalRemoveAttribute: Rejecting call due to missing attribute list");
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEconItemAttributeDefinition[2];

	GetByID(pEconItemAttributeDefinition, iDefIndex);

	if (!pEconItemAttributeDefinition[0])
	{
#else
	Address pEconItemAttributeDefinition = GetAttributeDefinitionByID(iDefIndex);
	if (pEconItemAttributeDefinition == Address_Null)
	{
#endif
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalRemoveAttribute: Rejecting call due to missing attribute def.");
#endif
		return false;
	}

	SDKCall(hSDKRemoveAttribute, pEntAttributeList, pEconItemAttributeDefinition);
	return true;
}

bool InternalTryFlushAttributes(int iEntity)
{
	if (!IsValidEntity(iEntity))
	{
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalTryFlushAttributes: Rejecting call due to invalid entity %i.", iEntity);
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEntAttributeList[2];
	GetEntityAttributeList(pEntAttributeList, iEntity);

	if (!pEntAttributeList[0])
	{
#else
	Address pEntAttributeList = GetEntityAttributeList(iEntity);

	if (pEntAttributeList == Address_Null)
	{
#endif
#if defined MALLET_DEBUG
		PrintToServer("[Mallet->Attributes] InternalTryFlushAttributes: Rejecting call due to missing attribute list");
#endif
		return false;
	}

	InternalFlushAttributes(pEntAttributeList);
	return true;
}

/* native bool MalletDeleteAllAttributes(int iEntity) */
public int Native_DeleteAllAttributes(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int iEntity = GetNativeCell(1);

#if defined MALLET_DEBUG
	PrintToServer("[Mallet->Attributes] DeleteAllAttributes()={iEntity=%i}", iEntity);
#endif
	return InternalDeleteAllAttributes(iEntity);
}

/* native bool MalletRemoveAttribute(int iEntity, int iDefIndex, bool lazy=false) */
public int Native_RemoveAttribute(Handle plugin, int numParams)
{
	if (numParams != 2)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int iEntity = GetNativeCell(1);
	int iDefIndex = GetNativeCell(2);

#if defined MALLET_DEBUG
	PrintToServer("[Mallet->Attributes] RemoveAttribute()={iEntity=%i, iDefIndex=%i}", iEntity, iDefIndex);
#endif
	return InternalRemoveAttribute(iEntity, iDefIndex);
}

/* native bool MalletSetAttribute(int iEntity, int iDefIndex, float flValue) */
public int Native_SetAttribute(Handle plugin, int numParams)
{
	if (numParams != 3)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int iEntity = GetNativeCell(1);
	int iDefIndex = GetNativeCell(2);
	float flValue = view_as<float>(GetNativeCell(3));

#if defined MALLET_DEBUG
	PrintToServer("[Mallet->Attributes] SetAttribute()={iEntity=%i, iDefIndex=%i, flValue=%f}", iEntity, iDefIndex, flValue);
#endif
	return InternalSetAttribute(iEntity, iDefIndex, flValue);
}

/* native bool MalletFlushAttributes(int iEntity) */
public int Native_FlushAttributes(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int iEntity = GetNativeCell(1);

#if defined MALLET_DEBUG
	PrintToServer("[Mallet->Attributes] FlushAttributes()={iEntity=%i}", iEntity);
#endif

	return InternalTryFlushAttributes(iEntity);
}