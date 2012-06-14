#import <Foundation/NSObject.h>

int foo(int (^b)(int)) {
   return b(5);
}

int main() {

   int y = 10;
   int z = foo(^(int x) {
	 return y + x; 
      });
   NSLog(@"result is %d\n",z);
}
