#include "utils.h"
#include "platform_utils.h"
#include <iostream>

int main() {
    std::cout << "CMDEF Test Executable" << std::endl;
    std::cout << "Version: " << get_version_string() << std::endl;
    std::cout << "Platform: " << get_platform_name() << std::endl;
    
    if (run_tests()) {
        std::cout << "All tests passed" << std::endl;
        return 0;
    } else {
        std::cout << "Some tests failed" << std::endl;
        return 1;
    }
}
