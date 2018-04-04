/*
 u = [1.11, 2.22]; a = 0.25; b = 5000.0; n = 25.0; r = 0.0; xa = 0.25; h = ((b - a) / n);
 while (xa < 5000.0) do {
 xb = (xa + h) ;
 if (xb > 5000.0) {
 xb = 5000.0 ;
 gxa = (u / ((((((0.7 * xa) * xa) * xa) - ((0.6 * xa) * xa)) + (0.9 * xa)) - 0.2));
 gxb = (u / ((((((0.7 * xb) * xb) * xb) - ((0.6 * xb) * xb)) + (0.9 * xb)) - 0.2));
 r = (r + (((gxb + gxa) * 0.5) * h));
 xa = (xa + h);
 }
}
 u = [1.11, 2.22]; xa = 0.25; r = 0.0;
 while (xa < 5000.0) do {
 TMP_1 = (0.7 * (xa + 199.99));
 TMP_2 = (xa + 199.99);
 TMP_9 = ((((0.7 * xa) * xa) * xa) - ((0.6 * xa) * xa)) + (0.9 * xa);
 TMP_11= (((199.99 + xa) * (TMP_2 * TMP_1)) - ((199.99 + xa) * (TMP_2 * 0.6)))
 + (0.9 * TMP_2);
 r = (r + ((((u / (TMP_11 - 0.2)) + (u / (TMP_9 - 0.2))) * 0.5) * 199.99));
 xa = (xa + 199.99);
 }
 */

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
       // insert code here...
       NSLog(@"Hello, World!");
   }
   return 0;
}
