//
// Created by rake on 22.04.25.
//

#include "MalletUtils.h"
#include <cassert>

static uint32_t getCPUFlags()
{
	static int cpu_flags = -1;

	if (cpu_flags == -1)
	{
		uint32_t cpuFlags = 0;
		int eax, ebx, ecx, edx;

		// Call CPUID with EAX=1 to get feature information in ECX and EDX
		eax = 1;
		__asm__ __volatile__(
			"cpuid"
			: "=a"(eax), "=b"(ebx), "=c"(ecx), "=d"(edx)
			: "a"(eax)
		);

		// Check for SSE2 (Bit 26 in EDX)
		if (edx & (1 << 26))
		{
			cpuFlags |= MalletUtils::CPU_CAPABILITY_SSE2;
		}

		// Check for SSSE3 (Bit 9 in ECX)
		if (ecx & (1 << 9))
		{
			cpuFlags |= MalletUtils::CPU_CAPABILITY_SSSE3;
		}

		/**
		 * Check for SSE4.2 (bit 20 in ECX register)
		 */
		if (ecx & (1 << 20))
		{
			cpuFlags |= MalletUtils::CPU_CAPABILITY_SSE42;
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

static void Load()
{
	uint32_t flags = getCPUFlags();

	if (flags & MalletUtils::CPU_CAPABILITY_SSE42)
	{
		ConMsg("[Mallet] Checking for CPU capabilities...SSE4.2 SSSE3 SSE2");
	}
	else if (flags & MalletUtils::CPU_CAPABILITY_SSSE3)
	{
		ConMsg("[Mallet] Checking for CPU capabilities...SSSE3 SSE2");
	}
	else if (flags & MalletUtils::CPU_CAPABILITY_SSE2)
	{
		ConMsg("[Mallet] Checking for CPU capabilities...SSE2");
	}
	else
	{
		assert(!"Unsupported CPU hardware");
	}
}