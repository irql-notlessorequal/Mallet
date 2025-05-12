//
// Created by rake on 22.04.25.
//

#include "MalletUtils.h"
#include "IPlayerHelpers.h"
#include "smsdk_ext.h"

#include <cassert>

uint32_t MalletUtils::getCPUFlags()
{
	static int cpu_flags = -1;

	if (cpu_flags == -1)
	{
		uint32_t cpuFlags = 0;

		/* "CPUID EAX=1: Feature Information in EDX and ECX" */
		int eax = 1, ebx, ecx, edx;

		__asm__ __volatile__(
			"cpuid"
			: "=a"(eax), "=b"(ebx), "=c"(ecx), "=d"(edx)
			: "a"(eax)
		);

		/**
		 * Check for SSE (bit 25 in the EDX register)
		 */
		if (edx & (1 << 25))
		{
			cpuFlags |= MalletUtils::CPU_CAPABILITY_SSE;
		}

		/**
		 * Check for SSE2 (bit 26 in the EDX register)
		 */
		if (edx & (1 << 26))
		{
			cpuFlags |= MalletUtils::CPU_CAPABILITY_SSE2;
		}

		/**
		 * Check for SSSE3 (bit 9 in the ECX register)
		 */
		if (ecx & (1 << 9))
		{
			cpuFlags |= MalletUtils::CPU_CAPABILITY_SSSE3;
		}

		/**
		 * Check for SSE4.2 (bit 20 in the ECX register)
		 */
		if (ecx & (1 << 20))
		{
			cpuFlags |= MalletUtils::CPU_CAPABILITY_SSE42;
		}

		/**
		 * Check for RDRAND (bit 30 in the ECX register)
		 */
		if (ecx & (1 << 30))
		{
			cpuFlags |= MalletUtils::CPU_CAPABILITY_RDRAND;
		}

		/**
		 * Cache the flags to avoid excessive CPUID calls.
		 */
		return (cpu_flags = cpuFlags);
	}
	else
	{
		return cpu_flags;
	}
}

void MalletUtils::load()
{
	ConMsg("[Mallet] Checking for CPU capabilities...\n");

	uint32_t flags = getCPUFlags();
	char capabilities[48];

	if (flags & MalletUtils::CPU_CAPABILITY_SSE42)
	{
		strcat(capabilities, "SSE4.2 ");
	}

	if (flags & MalletUtils::CPU_CAPABILITY_SSSE3)
	{
		strcat(capabilities, "SSSE3 ");
	}

	if (flags & MalletUtils::CPU_CAPABILITY_SSE2)
	{
		strcat(capabilities, "SSE2 ");
	}

	if (flags & MalletUtils::CPU_CAPABILITY_SSE)
	{
		strcat(capabilities, "SSE ");
	}

	if (flags & MalletUtils::CPU_CAPABILITY_RDRAND)
	{
		strcat(capabilities, "(RDRAND) ");
	}

	ConMsg("[Mallet] Supported CPU extensions: %s\n", capabilities);

	/**
	 * This should absolutely NEVER EVER EVER happen.
	 */
	if (!(flags & MalletUtils::CPU_CAPABILITY_SSE2) && MALLET_IS_64_BIT)
	{
		assert(!"Missing SSE2 support on a 64-bit environment");
	}
}

void MalletUtils::SetEntData(CBaseEntity* entity, int offset, int value, int size)
{
	switch (size)
	{
		case 4:
		{
			*(int *)((uint8_t *)entity + offset) = value;
			break;
		}
		case 2:
		{
			*(short *)((uint8_t *)entity + offset) = value;
			break;
		}
		case 1:
		{
			*((uint8_t *)entity + offset) = value;
			break;
		}

		default:
		{
			assert(!"Invalid size in SetEntData!");
			break;
		}
	}
}

void *MalletUtils::FindPatternOrSymbol(IServerGameDLL* server, const char* patternOrSymbol)
{
#if !defined(LINUX)
	return memutils->ResolvePattern(server, patternOrSymbol);
#else
	Dl_info info;
	if (dladdr(server, &info) == 0)
	{
		return nullptr;
	}

	void *handle = dlopen(info.dli_fname, RTLD_NOW);
	if (!handle)
	{
		return nullptr;
	}

	return memutils->ResolveSymbol(handle, patternOrSymbol);
#endif
}

bool MalletUtils::IsValidEntity(int reference)
{
	CBaseEntity *pEntity = gamehelpers->ReferenceToEntity(reference);
	return (pEntity != nullptr);
}

bool MalletUtils::GetAndCheckValidClient(int reference, CBaseEntity **pEntity)
{
	if (reference <= 0 || reference >= playerhelpers->GetMaxClients())
	{
		return false;
	}

	IGamePlayer* player = playerhelpers->GetGamePlayer(reference);
	return player != nullptr && player->IsInGame();
}

bool MalletUtils::GetAndCheckValidEntity(int reference, CBaseEntity **pEntity)
{
	*pEntity = gamehelpers->ReferenceToEntity(reference);
	return (pEntity != nullptr);
}

void* MalletUtils::GetGameRules()
{
	return nullptr;
}
