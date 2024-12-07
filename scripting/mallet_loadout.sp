#include "mallet_utils.sp"
#define TF_ITEMDEF_DEFAULT -1

#if defined(_X64_IMPLEMENTATION_PORT64)
#include <port64>
#warning "Loadout API is unavailable when using Port64!"
#endif

/* Port64 limitation: We need to pass an int[2] to the offset, this isn't possible. Fuck. */
Address offs_CEconItemDefinition_aiItemSlot;

Handle g_SDKCallGetEconItemSchema = INVALID_HANDLE;
Handle g_SDKCallSchemaGetItemDefinition = INVALID_HANDLE;

public bool InitializeLoadout()
{
	GameData hGameConf = new GameData("tf2.mallet");

	if (hGameConf == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to find the game data handle!")
		return false;
	}

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GEconItemSchema");
#if defined(_X64_IMPLEMENTATION_PORT64)
	PrepSDKCall_SetReturnInfo(SDKType_Pointer, SDKPass_Plain);
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	PrepSDKCall_SetReturnInfo(SDKType_MemoryPointer, SDKPass_Plain);
#else
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
#endif
	g_SDKCallGetEconItemSchema = EndPrepSDKCall();

	if (g_SDKCallGetEconItemSchema == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into GEconItemSchema");
		return false;
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetItemDefinition");
#if defined(_X64_IMPLEMENTATION_PORT64)
	PrepSDKCall_SetReturnInfo(SDKType_Pointer, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Pointer, SDKPass_Plain);
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	PrepSDKCall_SetReturnInfo(SDKType_MemoryPointer, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_MemoryPointer, SDKPass_Plain);
#else
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
#endif
	g_SDKCallSchemaGetItemDefinition = EndPrepSDKCall();

	if (g_SDKCallSchemaGetItemDefinition == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CEconItemSchema::GetItemDefinition");
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	offs_CEconItemDefinition_aiItemSlot = -1;
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	assert(!"TODO");
#else
	offs_CEconItemDefinition_aiItemSlot = GameConfGetAddressOffset(hGameConf, "CTFItemDefinition::m_aiItemSlot");
#endif

	delete hGameConf;
	return true;
}

static Address GameConfGetAddressOffset(Handle gamedata, const char[] key) {
	/* SourceMod limitation: We don't have a x64-equivalent of this function... */
    Address offs = view_as<Address>(GameConfGetOffset(gamedata, key));

    if (offs == view_as<Address>(-1))
	{
        SetFailState("Failed to get member offset %s", key);
    }

    return offs;
}

#if defined(_X64_IMPLEMENTATION_PORT64)
static int[] GetEconDefaultItemDefinition()
{
	int out[2];
	GetEconItemDefinition(out, TF_ITEMDEF_DEFAULT);
	return out;
}
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	assert(!"TODO");
#else
static Address GetEconDefaultItemDefinition() {
	return GetEconItemDefinition(TF_ITEMDEF_DEFAULT);
}
#endif

#if defined(_X64_IMPLEMENTATION_PORT64)
void GetEconItemDefinition(any address[2], int defindex)
{
	int pSchema[2];
	GetEconItemSchema(pSchema);

	if (!pSchema[0])
	{
		return;
	}

	int pItemDefinition[2];
	SDKCall(g_SDKCallSchemaGetItemDefinition, pSchema, defindex, pItemDefinition);

	/* TODO() */
	if (defindex == TF_ITEMDEF_DEFAULT || MalletNotEqualAddresses(pItemDefinition, GetEconDefaultItemDefinition()))
	{
		MalletCopyInto(pItemDefinition, address);
	}
}
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	assert(!"TODO");
#else
Address GetEconItemDefinition(int defindex) {
	Address pSchema = GetEconItemSchema();
	if (!pSchema) {
		return Address_Null;
	}
	
	Address pItemDefinition = SDKCall(g_SDKCallSchemaGetItemDefinition, pSchema, defindex);
	
	// special case: return default item definition on TF_ITEMDEF_DEFAULT (-1)
	// otherwise return a valid definition iff not the default
	if (defindex == TF_ITEMDEF_DEFAULT || pItemDefinition != GetEconDefaultItemDefinition())
	{
		return pItemDefinition;
	}
	else
	{
		return Address_Null;
	}
}
#endif

#if defined(_X64_IMPLEMENTATION_PORT64)
void GetEconItemSchema(any address[2]) {
	SDKCall(g_SDKCallGetEconItemSchema, address);
}
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	assert(!"TODO");
#else
Address GetEconItemSchema() {
	return SDKCall(g_SDKCallGetEconItemSchema);
}
#endif

/*
 * TF2EconData compatibility
 * GetItemLoadoutSlot(int defindex, int playerClass)
 */
public int Native_GetItemLoadoutSlot(Handle plugin, int numParams)
{
	int defindex = GetNativeCell(1);
	int playerClass = GetNativeCell(2);

#if defined(_X64_IMPLEMENTATION_PORT64)
	return ThrowNativeError(SP_ERROR_NATIVE, "Interface unavailable on Port64.");
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	assert(!"TODO");
#else
	Address pItemDef = GetEconItemDefinition(defindex);
	if (!pItemDef) {
		return -1;
	}

	return LoadFromAddress(pItemDef + offs_CEconItemDefinition_aiItemSlot +
                        view_as<Address>(playerClass * 4), NumberType_Int32);
#endif
}