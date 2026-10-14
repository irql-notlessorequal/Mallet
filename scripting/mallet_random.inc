#define INT32_MAX	0x7FFFFFFF
#define INT32_MIN  -0x7FFFFFFF

static int g_s0, g_s1, g_s2, g_s3;

int RotL32(int x, int k)
{
	return (x << k) | (x >>> (32 - k));
}

int Xoshiro128Next()
{
	int result = RotL32(g_s1 * 5, 7) * 9;
	int t = g_s1 << 9;

	g_s2 ^= g_s0;
	g_s3 ^= g_s1;
	g_s1 ^= g_s2;
	g_s0 ^= g_s3;
	g_s2 ^= t;
	g_s3  = RotL32(g_s3, 11);

	return result;
}

int SplitMix32(int &state)
{
	state += 0x9E3779B9;
	int z = state;
	z = (z ^ (z >>> 16)) * 0x85EBCA6B;
	z = (z ^ (z >>> 13)) * 0xC2B2AE35;
	return z ^ (z >>> 16);
}

bool U32Ge(int a, int b)
{
	return (a ^ 0x80000000) >= (b ^ 0x80000000);
}

int U32Mod(int a, int m)
{
	int rem = 0;
	for (int i = 31; i >= 0; i--)
	{
		rem = (rem << 1) | ((a >>> i) & 1);
		if (U32Ge(rem, m))
			rem -= m;
	}
	return rem;
}

int U32Uniform(int range)
{
	int threshold = U32Mod(-range, range);

	int r;
	do
	{
		r = Xoshiro128Next();
	} while (!U32Ge(r, threshold));

	return U32Mod(r, range);
}

public void MalletInitRand()
{
	int seed[2];

	GetTime(seed);

	seed[0] ^= GetURandomInt();
	seed[1] ^= GetURandomInt();

	int smLo = seed[0];
	int smHi = seed[1];

	g_s0 = SplitMix32(smLo);
	g_s1 = SplitMix32(smLo);
	g_s2 = SplitMix32(smHi);
	g_s3 = SplitMix32(smHi);

	if (g_s0 == 0 && g_s1 == 0 && g_s2 == 0 && g_s3 == 0)
		g_s0 = 1;
}

static int MalletGetRand32()
{
	return Xoshiro128Next();
}

/* public int MalletGetRand32() */
public int Native_GetRand32(Handle plugin, int numParams)
{
	return MalletGetRand32();
}

/* public void MalletGetRand64(int data[2]) */
public void Native_GetRand64(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
		return;
	}

	int array[2];

	array[0] = Xoshiro128Next();
	array[1] = Xoshiro128Next();

	SetNativeArray(1, array, 2);
}

/* public int MalletGetRandomInt(int min, int max) */
public int Native_GetRandomInt(Handle plugin, int numParams)
{
	if (numParams != 2)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int min = GetNativeCell(1);
	int max = GetNativeCell(2);

	int range = max - min + 1;
	if (range <= 0)
		return min; // handle bad input

	return min + U32Uniform(range);
}

/* public any MalletGetRandomFloat(bool positive) */
public any Native_GetRandomFloat(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%d)", numParams);
	}

	bool positive = GetNativeCell(1);

	int rand = Xoshiro128Next();

	if (positive)
	{
		// Clear the sign bit...
		rand &= 0x7fffffff;
		return float(rand) / float(0x7fffffff);
	}

	float asFloat = (rand < 0) ? (4294967296.0 + float(rand)) : float(rand);
	return asFloat / float(0xffffffff);
}