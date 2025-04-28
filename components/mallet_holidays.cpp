#include "mallet_holidays.h"

static int iIsHolidayActive = -1;
SH_DECL_MANUALHOOK1(MHook_IsHolidayActive, 0, 0, 0, int, int);

bool MalletHolidays::load(SourceMod::IGameConfig *g_pGameConf)
{
	if (!g_pGameConf->GetOffset("CTFGameRules::IsHolidayActive", &iIsHolidayActive))
	{
		ConMsg("\"CTFGameRules::IsHolidayActive\" couldn't be found!\n");
		return false;
	}
	else
	{
		SH_MANUALHOOK_RECONFIGURE(MHook_IsHolidayActive, iIsHolidayActive, 0, 0);
		g_pSM->LogMessage(myself, "\"CTFGameRules::IsHolidayActive\" offset = %d", iIsHolidayActive);
	}

	return true;
}

cell_t MalletHolidays::MalletIsHolidayActive(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) != 1)
	{
		return pContext->ThrowNativeError("Invalid parameter count (%i)", PARAM_COUNT(params));
	}

	return SH_MCALL(MalletUtils::GetGameRules(), MHook_IsHolidayActive)(params[1]);
}
