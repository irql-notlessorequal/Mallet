# Mallet 🔨
A general purpose library for making SourceMod plugins for Team Fortress 2.

*We take no responsibility in the hammer emoji not being a Mallet.*

## Compiling Mallet.

Mallet has the following build-time defines available for users:
- `MALLET_DEBUG=1` enables additional runtime logging into the server console.
- `_X64=1` enables 64-bit compilation, requires an implementation to be set.
	- `_X64_IMPLEMENTATION_PORT64=1` uses [Port64](https://github.com/skial-com/port64) as the implementation for 64-bit memory pointers.

		**Requires the [following patch](https://github.com/alliedmodders/sourcemod/pull/2159) to be applied on top of SourceMod.**
		
		Known limitations: None.
	- `_X64_IMPLEMENTATION_MEMORY_POINTER=1` uses a [proposed merge request](https://github.com/alliedmodders/sourcemod/pull/2196) to implement 64-bit memory pointers.

		Known limitations: Mallet's implementation is experimental and untested!
	- `_X64_IMPLEMENTATION_VIRTUAL_ADDRESS=1` is a placeholder for a future implementation.

		Does not compile.
- `MALLET_DISABLE_ATTRIBUTE_LOCALE=1` disables the AttributeLocale interface.

Compiling for 64-bit:
```
./spcomp64 _X64=1 _X64_IMPLEMENTATION_PORT64=1 mallet.sp
```

Compiling for 32-bit
```
./spcomp mallet.sp
```
## License

Mallet contains fragments of code from [TF2Attributes](https://github.com/FlaminSarge/tf2attributes) and [TF2EconData](https://github.com/nosoop/SM-TFEconData).

[TF2EconData](https://github.com/nosoop/SM-TFEconData) is licensed under the GNU General Public License v3.0.

```
Copyright (C) 2024-2025  IRQL_NOT_LESS_OR_EQUAL

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```