/* These are all non cryptographically secure PRNGs! Only a fool would do anything sensitive with these. */
#if defined(MALLET_USE_NON_RECYCLING_PRNG)
#error "TODO"
#else
int hash_prng(int a) {
    a = (a ^ 61) ^ (a >> 16);
    a = a + (a << 3);
    a = a ^ (a >> 4);
    a = a * 0x27d4eb2d;
    a = a ^ (a >> 15);
    return a;
}

int GetRand()
{
	return hash_prng(GetURandomInt());
}
#endif

/* public int Mallet_GetRand() */
public int Native_GetRand(Handle plugin, int numParams)
{
	if (numParams != 0)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	return GetRand();
}