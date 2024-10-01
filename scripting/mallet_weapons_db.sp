/* Valve's KeyValues suck too much for me to bother using anything else, you are free to try and re-implement with them. */
#include <json>

#define FILE_LOCATION "addons/sourcemod/gamedata/mallet_weapons_db.json"
#define FILE_MAX_SIZE (1 * 1024 * 1024)

JSON_Array WEAPONS_DB;

public bool InitializeWeaponsDB() {
	int bufferSize = FileSize(FILE_LOCATION);

	if (bufferSize <= 0) {
		SetFailState("InitializeWeaponsDB: Got an invalid buffer size, you are probably missing a gamedata file.");
		return false;
	}

	Handle file = OpenFile(FILE_LOCATION, "r");
	char[] buffer = new char[bufferSize];

	int read = ReadFileString(file, buffer, FILE_MAX_SIZE, -1);
	if (read != bufferSize) {
		CloseHandle(file);
		SetFailState("InitializeWeaponsDB: Did not read the expected amount. (got: %i, wanted: %i)", read, bufferSize);
		return false;
	}

	CloseHandle(file);
	WEAPONS_DB = view_as<JSON_Array>(json_decode(buffer));

	return true;
}

JSON_Object InternalGetRandomWeaponKey(int targetSlot)
{
	JSON_Object valid_candidate = null;

	while (true)
	{
		int idx = GetRandomInt(0, WEAPONS_DB.Length - 1);
		JSON_Object candidate = WEAPONS_DB.GetObject(idx);

		if (candidate == null)
			continue;

		int slot = candidate.GetInt("slot");
		if (slot != targetSlot)
			continue;

		valid_candidate = candidate;
		break;
	}

	return valid_candidate;
}

int InternalCreateRandomizedWeapon(int client, int targetSlot)
{
	return -1;
}