#include "mallet_conversions.h"

struct InternalLookUp
{
	const char* key;
	int value;
};

static const InternalLookUp CLASS_VALUES[] =
{
	{ "scout", TFClass_Scout },
	{ "soldier", TFClass_Soldier },
	{ "pyro", TFClass_Pyro },
	{ "demoman", TFClass_DemoMan },
	{ "heavy", TFClass_Heavy },
	{ "engineer", TFClass_Engineer },
	{ "medic", TFClass_Medic },
	{ "sniper", TFClass_Sniper },
	{ "spy", TFClass_Spy }
};

static const InternalLookUp SLOT_VALUES[] =
{
	{ "primary", TFWeaponSlot_Primary },
	{ "secondary", TFWeaponSlot_Secondary },
	{ "primary", TFWeaponSlot_Melee },
	{ "grenade", TFWeaponSlot_Grenade },
	{ "building", TFWeaponSlot_Building },
	{ "pda", TFWeaponSlot_PDA },
	{ "item1", TFWeaponSlot_Item1 },
	{ "item2", TFWeaponSlot_Item2 },
	/**
	 * Special value, should not be used unless
	 * you have a very _good_ reason.
	 */
	{ "any", -2 }
};

static const InternalLookUp TEAM_VALUES[] =
{
	{ "spectator", TFTeam_Spectator },
	{ "red", TFTeam_Red },
	{ "blue", TFTeam_Blue }
};

cell_t MalletConversions::MalletConvertClassFromString(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	char* className;
	int err;
	if ((err = pContext->LocalToString(params[1], &className)) != SP_ERROR_NONE)
	{
		return pContext->ThrowNativeErrorEx(err, NULL);
	}

	/**
	 * Not super efficient, too bad! (for now)
	 */
	for (int i = 0; i < sizeof(CLASS_VALUES); i++)
	{
		if (strcicmp(className, CLASS_VALUES[i].key))
		{
			return CLASS_VALUES[i].value;
		}
	}

	return TFClass_Unknown;
}

cell_t MalletConversions::MalletConvertSlotFromString(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	char* className;
	int err;
	if ((err = pContext->LocalToString(params[1], &className)) != SP_ERROR_NONE)
	{
		return pContext->ThrowNativeErrorEx(err, NULL);
	}

	/**
	 * Not super efficient, too bad! (for now)
	 */
	for (int i = 0; i < sizeof(SLOT_VALUES); i++)
	{
		if (strcicmp(className, SLOT_VALUES[i].key))
		{
			return SLOT_VALUES[i].value;
		}
	}

	return -1;
}

cell_t MalletConversions::MalletConvertTeamFromString(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	char* className;
	int err;
	if ((err = pContext->LocalToString(params[1], &className)) != SP_ERROR_NONE)
	{
		return pContext->ThrowNativeErrorEx(err, NULL);
	}

	/**
	 * Not super efficient, too bad! (for now)
	 */
	for (int i = 0; i < sizeof(TEAM_VALUES); i++)
	{
		if (strcicmp(className, TEAM_VALUES[i].key))
		{
			return TEAM_VALUES[i].value;
		}
	}

	return TFTeam_Unassigned;
}
