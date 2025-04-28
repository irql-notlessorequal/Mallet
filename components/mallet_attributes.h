#include "MalletUtils.h"

class MalletAttributes
{
public:
	static bool load(SourceMod::IGameConfig *g_pGameConf);

	static cell_t MalletSetAttribute(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletRemoveAttribute(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletDeleteAllAttributes(IPluginContext *pContext, const cell_t *params);
};
