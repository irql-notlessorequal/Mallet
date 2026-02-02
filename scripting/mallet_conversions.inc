#include <tf2>
#include <tf2_stocks>

TFClassType InternalConvertClassFromString(const char[] strclass)
{
	if (StrEqual(strclass, "scout", false))
	{
		return TFClass_Scout;
	}
	else if (StrEqual(strclass, "soldier", false))
	{
		return TFClass_Soldier;
	}
	else if (StrEqual(strclass, "pyro", false))
	{
		return TFClass_Pyro;
	}
	else if (StrEqual(strclass, "demoman", false))
	{
		return TFClass_DemoMan;
	}
	else if (StrEqual(strclass, "heavy", false))
	{
		return TFClass_Heavy;
	}
	else if (StrEqual(strclass, "engineer", false))
	{
		return TFClass_Engineer;
	}
	else if (StrEqual(strclass, "medic", false))
	{
		return TFClass_Medic;
	}
	else if (StrEqual(strclass, "sniper", false))
	{
		return TFClass_Sniper;
	}
	else if (StrEqual(strclass, "spy", false))
	{
		return TFClass_Spy;
	}
	else
	{
		return TFClass_Unknown;
	}
}

int InternalConvertSlotFromString(const char[] strclass)
{
	if (StrEqual(strclass, "primary", false))
	{
		return TFWeaponSlot_Primary;
	}
	else if (StrEqual(strclass, "secondary", false))
	{
		return TFWeaponSlot_Secondary;
	}
	else if (StrEqual(strclass, "melee", false))
	{
		return TFWeaponSlot_Melee;
	}
	else if (StrEqual(strclass, "grenade", false))
	{
		return TFWeaponSlot_Grenade;
	}
	else if (StrEqual(strclass, "building", false))
	{
		return TFWeaponSlot_Building;
	}
	else if (StrEqual(strclass, "pda", false))
	{
		return TFWeaponSlot_PDA;
	}
	else if (StrEqual(strclass, "item1", false))
	{
		return TFWeaponSlot_Item1;
	}
	else if (StrEqual(strclass, "item2", false))
	{
		return TFWeaponSlot_Item2;
	}
	else if (StrEqual(strclass, "any", false))
	{
		/* Special value */
		return -2;
	}
	else
	{
		return -1;
	}
}

TFTeam InternalConvertTeamFromString(const char[] strclass)
{
	if (StrEqual(strclass, "red", false))
	{
		return TFTeam_Red;
	}
	else if (StrEqual(strclass, "blue", false))
	{
		return TFTeam_Blue;
	}
	else if (StrEqual(strclass, "spectator", false))
	{
		return TFTeam_Spectator;
	}
	else
	{
		return TFTeam_Unassigned;
	}
}

/* native int MalletConvertClassFromString(char[] strclass) */
public int Native_ConvertClassFromString(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	char strAttrib[10];
	GetNativeString(1, strAttrib, 10);

	return InternalConvertClassFromString(strAttrib);
}

/* native int MalletConvertSlotFromString(char[] strclass) */
public int Native_ConvertSlotFromString(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	char strAttrib[10];
	GetNativeString(1, strAttrib, 10);

	return InternalConvertSlotFromString(strAttrib);
}

/* native int MalletConvertTeamFromString(char[] strclass) */
public int Native_ConvertTeamFromString(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	char strAttrib[10];
	GetNativeString(1, strAttrib, 10);

	return InternalConvertTeamFromString(strAttrib);
}