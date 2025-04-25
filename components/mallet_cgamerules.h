#include "mallet_linkage.h"

class CTFGameRules;

enum gamerules_roundstate_t
{
	// initialize the game, create teams
	GR_STATE_INIT = 0,

	//Before players have joined the game. Periodically checks to see if enough players are ready
	//to start a game. Also reverts to this when there are no active players
	GR_STATE_PREGAME,

	//The game is about to start, wait a bit and spawn everyone
	GR_STATE_STARTGAME,

	//All players are respawned, frozen in place
	GR_STATE_PREROUND,

	//Round is on, playing normally
	GR_STATE_RND_RUNNING,

	//Someone has won the round
	GR_STATE_TEAM_WIN,

	//Noone has won, manually restart the game, reset scores
	GR_STATE_RESTART,

	//Noone has won, restart the game
	GR_STATE_STALEMATE,

	//Game is over, showing the scoreboard etc
	GR_STATE_GAME_OVER,

	//Game is in a bonus state, transitioned to after a round ends
	GR_STATE_BONUS,

	//Game is awaiting the next wave/round of a multi round experience
	GR_STATE_BETWEEN_RNDS,

	GR_NUM_ROUND_STATES
};


enum
{
	WINREASON_NONE                    =  0,
	WINREASON_ALL_POINTS_CAPTURED     =  1,
	WINREASON_OPPONENTS_DEAD          =  2,
	WINREASON_FLAG_CAPTURE_LIMIT      =  3,
	WINREASON_DEFEND_UNTIL_TIME_LIMIT =  4,
	WINREASON_STALEMATE               =  5,
	WINREASON_TIMELIMIT               =  6,
	WINREASON_WINLIMIT                =  7,
	WINREASON_WINDIFFLIMIT            =  8,
	WINREASON_RD_REACTOR_CAPTURED     =  9,
	WINREASON_RD_CORES_COLLECTED      = 10,
	WINREASON_RD_REACTOR_RETURNED     = 11,
};


class CBaseMultiplayerPlayer;
class CTFPlayer;
struct VoiceCommandMenuItem_t;
struct CMannVsMachineUpgrades;

struct CTFRadiusDamageInfo
{
	CTakeDamageInfo *m_DmgInfo;   // +0x00
	Vector m_vecOrigin;           // +0x04: blast origin
	float m_flRadius;             // +0x10: blast radius
	CBaseEntity *m_pEntityIgnore = nullptr; // +0x14
	float m_unknown_18 = 0.0f;           // +0x18, default 0.0f, ?
	float m_unknown_1c = 1.0f;           // +0x1c, default 1.0f, scales damage force or something
	CBaseEntity *target = nullptr;             // +0x20, default 0, ?
	float m_flFalloff = 0.5f;            // +0x24: how much the damage is decreased by at the edge of the blast
};


class CGameRulesProxy : public CBaseEntity
{
public:
	static void NotifyNetworkStateChanged();

	static GlobalThunk<CGameRulesProxy *> s_pGameRulesProxy;
};

class CTeamplayRoundBasedRulesProxy : public CGameRulesProxy {};
class CTFGameRulesProxy : public CTeamplayRoundBasedRulesProxy {};


/**
 * g_pGameRules is sometimes nullptr (e.g. at engine shutdown time), so we have
 * to be able to gracefully handle those cases, ideally without crashing;
 * annoyingly, 'this' is guaranteed to be non-nullptr in well-formed C++ code,
 * so we have to do stupid workarounds like this to avoid compilers optimizing
 * out the check we do
 */
[[gnu::noinline]] bool IsNullptr(uintptr_t ptr);
#define IF_NULL if (IsNullptr((uintptr_t)static_cast<const void *>(this)))
#define NULL_RET(...) IF_NULL { return __VA_ARGS__; }

class CGameRules
{
public:
	void NetworkStateChanged(void *pVar) { NULL_RET(); CGameRulesProxy::NotifyNetworkStateChanged(); }
	void NetworkStateChanged()           { NULL_RET(); CGameRulesProxy::NotifyNetworkStateChanged(); }

	const CViewVectors *GetViewVectors() const;
	bool ShouldCollide(int collisionGroup0, int collisionGroup1) { NULL_RET(true); return vt_ShouldCollide (this, collisionGroup0, collisionGroup1); }
	bool IsConnectedUserInfoChangeAllowed(CBasePlayer *player) { NULL_RET(true); return vt_IsConnectedUserInfoChangeAllowed (this, player); }

private:
	static MemberVFuncThunk<const CGameRules *, const CViewVectors *> vt_GetViewVectors;
	static MemberVFuncThunk<      CGameRules *, bool, int, int>       vt_ShouldCollide;
	static MemberVFuncThunk<      CGameRules *, bool, CBasePlayer *>  vt_IsConnectedUserInfoChangeAllowed;
};

extern GlobalThunk<CGameRules*> g_pGameRules;

inline CGameRules *GameRules()
{
	CGameRules *gamerules = g_pGameRules;

	if (gamerules == nullptr)
	{
		Warning("WARNING: g_pGameRules == nullptr!\n");
	}

	return gamerules;
}

inline CTFGameRules *TFGameRules()
{
	return reinterpret_cast<CTFGameRules*>(GameRules());
}
