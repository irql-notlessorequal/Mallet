#include <sdktools>

/**
 * Temporary file!
 * I'm not sure if this'll be used with the Attribute description generator.
 * Might be removed at any moment!
 */

static Handle hGLocalizationProvider = INVALID_HANDLE;

public bool InitializeLocale()
{
	Handle hGameConf = LoadGameConfigFile("tf2.mallet");
	if (hGameConf == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to find the gamedata config handle!");
		return false;
	}

#if defined(_X64_IMPLEMENTATION_PORT64)
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GLocalizationProvider");
	PrepSDKCall_SetReturnInfo(SDKType_Pointer, SDKPass_Plain);
	hGLocalizationProvider = EndPrepSDKCall();
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GLocalizationProvider");
	PrepSDKCall_SetReturnInfo(SDKType_MemoryPointer, SDKPass_Plain);
	hGLocalizationProvider = EndPrepSDKCall();
#else
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GLocalizationProvider");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hGLocalizationProvider = EndPrepSDKCall();
#endif

	if (hGLocalizationProvider == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into GLocalizationProvider!")
		return false;
	}

	delete hGameConf;
	return true;
}

#if defined(_X64_IMPLEMENTATION_PORT64)
static void GetLocalizationProvider(any pAddress[2])
{
	SDKCall(hGLocalizationProvider, pAddress);
}
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
static MemoryPointer GetLocalizationProvider()
{
	return SDKCall(hGLocalizationProvider);
}
#else
static Address GetLocalizationProvider()
{
	return SDKCall(hGLocalizationProvider);
}
#endif