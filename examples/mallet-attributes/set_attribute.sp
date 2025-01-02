#include <mallet>

public Plugin myinfo =
{
	name = "Set Attribute",
	author = "IRQL_NOT_LESS_OR_EQUAL",
	description = "Example plugin showing Mallet's Attribute interface in use.",
	version = "1.0.0",
	url = "https://github.com/irql-notlessorequal/Mallet"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_setattribute", SetAttribute, ADMFLAG_CHEATS, "Adds an attribute to self or a target player.");
}

/* sm_setattribute [client] {id} {value} */
public Action SetAttribute(int client, int args)
{
	int targetClient = -1;
	int id = -1;
	float value = -1;

	if (args == 3)
	{
		targetClient = GetCmdArgInt(0);
		id = GetCmdArgInt(1);
		value = GetCmdArgFloat(2);
	}
	else
	{
		targetClient = client;
		id = GetCmdArgInt(0);
		value = GetCmdArgFloat(1);
	}

	/* TODO: Replace "targetClient" with a ProcessTargetString call. */
	/* https://forums.alliedmods.net/showthread.php?t=300156 */

	if (targetClient == -1)
	{
		PrintToConsole(client, "[SetAttribute] Invalid target client!");
		return Plugin_Handled;
	}

	if (id == -1)
	{
		PrintToConsole(client, "[SetAttribute] Invalid attribute id!");
		return Plugin_Handled;
	}

	MalletSetAttribute(targetClient, id, value);
	return Plugin_Handled;
}