#include "mallet_random.h"

#include <immintrin.h>

cell_t MalletRandom::MalletGetRand(IPluginContext *pContext, const cell_t *params)
{
	if (MalletUtils::getCPUFlags() & MalletUtils::CPU_CAPABILITY_RDRAND)
	{
		return MalletGetRandRDRAND();
	}
	else
	{
		return MalletGetRandGeneric();
	}
}

inline int MalletRandom::MalletGetRandGeneric()
{
	return -1;
}

[[gnu::target("rdrnd")]] inline int MalletRandom::MalletGetRandRDRAND()
{
	unsigned int ret;
	do {} while( !_rdrand32_step(&ret) );
	return static_cast<int>(ret);
}