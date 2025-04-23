#ifndef _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_
#define _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_

#include "smsdk_ext.h"

class Mallet : public SDKExtension
{
public:
	/**
	 * @brief This is called once all known extensions have been loaded.
	 * Note: It is a good idea to add natives here, if any are provided.
	 */
	virtual void SDK_OnAllLoaded();
};

#endif // _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_