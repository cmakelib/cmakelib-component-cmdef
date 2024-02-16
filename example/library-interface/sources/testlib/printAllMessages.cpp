
#include <test_c.hpp>

#include <second/InterfaceFirst.hpp>
#include <second/InterfaceSecond.hpp>

#include <testlib/printAllMessages.hpp>


namespace testlib {

int printAllMessages() {
  second::InterfaceFirst  first;
  second::InterfaceSecond second;

  first.printMessage();
  second.printMessage();

  return test_c();
}

}