## Mallet API changelog.

### version 1

Initial release.

### version 2 (2024-12-07)

- `MalletCreateWeapon` no longer exists.
	
	The native has been split into `MalletCreateWeaponDumb` and `MalletCreateWeaponEcon`.

	These functions are considered experimental, and may change with future revisions of Mallet.

- Added `MalletIsWeapon`.

- Added Econ interface with the following natives:

	```
	MalletTranslateWeaponEntForClass
	```

	A build time macro `MALLET_ENABLE_TF2ECON_COMPAT` is also available to provide TF2Econ compatibility.

- The Loadout interface has been declared as unstable, meaning that it will either change rapidly or be removed at any moment. Users should use caution.

- Added `MalletAPIVersion` to query the API version in use.

### version 3 (2024-12-14)

- Added the AttributeLocale interface with the following natives.

	```
	MalletGetRawAttributeDescription
	MalletGetAttributeDescription
	```

- `MalletGetAttributeLocalization` has been renamed to `MalletGetAttributeClass`.

- Added `MalletGetRandomAttribute` into the AttributeDB interface.

	This provides a random known attribute ID, including unused attributes.

	A future revision of Mallet may add an optional parameter to exclude unused attributes.

- The Attributes interface now has a untested and potentially broken implementation of MemoryPointer.

### version 4 (2025-01-15)

- Added the Holidays interface with the following natives.

	```
	MalletIsHolidayActive
	```

### version 5 (2025-02-04)

- `MalletCreateWeapon` exists once more.
	
	You can use the defined flag `MALLET_WEAPON_FLAG_FORCE_DUMB` to force the legacy path.

	This method once again replaces `MalletCreateWeaponDumb` and `MalletCreateWeaponEcon`.

- Weapons: Added `MalletSwapWeapon` and `MalletSwapWeaponAndPurge`

- Attributes: Added `MalletRemoveAttribute`

- AttributeDB: The argument `excludeBroken` in `MalletGetRandomAttribute` is now optional.

- AttributeDB: Added `MalletAttributeFromName`

- Removed the Loadout API.

	This has no purpose as Pallet (once it's ready) will likely take over any functionality.

### version 6 (2025-02-09)

- AttributeLocale:

	The layout of `MalletGetAttributeDescription` has been changed in order to workaround
	SourcePawn limitations.

	The function is now:

	```
	native int MalletGetAttributeDescription(int key, char[] value, int valueSize, MalletAttributeValueType attributeType, any attributeValue);
	```

	All users MUST switch to the new version.

### version 7 (2025-03-14)

- Wearables:

	Renamed `MalletGetWearableOwner` into `MalletGetItemOwner`

	I have no clue why I added this one in, either way, takes only one argument now which is the entity.

	Supports both dropped weapons and wearables.

	All users MUST switch to the new version.

### version 8 (2025-05-27)

- Random API:

	Initial introduction of the API.

	This is **very** experimental and subject to change between builds.

	The following functions are available:

	```
	native int MalletGetRand32();
	native void MalletGetRand64(int array[2]);
	native int MalletGetRandomInt(int min, int max);
	```

### version 8.1 (2025-11-13)

No functional changes, therefore no actual ABI version bump.

- Removed Memory Pointer implementation for x64.
- Updated Mallet's random implementation.

	Now based upon RANROT-BI, an improved variant of RANROT type B.

- Mallet's IntMap implementation is no longer required as of SourceMod 1.13.

### version 9 (2025-11-16)

- Random: Added `MalletGetRandomFloat`

	This function returns a random float between 0.0 and 1.0

- Clarification of Mallet's RNG implementation (see above)
- Clean up some warnings.

### version 9.1 (2026-02-02)

- Weapons: Removed the placeholder Pallet backend.

	This will be replaced in the future by the extension
	rewrite of Mallet, aka Mallet2...once that is finished.

- Switched all files that aren't the main `mallet.sp` file into a header file.

- The VirtualAddress backend no longer prints a warning as it is deemed stable.

- The legacy `port64` 64-bit implementation will be removed at the end of 2026.