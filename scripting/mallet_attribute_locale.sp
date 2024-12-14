/**
 * TODO:
 * - Reuse the KeyValues, we're currently very inefficient.
 * - Add a piss basic LRU cache to avoid reduce overhead and I/O.
 */
bool InternalGetRawAttributeDescription(int iDefIndex, char[] value, int valueSize)
{
	KeyValues items_game = new KeyValues("items_game");
	if (!items_game.ImportFromFile("scripts/items/items_game.txt"))
	{
		PrintToServer("[Mallet::AttributeLocale] Failed to open items_game.txt!");
		return false;
	}

	if (!items_game.JumpToKey("attributes"))
	{
		PrintToServer("[Mallet::AttributeLocale] Failed to find the attributes object!");

		delete items_game;
		return false;
	}

	char str_iDefIndex[5 /* 4 + NUL */];
	IntToString(iDefIndex, str_iDefIndex, 5);

	if (!items_game.JumpToKey(str_iDefIndex))
	{
		/* Not found. */

		delete items_game;
		return false;
	}

	char description_string[512];
	items_game.GetString("description_string", description_string, 512);

	/* Not an English speaker? Too bad! */
	KeyValues language = new KeyValues("lang");
	if (!language.ImportFromFile("resource/tf_english.txt"))
	{
		PrintToServer("[Mallet::AttributeLocale] Failed to open resource/tf_english.txt!");

		delete language;
		delete items_game;
		return false;
	}

	if (!language.JumpToKey("Tokens"))
	{
		PrintToServer("[Mallet::AttributeLocale] Failed to find the Tokens object!");

		delete language;
		delete items_game;
		return false;
	}

	language.GetString(description_string, value, valueSize, "N/A");

	delete language;
	delete items_game;
	return true;
}

/* native bool MalletGetRawAttributeDescription(int key, char[] value, int valueSize) */
public int Native_GetRawAttributeDescription(Handle plugin, int numParams)
{
	if (numParams != 3)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int key = GetNativeCell(1);
	int valueSize = GetNativeCell(3);

	if (valueSize <= 0 || valueSize > 2048)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid valueSize (%i)", valueSize);
	}

	char[] strAttrib = new char[valueSize];
	GetNativeString(2, strAttrib, valueSize);

	bool retValue = InternalGetRawAttributeDescription(key, strAttrib, valueSize);
	SetNativeString(2, strAttrib, valueSize);

	return retValue;
}

/* native bool MalletGetAttributeDescription(int key, char[] value, int valueSize, any value) */
public int Native_GetAttributeDescription(Handle plugin, int numParams)
{
	if (numParams != 4)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid parameter count (%i)", numParams);
	}

	int key = GetNativeCell(1);
	int valueSize = GetNativeCell(3);

	if (valueSize <= 0 || valueSize > 2048)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid valueSize (%i)", valueSize);
	}

	char[] strAttrib = new char[valueSize];
	GetNativeString(2, strAttrib, valueSize);

	if (!InternalGetRawAttributeDescription(key, strAttrib, valueSize))
		return false;

	if (StrContains(strAttrib, "%s1"))
	{
		/* TODO: Replace %s1 with the value given. */
		SetNativeString(2, "TODO", sizeof("TODO"));
	}
	else
	{
		SetNativeString(2, strAttrib, valueSize);
	}

	return true;
}

