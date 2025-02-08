#include <sdktools>

static Handle hIsHolidayActive = INVALID_HANDLE;

public bool InitializeHolidays()
{
	Handle hGameConf = LoadGameConfigFile("tf2.mallet");
	if (hGameConf == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to find the gamedata config handle!");
		return false;
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFGameRules::IsHolidayActive");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hIsHolidayActive = EndPrepSDKCall();

	if (hIsHolidayActive == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into CTFGameRules::IsHolidayActive!")
		return false;
	}

	delete hGameConf;
	return true;
}

enum EHoliday
{
	kHoliday_None = 0,
	kHoliday_TFBirthday,
	kHoliday_Halloween,
	kHoliday_Christmas,
	kHoliday_CommunityUpdate,
	kHoliday_EOTL,
	kHoliday_Valentines,
	kHoliday_MeetThePyro,
	kHoliday_FullMoon,
	kHoliday_HalloweenOrFullMoon,
	kHoliday_HalloweenOrFullMoonOrValentines,
	kHoliday_AprilFools,
	kHolidayCount,
};

/* MalletIsHolidayActive(int holiday) */
public int Native_IsHolidayActive(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int holiday = GetNativeCell(1);

	if (holiday < 0 || holiday >= kHolidayCount)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid holiday (%i)", holiday);
	}

	return SDKCall(hIsHolidayActive, holiday);
}