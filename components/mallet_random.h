#include "MalletUtils.h"

class MalletRandom
{
public:
	static bool init();

	static cell_t MalletGetRand(IPluginContext *pContext, const cell_t *params);

private:
	static int MalletGetRandGeneric();

	static int MalletGetRandRDRAND();
};
