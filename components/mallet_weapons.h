#include "smsdk_ext.h"

#include "MalletUtils.h"

class MalletWeapons
{
public:
	static bool loadEcon(SourceMod::IGameConfig *g_pGameConf);

	static cell_t Internal_MalletCreateWeapon_Econ(IPluginContext *pContext, int client,
		int weaponId, const char* weaponName, int level,
		int quality, int weaponSlot, int flags);

	static cell_t Internal_MalletCreateWeapon_Dumb(IPluginContext *pContext, int client,
		int weaponId, const char* weaponName, int level,
		int quality, int weaponSlot, int flags);		

	static cell_t MalletCreateWeapon(IPluginContext *pContext, const cell_t *params)
	{
		if (PARAM_COUNT(params) < 6 || PARAM_COUNT(params) > 7)
		{
			return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
		}

		int client = params[1];
		int weaponId = params[2];
		
		char* weaponName;
		int err;
		if (pContext->LocalToString(params[3], &weaponName) != SP_ERROR_NONE)
		{
			return pContext->ThrowNativeErrorEx(err, NULL);
		}
		
		int level = params[4];
		int quality = params[5];
		int weaponSlot = params[6];
		
		int flags = 0;
		if (PARAM_COUNT(params) == 7)
		{
			flags = params[7];
		}
		
		if ((flags & MALLET_WEAPON_FLAG_FORCE_DUMB))
		{
			return MalletWeapons::Internal_MalletCreateWeapon_Dumb(pContext, client, weaponId, weaponName, level, quality, weaponSlot, flags);
		}
		else
		{
			return MalletWeapons::Internal_MalletCreateWeapon_Econ(pContext, client, weaponId, weaponName, level, quality, weaponSlot, flags);
		}
	}
};