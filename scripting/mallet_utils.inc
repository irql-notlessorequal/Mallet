/* Utility functions for handling 64-bit, etc. */

#if SOURCEMOD_V_MAJOR > 1 || \
    (SOURCEMOD_V_MAJOR == 1 && SOURCEMOD_V_MINOR > 13) || \
    (SOURCEMOD_V_MAJOR == 1 && SOURCEMOD_V_MINOR == 13 && SOURCEMOD_V_RELEASE > 0) || \
    (SOURCEMOD_V_MAJOR == 1 && SOURCEMOD_V_MINOR == 13 && SOURCEMOD_V_RELEASE == 0 && SOURCEMOD_V_REV >= 7308)
#define MALLET_HAS_VIRTUALADDRESS 1
#endif

#if defined __sourcepawn2
	#define INTPTR_S Address_PointerSize
#elseif defined(_X64)
	#define INTPTR_S 8
#else
	#define INTPTR_S 4
#endif

#if defined(_X64_IMPLEMENTATION_PORT64)
bool MalletNotEqualAddresses(any first[2], any second[2])
{
	return first[0] != second[0] || first[1] != second[1];
}

void MalletCopyInto(any root[2], any output[2])
{
	output[0] = root[0];
	output[1] = root[1];
}
#endif