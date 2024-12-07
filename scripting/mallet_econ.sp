static Handle hSDKCallTranslateWeaponEntForClass = INVALID_HANDLE;

public bool InitializeEcon()
{
	GameData hGameConf = new GameData("tf2.mallet");

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "TranslateWeaponEntForClass()");
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	hSDKCallTranslateWeaponEntForClass = EndPrepSDKCall();

	if (hSDKCallTranslateWeaponEntForClass == INVALID_HANDLE)
	{
		PrintToServer("[Mallet] Failed to hook into TranslateWeaponEntForClass()!");
		return false;
	}

	delete hGameConf;
	return true;
}

bool TranslateWeaponEntForClass(char[] buffer, int maxlen, int playerClass)
{
	return SDKCall(hSDKCallTranslateWeaponEntForClass, buffer, maxlen, buffer, playerClass) > 0;
}

int Native_TranslateWeaponEntForClass(Handle hPlugin, int nParams)
{
	char weaponClass[64];
	GetNativeString(1, weaponClass, sizeof(weaponClass));

	int maxlen = GetNativeCell(2);
	int playerClass = GetNativeCell(3);
	
	if (TranslateWeaponEntForClass(weaponClass, maxlen, playerClass))
	{
		SetNativeString(1, weaponClass, maxlen, true);
		return true;
	}

	return false;
}