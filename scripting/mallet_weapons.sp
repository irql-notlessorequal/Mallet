#include "mallet_weapons_dumb.sp"
#include "mallet_weapons_econ.sp"
#include "mallet_weapons_wearable.sp"
#include "mallet_weapons_misc.sp"

public bool InitializeWeapons()
{
	return InitializeWeaponsDumb() && InitializeWeaponsWearable() && InitializeWeaponsMisc();
}