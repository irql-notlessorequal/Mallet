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