#include "MalletUtils.h"
#include "hl2sdk-tf2/game/server/variant_t.h"

class variant_t;

extern variant_t g_Variant_t;

class MalletWearables
{
public:
	static bool load(SourceMod::IGameConfig *g_pGameConf);

	static bool TypeIsWearable(const char* name);

	static cell_t MalletIsWearable(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletRemoveWearable(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletCreateWearable(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletEquipWearable(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletRemoveAllWearables(IPluginContext *pContext, const cell_t *params);
};
