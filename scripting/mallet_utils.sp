/* Utility functions for handling 64-bit, etc. */

#if defined(_X64_IMPLEMENTATION_PORT64)
bool MalletNotEqualAddresses(any first[2], any second[2])
{
	return first[0] != second[0] || first[1] != second[1];
}

void MalletCopyInto(any root[2], any output[2])
{
	output[0] = root[0];
	output[1] = root[1];
}
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
bool MalletNotEqualAddresses(MemoryPointer first, MemoryPointer second)
{
	return first != second;
}
#else
#endif