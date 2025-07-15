#include "platform_utils.h"
#include <string>

std::string get_platform_name() {
#ifdef _WIN32
    return "Windows";
#elif __APPLE__
    return "macOS";
#elif __linux__
    return "Linux";
#else
    return "Unknown";
#endif
}

bool is_debug_build() {
#ifdef _DEBUG
    return true;
#else
    return false;
#endif
}
