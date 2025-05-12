#include "mallet_weapons.h"
#include "sourcehook.h"

int iIsBaseCombatWeapon = -1;
SH_DECL_MANUALHOOK0(MHook_IsBaseCombatWeapon, 0, 0, 0, bool);

cell_t MalletWeapons::MalletIsWeapon(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	CBaseEntity* weapon;
	if (!MalletUtils::GetAndCheckValidEntity(params[1], &weapon))
	{
		return pContext->ThrowNativeError("Invalid weapon reference (%i)", params[2]);
	}

	return SH_MCALL(weapon, MHook_IsBaseCombatWeapon)();
}

cell_t MalletWeapons::MalletGetItemOwner(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	return pContext->ThrowNativeError("TODO");
}
