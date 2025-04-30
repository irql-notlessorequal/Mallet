#include "MalletUtils.h"

class MalletWeapons
{
public:
	static bool loadEcon(SourceMod::IGameConfig *g_pGameConf);

	static bool MalletEquipWeapon(CBaseEntity* entity, CBaseEntity* weapon);

	static cell_t Internal_MalletCreateWeapon_Econ(IPluginContext *pContext, int client,
		int weaponId, const char* weaponName, int level,
		int quality, int weaponSlot, int flags);

	static cell_t Internal_MalletCreateWeapon_Dumb(IPluginContext *pContext, int client,
		int weaponId, const char* weaponName, int level,
		int quality, int weaponSlot, int flags);

	static cell_t MalletCreateWeapon(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletIsWeapon(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletSwapWeapon(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletSwapWeaponAndPurge(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletGetItemOwner(IPluginContext *pContext, const cell_t *params);
};
