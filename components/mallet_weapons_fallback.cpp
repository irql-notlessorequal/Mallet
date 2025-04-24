#include "MalletUtils.h"
#include "mallet_weapons.h"

/**
 * Not really needed with native Mallet but might as well keep it
 * for compatibility purposes.
 */

cell_t MalletWeapons::Internal_MalletCreateWeapon_Dumb(IPluginContext *pContext, int client,
	 int weaponId, const char* weaponName, int level,
	 int quality, int weaponSlot, int flags)
{
	CBaseEntity* entity = servertools->CreateEntityByName(weaponName);
	if (!entity)
	{
		return MALLET_ERROR_GENERAL_ERROR;
	}

	servertools->SetKeyValue(entity, "m_iItemDefinitionIndex", weaponId);
	servertools->SetKeyValue(entity, "m_bInitialized", 1);
	servertools->SetKeyValue(entity, "m_bValidatedAttachedEntity", 1);

	servertools->SetKeyValue(entity, "m_iEntityLevel", level);
	servertools->SetKeyValue(entity, "m_iEntityQuality", quality);

	/**
	 * Weapon specific workarounds.
	 */
	switch (weaponId)
	{
		/* The Vaccinator */
		case 998:
		{
			SourceMod::sm_sendprop_info_t *info = { 0 };
			if (!gamehelpers->FindSendPropInfo(weaponName, "m_nChargeResistType", info))
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}

			MalletUtils::SetEntData(entity, info->actual_offset, 0);
			break;
		}

		/* Dragon's Fury */
		case 1178:
		{
			datamap_t* dataMap = gamehelpers->GetDataMap(entity);
			if (!dataMap)
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}

			typedescription_t* tdt = gamehelpers->FindInDataMap(dataMap, "m_iPrimaryAmmoType");
			if (!tdt)
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}
			
			int iOffset = tdt->fieldOffset[0] * 4;
			if (iOffset == -1)
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}

			SourceMod::sm_sendprop_info_t *iAmmoTable = { 0 };
			if (!gamehelpers->FindSendPropInfo("CTFPlayer", "m_iAmmo", iAmmoTable))
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}

			MalletUtils::SetEntData(entity, iAmmoTable->actual_offset + iOffset, 40, 4);
			break;
		}

		/* The Flare Gun */
		/* The Detonator */
		/* The Scorch Shot */
		case 39:
		case 351:
		case 740:
		{
			datamap_t* dataMap = gamehelpers->GetDataMap(entity);
			if (!dataMap)
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}

			typedescription_t* tdt = gamehelpers->FindInDataMap(dataMap, "m_iPrimaryAmmoType");
			if (!tdt)
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}
			
			int iOffset = tdt->fieldOffset[0] * 4;
			if (iOffset == -1)
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}

			SourceMod::sm_sendprop_info_t *iAmmoTable = { 0 };
			if (!gamehelpers->FindSendPropInfo("CTFPlayer", "m_iAmmo", iAmmoTable))
			{
				return MALLET_ERROR_GENERAL_ERROR;
			}

			MalletUtils::SetEntData(entity, iAmmoTable->actual_offset + iOffset, 16, 4);
			break;	
		}

		/* Gas Passer */
		case 1180:
		{
			servertools->SetKeyValue(entity, "m_flItemChargeMeter", 99.5f);
			break;
		}
	}

	/**
	 * DispatchSpawn always returns TRUE
	 * in SourceMod since the Orange Box, lol.
	 */
	servertools->DispatchSpawn(entity);

	return gamehelpers->EntityToReference(entity);
}