
#include "mallet_econ.sp"

public bool InitializeWeaponsEcon()
{
	return false;
}

int InternalCreateWeaponEcon(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot, int flags)
{
	PrintToServer("[Mallet->Econ] InternalCreateWeaponEcon: Rejecting call.", client, weaponId, weaponName, level, quality, weaponSlot, flags);
	return MALLET_ERROR_FAILED_TO_SPAWN;
}