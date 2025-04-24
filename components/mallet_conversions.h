#include "smsdk_ext.h"

#include "MalletUtils.h"

enum TFClassType
{
	TFClass_Unknown = 0,
	TFClass_Scout,
	TFClass_Sniper,
	TFClass_Soldier,
	TFClass_DemoMan,
	TFClass_Medic,
	TFClass_Heavy,
	TFClass_Pyro,
	TFClass_Spy,
	TFClass_Engineer
};

enum TFWeaponSlot
{
	TFWeaponSlot_Primary,
	TFWeaponSlot_Secondary,
	TFWeaponSlot_Melee,
	TFWeaponSlot_Grenade,
	TFWeaponSlot_Building,
	TFWeaponSlot_PDA,
	TFWeaponSlot_Item1,
	TFWeaponSlot_Item2
};

enum TFTeam
{
	TFTeam_Unassigned = 0,
	TFTeam_Spectator = 1,
	TFTeam_Red = 2,
	TFTeam_Blue = 3
};

class MalletConversions
{
public:
	static cell_t MalletConvertClassFromString(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletConvertSlotFromString(IPluginContext *pContext, const cell_t *params);

	static cell_t MalletConvertTeamFromString(IPluginContext *pContext, const cell_t *params);
};

static inline int strcicmp(char const *a, char const *b)
{
    for (;; a++, b++)
	{
        int d = tolower((unsigned char)*a) - tolower((unsigned char)*b);
        if (d != 0 || !*a)
            return d;
    }
}