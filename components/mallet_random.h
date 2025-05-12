#include "MalletUtils.h"

class MalletRandom
{
public:
	static bool init();

	static cell_t MalletGetRand(IPluginContext *pContext, const cell_t *params);

private:
	static uint64_t MalletGetRandGeneric();

	static uint64_t MalletGetRandRDRAND();
};
