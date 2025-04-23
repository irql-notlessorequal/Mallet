//
// Created by rake on 22.04.25.
//

#include "extension.h"

#include "components/MalletUtils.h"

const Mallet mallet;
SMEXT_LINK(&mallet);

extern sp_nativeinfo_t MalletNatives[];

void Mallet::SDK_OnAllLoaded()
{
	sharesys->RegisterLibrary(myself, "mallet");
	sharesys->AddNatives(myself, MalletNatives);

	MalletUtils::load();
}

const sp_nativeinfo_t MalletNatives[] =
{
	{ nullptr, nullptr }
};