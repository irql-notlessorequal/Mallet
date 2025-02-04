#include "mallet_weapons_dumb.sp"
#include "mallet_weapons_econ.sp"
#include "mallet_weapons_wearable.sp"
#include "mallet_weapons_misc.sp"

static bool IsEconAvailable = false;

public bool InitializeWeapons()
{
	IsEconAvailable = InitializeWeaponsEcon();
	if (!IsEconAvailable)
	{
		PrintToServer("[Mallet] [WARNING] Failed to initialize the TF2Econ weapon spawning path!\nThings are about to break.");
	}

	return InitializeWeaponsDumb() && InitializeWeaponsWearable() && InitializeWeaponsMisc();
}

/* native int MalletCreateWeapon(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot, int flags = 0) */
public int Native_CreateWeapon(Handle plugin, int numParams)
{
	if (numParams < 6 || numParams > 7)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int client = GetNativeCell(1);
	int weaponId = GetNativeCell(2);

	char weaponName[64];
	GetNativeString(3, weaponName, 64);

	int level = GetNativeCell(4);
	int quality = GetNativeCell(5);
	int weaponSlot = GetNativeCell(6);

	int flags = 0;
	if (numParams == 7)
	{
		flags = GetNativeCell(7);
	}

	return InternalCreateWeapon(client, weaponId, weaponName, level, quality, weaponSlot, flags);
}

int InternalCreateWeapon(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot, int flags)
{
	if (IsEconAvailable && !(flags & MALLET_WEAPON_FLAG_FORCE_DUMB))
	{
		return InternalCreateWeaponEcon(client, weaponId, weaponName, level, quality, weaponSlot, flags);
	}
	else
	{
		return InternalCreateWeaponDumb(client, weaponId, weaponName, level, quality, weaponSlot);
	}
}