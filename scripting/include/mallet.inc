#include <tf2>

#if defined _mallet_included
  #endinput
#endif
#define _mallet_included

enum MalletType
{
	MALLET_TYPE_SOURCEPAWN = 0,
	MALLET_TYPE_EXTENSION  = 0xAAAAA
};

/**
 * Returns the implementation type of Mallet as a integer.
 * 
 * Value will be one of the types within MalletType.
 */
native int MalletGetType();

/**
 * Returns TRUE if the loaded Mallet extension/plugin is ready for use.
 */
native int MalletIsReady();

/**
 * Returns TRUE if the compiled Mallet version is built for 64-bit.
 */
native int MalletIsX64();

/**
 * Returns the API version.
 * 
 * Check `APIChanges.md` for more details.
 */
native int MalletAPIVersion();

/* Conversions */

/**
 * Converts a string into an instance of `TFClassType`
 * 
 * @return Integer representation of `TFClassType`
 */
native int MalletConvertClassFromString(char[] strclass);

/**
 * Converts a string into an instance of `TFWeaponSlot_[...]`
 * 
 * @return Integer representation of `TFWeaponSlot`
 */
native int MalletConvertSlotFromString(char[] strclass);

/**
 * Converts a string into an instance of `TFTeam`
 * 
 * @return Integer representation of `TFTeam`
 */
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
 * @param flags 		[OPTIONAL]
 * @return A entity index if successful, else a negative value which is mapped into a mallet error.
 */
native int MalletCreateWeapon(int client, int weaponId, const char[] weaponName, int level, int quality, int weaponSlot, int flags=0);

/**
 * Checks if a entity is a wearable.
 * 
 * @param entity	Entity Index
 * @return A boolean mapped as an int (returns 1 on success)
 */
native int MalletIsWearable(int entity);

/**
 * Checks if a entity is a weapon.
 * 
 * @param entity	Entity Index
 * @return A boolean mapped as an int (returns 1 on success)
 */
native int MalletIsWeapon(int entity);

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

native int MalletRemoveAllWearables(int client);

native int MalletRemoveWeapon(int client, int weapon);

native int MalletGetItemOwner(int item);

/**
 * Equips the weapon on a client's slot.
 * 
 * This function may return zero if there was no weapon previously equipped.
 * 
 * @note Invoking this function on a wearable will crash the server.
 * 
 * @param client 	index of the client
 * @param weaponEntity 	index of the weapon entity
 * @param slot		slot of the weapon
 * @return An int with the entity index of the old weapon
 */
native int MalletSwapWeapon(int client, int weaponEntity, int slot);

/**
 * Equips the weapon on a client's slot and deletes the previous weapon.
 * 
 * @note Invoking this function on a wearable will crash the server.
 * 
 * @param client 	index of the client
 * @param weaponEntity 	index of the weapon entity
 * @param slot		slot of the weapon
 * @return A boolean.
 */
native int MalletSwapWeaponAndPurge(int client, int weaponEntity, int slot);

/* WeaponsDB */

native int MalletGetWeaponIndex(int weaponNameSize, const char[] weaponName, int& value);

/* AttributeDB */

/**
 * Returns the attribute definition index from the string name.
 * 
 * @param string 	char array containing the name of the attribute
 * @param stringSize 	Size of the char array
 * @return The index as an integer or zero if no such attribute was found.
 */
native int MalletAttributeFromName(char[] string, int stringSize);

native int MalletGetAttributeClass(int key, char[] value, int valueSize);

/**
 * Returns a random Team Fortress 2 item attribute.
 * 
 * @param excludeBroken		Exclude known broken attributes or attributes that are prone to crash players when misused.
 * @return An integer identifier of the attribute.
 */
native int MalletGetRandomAttribute(bool excludeBroken=false);

/* AttributeLocale */

/**
 * I am so sorry for this.
 */
enum MalletAttributeValueType
{
	mStringAttribute = 0,
	mFloatAttribute,
	mIntegerAttribute
}

native int MalletGetRawAttributeDescription(int key, char[] value, int valueSize);

native int MalletGetAttributeDescription(int key, char[] value, int valueSize, MalletAttributeValueType attributeType, any attributeValue);

/* Attributes */

/**
 * Sets an attribute for the following entity. (weapon/wearabale)
 * 
 * @param iEntity	The entity of the weapon or wearable
 * @param iDefIndex	The attribute identifier.
 * @param flValue	The value to set (as a float)
 * 
 * @return	A boolean in the form of an integer.
 */
