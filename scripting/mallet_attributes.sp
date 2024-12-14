
/**
 * Based upon FlamingSarge's "tf2attributes".
 * (https://github.com/FlaminSarge/tf2attributes/)
 * 
 * Very special thanks to "Malifox" on the AlliedModders Discord for help and a copy of a work-in-progress tf2attributes for x64.
 */

#include <sdktools>

#include "mallet_defines.sp"
#include "mallet_utils.sp"

Handle hSDKSetRuntimeValue = INVALID_HANDLE;
Handle hSDKGetAttributeDef = INVALID_HANDLE;
Handle hSDKGetAttributeDefByName = INVALID_HANDLE;
Handle hSDKGetAttributeList = INVALID_HANDLE;
Handle hSDKDestroyAllAttributes = INVALID_HANDLE;
Handle hSDKSchema = INVALID_HANDLE;

#if defined(_X64_IMPLEMENTATION_PORT64)
#include <port64>

// CUtlVector offsets
enum m_Attributes_m_Memory // CUtlVector<CEconItemAttribute>
{
	Attributes_m_Memory_AttrIndex =	8,	// 0x08
	Attributes_m_Memory_sizeof =	24,	// 0x18
}

enum static_attrib_t64
{
	StaticAttrib_m_iAttributeDefinitionIndex =	0,	// 0x00
	StaticAttrib_m_flValue =					4,	// 0x04
	StaticAttrib_sizeof =						16,	// 0x10
}

// CAttributeList offsets
enum CAttributeList64
{
	AL_CUtlVector_m_Attributes_m_Memory = 	8,	// 0x08, CAttributeList.m_Attributes.m_Memory.m_pMemory
	AL_CUtlVector_m_Size =					24,	// 0x18, 4 bytes padding after this
	AL_CUtlVector_pAttrElement =			32,	// 0x20
	AL_m_pAttributeManager =				40,	// 0x28
}

// CEconItemAttributeDefinition offsets
enum CEconItemAttributeDefinition64
{
	AttrDef_m_nDefIndex =			8,	// 0x08
	AttrDef_m_pAttrType =			16,	// 0x10
	AttrDef_m_bStoredAsInteger =	26,	// 0x1A
}
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
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GEconItemSchema");
	PrepSDKCall_SetReturnInfo(SDKType_MemoryPointer, SDKPass_Plain);
	hSDKSchema = EndPrepSDKCall();
#else
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GEconItemSchema");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hSDKSchema = EndPrepSDKCall();
#endif	
	if (hSDKSchema == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into GEconItemSchema!")
		return false;
	}

    /* This one is immune to x64 changes. */
    StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CAttributeList::SetRuntimeAttributeValue");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
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
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_MemoryPointer, SDKPass_Plain);
	hSDKGetAttributeDef = EndPrepSDKCall();
#else
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hSDKGetAttributeDef = EndPrepSDKCall();
#endif
	
	if (hSDKGetAttributeDef == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CEconItemSchema::GetAttributeDefinition!")
		return false;
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinitionByName");
#if defined(_X64_IMPLEMENTATION_PORT64)
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Pointer, SDKPass_Plain);	// Returns address of a CEconItemAttributeDefinition
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
#warning "Should AddParameter be SDKPass_Pointer in MP?"
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_MemoryPointer, SDKPass_Plain);	// Returns address of a CEconItemAttributeDefinition
#else
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	// Returns address of a CEconItemAttributeDefinition
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
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CEconEntity::GetAttributeList");
	PrepSDKCall_SetReturnInfo(SDKType_MemoryPointer, SDKPass_Plain);
	hSDKGetAttributeList = EndPrepSDKCall();
#else
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CEconEntity::GetAttributeList");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hSDKGetAttributeList = EndPrepSDKCall();
#endif

	if (hSDKGetAttributeList == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CEconEntity::GetAttributeList!")
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

	delete hGameConf;
	return true;
}

#if defined(_X64_IMPLEMENTATION_PORT64)
static void GetItemSchema(any pSchema[2]) {
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
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
static MemoryPointer GetItemSchema() {
	return SDKCall(hSDKSchema);
}

/**
 * Sets this to entity address + the m_AttributeList offset.  This does not correspond to the CUtlVector instance
 * (which is offset by 0x08).
 */
MemoryPointer GetEntityAttributeList(int entity)
{
	/* Call CEconEntity::GetAttributeList() and store the offset. */
	return SDKCall(hSDKGetAttributeList, GetEntityMemoryPointer(entity));
}

MemoryPointer GetByID(int id)
{
	MemoryPointer schema = GetItemSchema();
	if (!schema)
		return;

	return SDKCall(hSDKGetAttributeDef, pSchema, id);
}
#else
static Address GetItemSchema() {
	return SDKCall(hSDKSchema);
}

static Address GetAttributeDefinitionByID(int id) {
	Address pSchema = GetItemSchema();

	if (pSchema == Address_Null)
	{
		return Address_Null;
	} 
	else
	{
		return SDKCall(hSDKGetAttributeDef, pSchema, id);
	}	
}
/**
 * Returns the m_AttributeList offset.  This does not correspond to the CUtlVector instance
 * (which is offset by 0x04).
 */
static Address GetEntityAttributeList(int entity) {
	int offsAttributeList = GetEntSendPropOffs(entity, "m_AttributeList", true);
	if (offsAttributeList != -1)
	{
		return GetEntityAddress(entity) + view_as<Address>(offsAttributeList);
	}
	else
	{
		return Address_Null;
	}
}
#endif

bool InternalDeleteAllAttributes(int iEntity)
{
	if (!IsValidEntity(iEntity))
	{
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEntAttributeList[2];

	GetEntityAttributeList(pEntAttributeList, iEntity);
	if (!pEntAttributeList[0])
	{
		return false;
	}

	SDKCall(hSDKDestroyAllAttributes, pEntAttributeList);
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	MemoryPointer pEntAttributeList = GetEntityAttributeList(iEntity);

	if (!pEntAttributeList)
	{
		return false;
	}

	SDKCall(hSDKDestroyAllAttributes, pEntAttributeList);
#else
	Address pEntAttributeList = GetEntityAttributeList(iEntity);
	if (pEntAttributeList == Address_Null)
	{
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
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEntAttributeList[2];

	GetEntityAttributeList(pEntAttributeList, iEntity);

	if (!pEntAttributeList[0])
	{
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	MemoryPointer pEntAttributeList = GetEntityAttributeList(iEntity);

	if (!pEntAttributeList)
	{
#else
	Address pEntAttributeList = GetEntityAttributeList(iEntity);
	if (pEntAttributeList == Address_Null)
	{
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	int pEconItemAttributeDefinition[2];

	GetByID(pEconItemAttributeDefinition, iDefIndex);

	if (!pEconItemAttributeDefinition[0])
	{
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	MemoryPointer pEconItemAttributeDefinition = GetByID(iDefIndex);

	if (!pEconItemAttributeDefinition)
	{
#else
	Address pAttribDef = GetAttributeDefinitionByID(iDefIndex);
	if (pAttribDef == Address_Null)
	{
#endif
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	SDKCall(hSDKSetRuntimeValue, pEntAttributeList, pEconItemAttributeDefinition, flValue);
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	SDKCall(hSDKSetRuntimeValue, pEntAttributeList, pEconItemAttributeDefinition, flValue);
#else
	SDKCall(hSDKSetRuntimeValue, pEntAttributeList, pAttribDef, flValue);
#endif
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