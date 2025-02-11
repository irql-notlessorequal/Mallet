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

void ReadMemoryString(any addr[2], char[] buffer, int size)
{
	int max = size - 1;

	int i = 0;
	for( ; i < max; i++ )
	{
		int offset_addr[2];
		Port64_LoadFromAddress(addr, i, NumberType_Int8, offset_addr);

#if defined(MALLET_DEBUG_READ_MEMORY_STRING)
		PrintToServer("[Mallet::ReadMemoryString] idx=%i, addr={%i, %i}", i, offset_addr[0], offset_addr[1]);
#endif

		/* FIXME: We're assuming that only using the LOW bits will work... */ 
		if( (buffer[i] = view_as<char>(offset_addr[0])) == '\0' )
			return;
	}

	buffer[i] = '\0';
}
#elseif defined(_X64_IMPLEMENTATION_MEMORY_POINTER)
bool MalletNotEqualAddresses(MemoryPointer first, MemoryPointer second)
{
	return first != second;
}

void ReadMemoryString(MemoryPointer addr, char[] buffer, int size)
{
	int max = size - 1;

	int i = 0;
	for( ; i < max; i++ )
	{
		int data = addr.Load(NumberType_Int8, i);
#if defined(MALLET_DEBUG_READ_MEMORY_STRING)
		PrintToServer("[Mallet::ReadMemoryString] idx=%i, addr={%i}", i, addr);
#endif
		if( (buffer[i] = view_as<char>(data)) == '\0' )
			return;
	}

	buffer[i] = '\0';
}
#else
void ReadMemoryString(Address addr, char[] buffer, int size)
{
	int max = size - 1;

	int i = 0;
	for( ; i < max; i++ )
#if defined(MALLET_DEBUG_READ_MEMORY_STRING)
		PrintToServer("[Mallet::ReadMemoryString] idx=%i, addr={%i}", i, addr);
#endif
		if( (buffer[i] = view_as<char>(LoadFromAddress(addr + view_as<Address>(i), NumberType_Int8))) == '\0' )
			return;

	buffer[i] = '\0';
}
#endif