
#include "mallet_econ.sp"

public bool InitializeWeaponsEcon()
{
	return false;
}

int InternalCreateWeaponEcon(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot, int flags)
{
	SetFailState("unreachable: Requires Pallet.");
	return MALLET_ERROR_FAILED_TO_SPAWN;
}