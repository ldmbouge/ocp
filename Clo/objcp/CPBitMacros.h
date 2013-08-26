/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORUtilities/ORTypes.h>

#define CP_BITMASK 0x00000001
#define CP_UMASK 0xFFFFFFFF
#define CP_DESC_MASK 0x80000000
#define WORDLENGTH 5
#define POINTERLENGTH 6
#define BITSPERWORD  (1<<WORDLENGTH)
#define BITSPERPOINTER (1<<POINTERLENGTH)
#define WORDIDX(idx) ((idx)>> WORDLENGTH)
#define BITIDX(idx)  ((idx)& ((1<<WORDLENGTH)-1))
#define ONEAT(idx)   (1<<BITIDX(idx))
#define ZEROAT(idx)  (~ONEAT(idx))

