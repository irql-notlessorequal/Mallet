#include <tf2>

#if defined _mallet_included
  #endinput
#endif
#define _mallet_included

native int MalletIsReady();

/* Conversions */

native int MalletConvertClassFromString(char[] strclass);

native int MalletConvertSlotFromString(char[] strclass);

native int MalletConvertTeamFromString(char[] strclass);

/* Weapons */

/**
 * Creates and returns a weapon entity
 * 
 * @note Wearables are supported by this function and are automatically equipped. Invoking `EquipPlayerWeapon` on a wearable will crash the server.
 * @note Weapons must be manually equipped using `EquipPlayerWeapon`
 * 
 * @param client 	index of the client
 * @param weaponId	Team Fortress 2 weapon id
 * @param weaponName	Team Fortress weapon name
 * @param level			Weapon Level
 * @param quality		Weapon Quality
 * @param weaponSlot	Slot idx to equip weapon on
 * @return A entity index if successful, else a negative value which is mapped into a mallet error.
 */
native int MalletCreateWeapon(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot);

/**
 * Checks if a entity is a wearable.
 * 
 * @param entity	Entity Index
 * @return A boolean mapped as an int (returns 1 on success)
 */
native int MalletIsWearable(int entity);

/**
 * Creates and returns a wearable entity
 * 
 * @note This function DOES NOT equip the wearable. You must call `MalletEquipWearable` to do so.
 * @param client 	index of the client
 * @param weaponId	Team Fortress 2 weapon id
 * @param weaponName	Team Fortress weapon name
 * @return A entity index if successful, else a negative value which is mapped into a mallet error.
 */
native int MalletCreateWearable(int client, int weaponId, const char[] weaponName);

/**
 * Equips a wearable onto an entity.
 * 
 * @param client 	index of the client
 * @param entity 	index of the entity
 * @return A boolean mapped as an int (returns 1 on success)
 */
native int MalletEquipWearable(int client, int entity);

native int MalletRemoveWearable(int client, int wearable);

native int MalletRemoveWeapon(int client, int wearable);

native int MalletGetWearableOwner(int weapon, int client);

/* AttributeDB */

native int MalletGetAttributeLocalization(int key, char[] value, int valueSize);

/* Attributes */

native int MalletSetAttribute(int iEntity, int iDefIndex, float flValue);

native int MalletDeleteAllAttributes(int iEntity);

/* Players */

native int MalletIsValidPlayer(int client);

/* */

public SharedPlugin __pl_mallet =
{
	name = "mallet",
	file = "mallet.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_mallet_SetNTVOptional()
{
	MarkNativeAsOptional("MalletIsReady");

	MarkNativeAsOptional("MalletConvertClassFromString");
	MarkNativeAsOptional("MalletConvertSlotFromString");
	MarkNativeAsOptional("MalletConvertTeamFromString");

	MarkNativeAsOptional("MalletCreateWeapon");
	MarkNativeAsOptional("MalletCreateWearable");
	MarkNativeAsOptional("MalletEquipWearable");
	MarkNativeAsOptional("MalletIsWearable");
	MarkNativeAsOptional("MalletRemoveWearable");
	MarkNativeAsOptional("MalletRemoveWeapon");
	MarkNativeAsOptional("MalletGetWearableOwner");

	MarkNativeAsOptional("MalletGetAttributeLocalization");

	MarkNativeAsOptional("MalletSetAttribute");
	MarkNativeAsOptional("MalletDeleteAllAttributes");

	MarkNativeAsOptional("MalletIsValidPlayer");
}