#include "MalletUtils.h"

class MalletHolidays
{
public:
	static bool load(SourceMod::IGameConfig *g_pGameConf);

	static cell_t MalletIsHolidayActive(IPluginContext *pContext, const cell_t *params);
};
