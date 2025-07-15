#include "utils.h"
#include <string>

std::string get_library_name() {
    return "CMDEF Test Library";
}

bool validate_input(int value) {
    return value >= 0;
}
