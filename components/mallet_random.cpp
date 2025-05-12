#include "mallet_random.h"
#include "components/MalletUtils.h"
#include "mallet_random_loop128.h"

#include <cstdint>
#include <immintrin.h>

/**
 * TODO:
 *
 * - Add a MalletGetRandomInt(min, max) implementation
 * - Add a MalletGetRandomFloat(min, max) implementation
 */
static uint64_t (*FUNC_GET_RANDOM_RAW)(void);

[[gnu::target("rdrnd")]] inline uint64_t MalletRandom::MalletGetRandRDRAND()
{
	unsigned long long ret;
	do {} while( !_rdrand64_step(&ret) );
	return static_cast<uint64_t>(ret);
}

static inline bool IsIntelCPU()
{
	/* "EAX=0: Highest Function Parameter and Manufacturer ID" */
	int eax = 0, ebx, ecx, edx;

	__asm__ __volatile__(
		"cpuid"
		: "=a"(eax), "=b"(ebx), "=c"(ecx), "=d"(edx)
		: "a"(eax)
	);

	/* "GenuineIntel" */
	return (ebx == 0x756e6547 && edx == 0x49656e69 && ecx == 0x6c65746e);
}

static inline bool IsRDRANDBenefical()
{
	/* Obvious is obvious. */
	if (!(MalletUtils::getCPUFlags() & MalletUtils::CPU_CAPABILITY_RDRAND))
		return false;

	/* [TODO]: Add a debug option or env var to force RDRAND on mitigated CPUs. */

	/**
	 * Intel mainly has this issue with their SRBDS mitigations,
	 * AMD technically had broken RDRAND in their Excavator CPUs
	 * but who the hell is running Source Engine servers on them?
	 */
	if (!IsIntelCPU())
		return true;

	/**
	 * I'm not going to be insane and try to identify the CPU family here.
	 * Instead I'm going to use instruction sets as a reference for being
	 * "modern" enough to have good RDRAND performance.
	 *
	 * The following instruction sets are used as pointers:
	 * - 'VAES' (Icelake and newer)
	 * - 'AVX512VNNI' (Cascade Lake)
	 */

	/* "EAX=7, ECX=0: Extended Features" */
	int eax = 7, ebx, ecx, edx;

	__asm__ __volatile__(
		"cpuid"
		: "=a"(eax), "=b"(ebx), "=c"(ecx), "=d"(edx)
		: "a"(eax)
	);

	/* "VAES" */
	if (ecx & (1 << 9))
		return true;

	/* "AVX512VNNI" */
	if (ecx & (1 << 11))
		return true;

	return false;
}

bool MalletRandom::init()
{
	if (IsRDRANDBenefical())
	{
		FUNC_GET_RANDOM_RAW = MalletGetRandRDRAND;
	}
	else
	{
		FUNC_GET_RANDOM_RAW = loopMix128;
	}

	return true;
}

cell_t MalletRandom::MalletGetRand(IPluginContext *pContext, const cell_t *params)
{
	if (PARAM_COUNT(params) == 1)
	{
		/* Really ugly hack, too bad! */
		uintptr_t* addr;
		pContext->LocalToPhysAddr(params[1], reinterpret_cast<cell_t**>(&addr));

		*addr = FUNC_GET_RANDOM_RAW();
		return 0;
	}
	else
	{
		/* Convert uint64_t to a signed integer, thanks Source. */
		return static_cast<int>(FUNC_GET_RANDOM_RAW());
	}
}
