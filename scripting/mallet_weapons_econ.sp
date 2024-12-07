
#include "mallet_loadout.sp"
#include "mallet_econ.sp"

/* native int MalletCreateWeaponEcon(int client, int weaponId) */
EXPERIMENTAL public int Native_CreateWeaponEcon(Handle plugin, int numParams)
{
	if (numParams != 2)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int client = GetNativeCell(1);
	int weaponId = GetNativeCell(2);
	return InternalCreateWeaponEcon(client, weaponId);
}

int InternalCreateWeaponEcon(int client, int weaponId)
{
	if (!IsValidEntity(client))
	{
		ThrowError("InternalCreateWeaponEcon(): Invalid entity: %i", client);
	}

	int playerClass = TF2_GetPlayerClass(client);
	char weaponClassName[64];

	TranslateWeaponEntForClass(weaponClassName, sizeof (weaponClassName), playerClass);

	ThrowError("MALLET TODO");
}