#ifndef _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_
#define _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_

#include "smsdk_ext.h"
#include "extension_misc.h"

class Mallet : public SDKExtension
{
public:
	virtual bool OnExtensionLoad(IExtension *me, IShareSys *sys, char *error, size_t maxlength, bool late);

	virtual void SDK_OnAllLoaded();

	virtual bool SDK_OnMetamodLoad(ISmmAPI *ismm, char *error, size_t maxlength, bool late);
};

#endif // _INCLUDE_SOURCEMOD_EXTENSION_PROPER_H_