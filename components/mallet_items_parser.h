#include "MalletUtils.h"
/**
 * I am very happy that Source SDK 2013 is on C++17,
 * bless not having to spend an extra hour
 * writing code for multiple platforms.
 */

/**
 * oh boy
 */
#if defined(_WIN32)
#include <processthreadsapi.h>
#include <windows.h>
#elif defined(__linux__)
#include <pthread.h>
#else
#error "Unsupported operating system"
#endif

enum TF2AttributeType
{
	UNKNOWN = -1,
	PERCENTAGE = 0,
	INVERTED_PERCENTAGE,
	ADDITIVE,
	ADDITIVE_PERCENTAGE,
	OR,
	DATE,
	ACCOUNT_ID,
	ITEM_DEFINITION,
	PARTICLE_INDEX,
	KILL_STREAK_EFFECT_INDEX,
	KILL_STREAK_EFFECT_INDEX_IDLE
};

struct ItemsGameAttribute
{
	char* name;
	float value; /* [TODO]: This might be a bad idea, a pointer might be more universal here. */
	TF2AttributeType type;
};

struct ItemsGameEconItem
{
	char* className;
	char* rawItemName;
	unsigned int min_level;
	unsigned int max_level;
};

class MalletItemsParser
{
public:
	bool Load();
};
