#include "mallet_random.h"
#include "mallet_random_loop128.h"

#include <immintrin.h>

/**
 * TODO:
 *
 * - Add a MalletGetRandomInt(min, max) implementation
 * - Add a MalletGetRandomFloat(min, max) implementation
 */
int (*FUNC_GET_RANDOM_RAW)(void);

inline int MalletRandom::MalletGetRandGeneric()
{
	return static_cast<int>(loopMix128());
}

[[gnu::target("rdrnd")]] inline int MalletRandom::MalletGetRandRDRAND()
{
	unsigned int ret;
	do {} while( !_rdrand32_step(&ret) );
	return static_cast<int>(ret);
}

bool MalletRandom::init()
{
	if (false)
	{
		/**
		 * - Hook up RDRAND, but we'll need to _not_ use it on older Intel CPUs where RDRAND performance
		 *   was nuked out of existence due to vulnerability mitigations
	 	 */
		FUNC_GET_RANDOM_RAW = MalletGetRandRDRAND;
	}
	else
	{
		FUNC_GET_RANDOM_RAW = MalletGetRandGeneric;
	}

	return false;
}

cell_t MalletRandom::MalletGetRand(IPluginContext *pContext, const cell_t *params)
{
	return FUNC_GET_RANDOM_RAW();
}
