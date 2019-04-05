//
//  mps.hpp
//  mpsReader
//
//  Created by Laurent Michel on 5/24/16.
//  Copyright © 2016 Laurent Michel. All rights reserved.
//

#ifndef mps_hpp
#define mps_hpp

#include "model.hpp"

namespace MPSReader {
   Model::Ptr readMPSFile(const std::string& fname);
};

#endif /* mps_hpp */
