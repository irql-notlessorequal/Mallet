//
// Created by rake on 22.04.25.
//

#ifndef MALLETUTILS_H
#define MALLETUTILS_H

#include <cstdint>

#include <toolframework/itoolentity.h>

#define MALLET_IS_64_BIT 1

#define MALLET_ERROR_GENERAL_ERROR  -1
#define MALLET_ERROR_INVALID_ENTITY -2
#define MALLET_ERROR_INVALID_ENTITY_CLASS -3
#define MALLET_ERROR_FAILED_TO_SPAWN -4

class IServerTools;

class MalletUtils
{
public:
	static const int CPU_CAPABILITY_SSE2 = (1 << 1);
	static const int CPU_CAPABILITY_SSSE3 = (1 << 2);
	static const int CPU_CAPABILITY_SSE42 = (1 << 3);

	static uint32_t getCPUFlags();

	static void load();

	static void memcpy();
};

extern IServerTools *servertools;
#endif //MALLETUTILS_H
