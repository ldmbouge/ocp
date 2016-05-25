/*
 *  MPSReader.hpp
 *  MPSReader
 *
 *  Created by Laurent Michel on 5/24/16.
 *  Copyright © 2016 Laurent Michel. All rights reserved.
 *
 */

#ifndef MPSReader_
#define MPSReader_

/* The classes below are exported */
#pragma GCC visibility push(default)

#include "model.hpp"

namespace MPSReader {
   Model::Ptr readMPSFile(const std::string& fname);
};

#pragma GCC visibility pop
#endif
