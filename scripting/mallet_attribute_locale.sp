#include "include/stocksoup/textparse"

static StringMap TRANSLATION_PAIRS;

public bool InitializeAttributeLocale()
{
	TRANSLATION_PAIRS = new StringMap();
	
	File file = OpenFile("resource/tf_english.txt", "rb", .use_valve_fs = true);
	if (!file)
	{
		PrintToServer("[Mallet::AttributeLocale] Failed to open resource/tf_english.txt!");
		return false;
	}

	/* Setup locale parser. */
	TranslationFileParser tfp;
	tfp.Init();
	tfp.OnKeyValue = OnTranslationPair;

	/* Parse the not-so KeyValues file. */
	tfp.ParseOpenUTF16File(file);
	delete file;
	
	/* Allow errors, not my fault Valve chose to add comments into the file... */
	return true;
}

void OnTranslationPair(const char[] key, const char[] value)
{
	/* Not an attribute string. */
	if (StrContains(key, "Attrib_") != 0)
		return;

	TRANSLATION_PAIRS.SetString(key, value);
}

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

	delete items_game;
	return TRANSLATION_PAIRS.GetString(description_string, value, valueSize);
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

