#include "smsdk_ext.h"

#include "MalletUtils.h"

class MalletStrings
{
public:
	/**
	 * Generic variants (SSE/SSE2)
	 */

	static cell_t StringWordCountGeneric(const char* str);

	static cell_t StringOccurrenceGeneric(const char* str, const char* search);
};