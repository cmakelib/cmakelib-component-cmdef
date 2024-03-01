#pragma once

namespace second {

  class InterfaceFirst {
  public:
    virtual ~InterfaceFirst() = default;
    virtual void printMessage();
  };

}