#include "mallet_strings.h"

cell_t MalletStrings::StringWordCountGeneric(const char* str)
{
	if (str == nullptr)
	{
		return -1;
	}

	int count = 0, i = 0;

	while (str[i] != '\0')
	{
		/**
		 * Skip any whitespaces.
		 */
		while (str[i] == ' ')
		{
            i++;
        }

		if (str[i] != '\0')
		{
			int j = i;
			while (str[j] != ' ' && str[j] != '\0')
			{
                j++;
            }

			count++;
            i = j;
		}
	}

	return count;
}