native int MalletSetAttribute(int iEntity, int iDefIndex, float flValue);

/**
 * Removes an attribute for the following entity. (weapon/wearabale)
 * 
 * @param iEntity	The entity of the weapon or wearable
 * @param iDefIndex	The attribute identifier.
 * 
 * @return	A boolean in the form of an integer.
 */
native int MalletRemoveAttribute(int iEntity, int iDefIndex);

/**
 * Removes all attributes from a weapon entity.
 * 
 * (Wearables should use the player entity instead)
 * 
 * @param iEntity	The entity of the weapon or wearable
 * @return	A boolean in the form of an integer.
 */
native int MalletDeleteAllAttributes(int iEntity);

/* Players */

native int MalletIsValidPlayer(int client);

/* Holidays */

native int MalletIsHolidayActive(int holiday);

/* Random API (experimental) */

/**
 * Returns a random number, backed by either a PRNG or RDRAND.
 *
 * THIS FUNCTION IS NOT CRYPTOGRAPHICALLY SECURE!!!!!!!!
 *
 * @return	A 64-bit unsigned integer casted down to 32-bits
 */
native int MalletGetRand32();

/**
 * Puts a random number into an integer array, backed by either a PRNG or RDRAND.
 *
 * THIS FUNCTION IS NOT CRYPTOGRAPHICALLY SECURE!!!!!!!!
 */
native void MalletGetRand64(any a[2]);

/**
 * Returns a random number between two bounds (inclusive) using `MalletGetRand__()`.
 */
native int MalletGetRandomInt(int min, int max);

/**
 * Returns a random float value between the following ranges:
 * - [-1.0, 1.0 ] if positive is set to FALSE
 * - [ 0.0, 1.0 ] if positive is set to TRUE
 * 
 * Users of this function MUST cast this to a float.
 */
native any MalletGetRandomFloat(bool positive);

/* */

#if !defined(_MALLET_WEAPONS_FLAGS)
#define _MALLET_WEAPONS_FLAGS 1

#define MALLET_WEAPON_FLAG_PRESERVE_ATTRIBUTES (1 << 5)
#define MALLET_WEAPON_FLAG_FORCE_GENERATION (1 << 6)
#define MALLET_WEAPON_FLAG_FORCE_DUMB (1 << 7)
#endif

enum MalletHoliday
{
	kHoliday_None = 0,
	kHoliday_TFBirthday,
	kHoliday_Halloween,
	kHoliday_Christmas,
	kHoliday_CommunityUpdate,
	kHoliday_EOTL,
	kHoliday_Valentines,
	kHoliday_MeetThePyro,
	kHoliday_FullMoon,
	kHoliday_HalloweenOrFullMoon,
	kHoliday_HalloweenOrFullMoonOrValentines,
	kHoliday_AprilFools,
	kHolidayCount,
};

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
	MarkNativeAsOptional("MalletIsX64");
	MarkNativeAsOptional("MalletAPIVersion");

	MarkNativeAsOptional("MalletConvertClassFromString");
	MarkNativeAsOptional("MalletConvertSlotFromString");
	MarkNativeAsOptional("MalletConvertTeamFromString");

	MarkNativeAsOptional("MalletCreateWeapon");
	MarkNativeAsOptional("MalletCreateWearable");
	MarkNativeAsOptional("MalletEquipWearable");
	MarkNativeAsOptional("MalletIsWearable");
	MarkNativeAsOptional("MalletIsWeapon");
	MarkNativeAsOptional("MalletRemoveWearable");
	MarkNativeAsOptional("MalletRemoveWeapon");
	MarkNativeAsOptional("MalletGetItemOwner");
	MarkNativeAsOptional("MalletSwapWeapon");
	MarkNativeAsOptional("MalletSwapWeaponAndPurge");

	MarkNativeAsOptional("MalletAttributeFromName");
	MarkNativeAsOptional("MalletGetAttributeClass");
	MarkNativeAsOptional("MalletGetRandomAttribute");

	MarkNativeAsOptional("MalletSetAttribute");
	MarkNativeAsOptional("MalletRemoveAttribute");
	MarkNativeAsOptional("MalletDeleteAllAttributes");
	MarkNativeAsOptional("MalletGetAttributeDescription");

	MarkNativeAsOptional("MalletIsValidPlayer");

	MarkNativeAsOptional("MalletIsHolidayActive");
}