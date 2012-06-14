#if !defined(_SILLY_H)
#define _SILLY_H

class  Silly {
   int _x;
   int _y;
public:
   Silly(int x,int y) : _x(x),_y(y) {}
   ~Silly() {}
   virtual long callMe(long z); 
};

#endif
