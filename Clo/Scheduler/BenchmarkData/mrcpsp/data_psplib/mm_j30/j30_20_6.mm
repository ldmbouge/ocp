************************************************************************
file with basedata            : mf20_.bas
initial value random generator: 285514411
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  32
horizon                       :  232
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     30      0       24       15       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          11  13  19
   3        3          3           5   8  10
   4        3          3           7  16  26
   5        3          3           6  15  18
   6        3          1           9
   7        3          2          20  28
   8        3          2          13  31
   9        3          3          12  17  27
  10        3          3          13  20  25
  11        3          3          14  25  27
  12        3          1          25
  13        3          1          17
  14        3          3          17  24  26
  15        3          3          22  23  26
  16        3          2          21  27
  17        3          1          29
  18        3          2          23  30
  19        3          2          21  23
  20        3          1          21
  21        3          1          22
  22        3          1          24
  23        3          2          28  29
  24        3          2          29  30
  25        3          1          31
  26        3          1          30
  27        3          1          28
  28        3          1          31
  29        3          1          32
  30        3          1          32
  31        3          1          32
  32        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       0   10    0    6
         2     7       0    8    0    5
         3     8       0    6    4    0
  3      1     4       4    0    0    3
         2     6       0    4    6    0
         3     8       0    3    0    3
  4      1     1       0    8    0    7
         2     2       0    6    0    6
         3     8       0    3    0    6
  5      1     1       0    8    2    0
         2     1       0    8    0    6
         3     5       0    7    0    4
  6      1     4       6    0    0    6
         2     6       0    8    8    0
         3     8       4    0    0    5
  7      1     4       0    8    0    6
         2     4       0    8    4    0
         3     6       0    3    4    0
  8      1     4       0    3    0    7
         2     7       3    0    0    4
         3    10       2    0    0    3
  9      1     1       0    2    0    4
         2     4       8    0    9    0
         3     8       8    0    7    0
 10      1     3       8    0    9    0
         2     4       0    2    0    6
         3    10       8    0    8    0
 11      1     1       0   10    0    4
         2     2       3    0    0    3
         3     5       3    0    9    0
 12      1     5       0    9    5    0
         2     6       7    0    4    0
         3     8       0    7    0    5
 13      1     4       8    0    8    0
         2     6       5    0    7    0
         3     6       0    5    0    7
 14      1     1       7    0    0    7
         2     3       0    6    0    6
         3    10       0    6    6    0
 15      1     2       2    0    0    8
         2     4       0   10    8    0
         3     9       0    9    3    0
 16      1     3       0   10    0    7
         2     3       2    0    0    7
         3     5       2    0    0    4
 17      1     1      10    0    8    0
         2     6       0    2    0    4
         3     8       9    0    0    3
 18      1     1       0    8    0    8
         2     2       3    0    2    0
         3     8       3    0    0    6
 19      1     2       0    4    0    2
         2     2       3    0    0    3
         3     3       0    4    0    1
 20      1     4       5    0    0    7
         2     6       5    0    6    0
         3     9       5    0    5    0
 21      1     2       8    0    0    6
         2     5       0    1    6    0
         3     9       6    0    0    5
 22      1     3       0    9    9    0
         2     5       0    8    9    0
         3     7       4    0    0    3
 23      1     2       4    0    0    4
         2     8       0    8    3    0
         3     8       4    0    4    0
 24      1     5       0    5    8    0
         2     6       0    5    6    0
         3     9       0    4    3    0
 25      1     2       5    0    0    7
         2     9       3    0    6    0
         3    10       0    6    0    6
 26      1     4       6    0    8    0
         2     7       5    0    5    0
         3     8       0    5    0    6
 27      1     3       3    0    6    0
         2     6       0    3    3    0
         3     7       0    2    0    5
 28      1     4       0    3    0    7
         2     5      10    0    8    0
         3     8       0    2    4    0
 29      1     1       8    0    6    0
         2     1       0    7    0    7
         3     5       0    7    8    0
 30      1     3       7    0    0   10
         2     4       0    5    0    3
         3     9       3    0    6    0
 31      1     1       0    8    6    0
         2     4       9    0    0    6
         3    10       0    7    0    6
 32      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   29   36  128  133
************************************************************************
