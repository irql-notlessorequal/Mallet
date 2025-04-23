#include "MalletUtils.h"

/**
 * Not really needed with native Mallet but might as well keep it
 * for compatibility purposes.
 */

static cell_t Internal_MalletCreateWeapon_Econ(SourcePawn::IPluginContext *pContext, int client,
	 int weaponId, const char weaponName[], int level,
	 int quality, int weaponSlot, int flags)
{
	CBaseEntity* entity = servertools->CreateEntityByName(weaponName);
	if (entity == nullptr)
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	servertools->SetKeyValue(entity, "m_iItemDefinitionIndex", weaponId);
	servertools->SetKeyValue(entity, "m_bInitialized", 1);
	servertools->SetKeyValue(entity, "m_bValidatedAttachedEntity", 1);

	int internal_level = 1;
	int internal_quality = 6;

	if (level)
	{
		internal_level = level;
	}

	if (quality)
	{
		internal_quality = quality;
	}

	servertools->SetKeyValue(entity, "m_iEntityLevel", internal_level);
	servertools->SetKeyValue(entity, "m_iEntityQuality", internal_quality);

	switch (weaponId)
	{
		/**
		 * TODO
		 */
	}

	/**
	 * This needs to be double checked.
	 * - DispatchSpawn returns VOID, thanks Source~
	 * - That cast is 99.99999999% wrong.
	 */
	servertools->DispatchSpawn(entity);
	return (intptr_t)entity;
}