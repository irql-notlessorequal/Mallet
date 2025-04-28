//
// Created by rake on 22.04.25.
//

#include "extension.h"

#include "components/MalletUtils.h"
#include "components/mallet_attributes.h"
#include "components/mallet_conversions.h"
#include "components/mallet_weapons.h"
#include "components/mallet_holidays.h"
#include "components/mallet_wearables.h"
#include "components/mallet_random.h"

SourceMod::IGameConfig *g_pGameConf = NULL;
IServerTools *servertools = nullptr;

static Mallet mallet;
SMEXT_LINK(&mallet);

extern sp_nativeinfo_t MalletNatives[];

bool Mallet::SDK_OnLoad(char *error, size_t maxlength, bool late)
{
	char conf_error[255] = "";
	if (!gameconfs->LoadGameConfigFile("tf2.mallet", &g_pGameConf, conf_error, sizeof(conf_error)))
	{
		if (conf_error[0])
		{
			snprintf(error, maxlength, "Could not read tf2.mallet.txt: %s\n", conf_error);
		}

		return false;
	}

	if (!MalletAttributes::load(g_pGameConf))
	{
		return false;
	}

	if (!MalletHolidays::load(g_pGameConf))
	{
		return false;
	}

	if (!MalletWeapons::loadEcon(g_pGameConf))
	{
		return false;
	}

	sharesys->RegisterLibrary(myself, "mallet");
	sharesys->AddNatives(myself, MalletNatives);

	return true;
}

bool Mallet::SDK_OnMetamodLoad(ISmmAPI *ismm, char *error, size_t maxlength, bool late)
{
	MalletUtils::load();

	g_SMAPI->ConPrintf("Mallet running on %s was loaded successfully.\n",
		MALLET_IS_64_BIT ? "x64" : "x86");

//	GET_IFACE_REQUIRED(Server,	gamedll,		INTERFACEVERSION_SERVERGAMEDLL);
	GET_IFACE_REQUIRED(Server,	servertools,	VSERVERTOOLS_INTERFACE_VERSION);

	return true;
}

bool Mallet::OnExtensionLoad(IExtension *me, IShareSys *sys, char *error, size_t maxlength, bool late)
{
	sharesys = sys;
	myself = me;

	return true;
}

cell_t MalletIsReady(IPluginContext *pContext, const cell_t *params)
{
	/**
	 * Always ready in the extension version
	 * since we setup during extension load.
	 */
	return true;
}

cell_t MalletIsX64(IPluginContext *pContext, const cell_t *params)
{
	return MALLET_IS_64_BIT;
}

cell_t MalletGetType(IPluginContext *pContext, const cell_t *params)
{
	/**
	 * Equivalent to MALLET_TYPE_EXTENSION.
	 */
	return 0xAAAAA;
}

cell_t MalletAPIVersion(IPluginContext *pContext, const cell_t *params)
{
	return 7;
}

sp_nativeinfo_t MalletNatives[] =
{
	/**
	 * Core.
	 */
	{ "MalletGetType", MalletGetType },
	{ "MalletIsReady", MalletIsReady },
	{ "MalletIsX64", MalletIsX64 },
	{ "MalletAPIVersion", MalletAPIVersion },
	/**
	 * Attributes
	 */
	{ "MalletSetAttribute" , MalletAttributes::MalletSetAttribute },
	{ "MalletRemoveAttribute", MalletAttributes::MalletRemoveAttribute },
	{ "MalletDeleteAllAttributes", MalletAttributes::MalletDeleteAllAttributes },
	/**
	 * Conversions
	 */
	{ "MalletConvertClassFromString", MalletConversions::MalletConvertClassFromString },
	{ "MalletConvertSlotFromString", MalletConversions::MalletConvertSlotFromString },
	{ "MalletConvertTeamFromString", MalletConversions::MalletConvertTeamFromString },
	/**
	 * Random API
	 * (highly experimental)
	 */
	{ "MalletGetRand", MalletRandom::MalletGetRand },
	/**
	 * Holidays.
	 */
	{ "MalletIsHolidayActive", MalletHolidays::MalletIsHolidayActive },
	/**
	 * Weapons
	 */
	{ "MalletCreateWeapon", MalletWeapons::MalletCreateWeapon },
	{ "MalletIsWeapon", MalletWeapons::MalletIsWeapon },
	{ "MalletSwapWeapon", MalletWeapons::MalletSwapWeapon },
	{ "MalletSwapWeaponAndPurge", MalletWeapons::MalletSwapWeaponAndPurge },
	/**
	 * Wearables
	 */
	{ "MalletCreateWearable", MalletWearables::MalletCreateWearable },
	{ "MalletEquipWearable", MalletWearables::MalletEquipWearable },
	{ "MalletIsWearable", MalletWearables::MalletIsWearable },
	{ "MalletRemoveWearable", MalletWearables::MalletRemoveWearable },
	{ "MalletRemoveAllWearables", MalletWearables::MalletRemoveAllWearables },
};
