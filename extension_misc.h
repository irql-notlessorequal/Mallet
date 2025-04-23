inline CreateInterfaceFn ServerFactory()     { return g_SMAPI->GetServerFactory    (false); }

#define GET_IFACE_OPTIONAL(factory, var, name) \
	var = reinterpret_cast<decltype(var)>(ismm->VInterfaceMatch(factory##Factory(), name, -1)); \
	if (var == nullptr) { \
		DevWarning("Could not find optional interface: %s\n", name); \
	}

#define GET_IFACE_REQUIRED(factory, var, name) \
	var = reinterpret_cast<decltype(var)>(ismm->VInterfaceMatch(factory##Factory(), name, -1)); \
	if (var == nullptr) { \
		if (error != nullptr && maxlength != 0) { \
			ismm->Format(error, maxlength, "Could not find required interface: %s", name); \
		} \
		return false; \
	}