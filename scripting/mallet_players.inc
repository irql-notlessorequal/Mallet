#include <tf2>
#include <tf2_stocks>

bool InternalIsValidPlayer(int client)
{
	return (client >= 1 && client <= MaxClients
		&& IsClientConnected(client) && IsClientInGame(client)
		&& !IsClientSourceTV(client));
}

/* native int MalletIsValidPlayer(int client) */
public int Native_IsValidPlayer(Handle plugin, int numParams)
{
	if (numParams != 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int clientIdx = GetNativeCell(1);
	return InternalIsValidPlayer(clientIdx);
}
