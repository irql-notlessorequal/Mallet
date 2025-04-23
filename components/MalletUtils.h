//
// Created by rake on 22.04.25.
//

#ifndef MALLETUTILS_H
#define MALLETUTILS_H

#include <cstdint>

#include <eiface.h>
#include <smsdk_ext.h>
#include <IGameHelpers.h>
#include <toolframework/itoolentity.h>
#include <gameinterface.h>

#define MALLET_IS_64_BIT (INTPTR_MAX == INT64_MAX)

#define MALLET_ERROR_GENERAL_ERROR  -1
#define MALLET_ERROR_INVALID_ENTITY -2
#define MALLET_ERROR_INVALID_ENTITY_CLASS -3
#define MALLET_ERROR_FAILED_TO_SPAWN -4

#define MALLET_WEAPON_FLAG_PRESERVE_ATTRIBUTES (1 << 5)
#define MALLET_WEAPON_FLAG_FORCE_GENERATION (1 << 6)
#define MALLET_WEAPON_FLAG_FORCE_DUMB (1 << 7)

#define PARAM_COUNT(params) params[0]

class IServerTools;

class MalletUtils
{
public:
	enum PropType
	{
		Prop_Send = 1,
		Prop_Data = 2
	};

	static const int CPU_CAPABILITY_SSE2 = (1 << 1);
	static const int CPU_CAPABILITY_SSSE3 = (1 << 2);
	static const int CPU_CAPABILITY_SSE42 = (1 << 3);

	static uint32_t getCPUFlags();

	/**
	 * Loads some background information in
	 * including a query for CPU capability.
	 */
	static void load();

	static void memcpy();

	/**
	 * Mallet equivalent of SourcePawn's `SetEntData`.
	 */
	static void SetEntData(CBaseEntity* entity, int offset, int value, int size = 4);

	/**
	 * Platform specific handler.
	 * 
	 * On Windows will use a pattern while on Linux will use a symbol.
	 * 
	 * Otherwise use the provided methods in `sm_memutils`
	 */
	static void* FindPatternOrSymbol(IServerGameDLL* server, const char* patternOrSymbol);
};

extern IServerTools *servertools;
#endif //MALLETUTILS_H
