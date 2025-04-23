#include "MalletUtils.h"

cell_t MalletIsHolidayActive(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return -1;
	}

	return 0;
}