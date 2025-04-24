//
// Created by rake on 22.04.25.
//

#include "extension.h"

#include "components/MalletUtils.h"
#include "components/mallet_weapons_fallback.h"
#include "components/mallet_holidays.h"

IServerTools *servertools = nullptr;

static Mallet mallet;
SMEXT_LINK(&mallet);

extern sp_nativeinfo_t MalletNatives[];

void Mallet::SDK_OnAllLoaded()
{
	sharesys->RegisterLibrary(myself, "mallet");
	sharesys->AddNatives(myself, MalletNatives);
}

bool Mallet::SDK_OnMetamodLoad(ISmmAPI *ismm, char *error, size_t maxlength, bool late)
{
	MalletUtils::load();

	g_SMAPI->ConPrint("Loaded Mallet successfully.");

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
	return 1;
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

sp_nativeinfo_t MalletNatives[] =
{
	/**
	 * Core.
	 */
	{ "MalletGetType", MalletGetType },
	{ "MalletIsReady", MalletIsReady },
	{ "MalletIsX64", MalletIsX64 },
	/**
	 * Holidays.
	 */
	{ "MalletIsHolidayActive", MalletIsHolidayActive }
};