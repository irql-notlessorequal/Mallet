#include "mallet_items_parser.h"
#include <filesystem>
#include <pthread.h>

/**
 * Mallet's parser for "items_game.txt" within Team Fortress 2.
 */

using namespace std;
using namespace std::filesystem;

void *Parse(void* __ignored__)
{
	path directory = current_path();
	ConMsg("current dir: %s", directory.c_str());

	/* [TODO] */

	pthread_exit(NULL);
}

bool MalletItemsParser::Load()
{
#if defined(_WIN32)
	return CreateThread(NULL, 0, Parse, NULL, 0, 0) != NULL;
#elif defined(__linux__)
	pthread_t task;
	return pthread_create(&task, NULL, Parse, NULL) == 0;
#else
	assert(!"Unsupported operating system.");
	return false;
#endif
}
