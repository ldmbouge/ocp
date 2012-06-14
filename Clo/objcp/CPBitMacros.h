/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/


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

