************************************************************************
file with basedata            : mf38_.bas
initial value random generator: 547580547
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  32
horizon                       :  236
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     30      0       24       19       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           6  23
   3        3          3           9  12  16
   4        3          3           5  16  31
   5        3          2          10  26
   6        3          3           7  11  15
   7        3          2           8  16
   8        3          2          18  29
   9        3          2          10  14
  10        3          2          17  24
  11        3          1          20
  12        3          2          13  14
  13        3          3          18  19  25
  14        3          3          15  22  28
  15        3          3          18  19  24
  16        3          2          22  30
  17        3          1          25
  18        3          1          31
  19        3          1          21
  20        3          3          22  25  27
  21        3          2          26  30
  22        3          1          29
  23        3          3          26  28  31
  24        3          1          27
  25        3          1          28
  26        3          1          27
  27        3          1          29
  28        3          1          30
  29        3          1          32
  30        3          1          32
  31        3          1          32
  32        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       2    2    9    5
         2     3       2    2    9    4
         3     5       2    1    8    1
  3      1     2       6    7   10    5
         2     2       6   10    9    4
         3     8       6    5    9    3
  4      1     1      10    6    9    5
         2     7       9    5    8    5
         3     9       9    5    6    4
  5      1     3       8   10    9    2
         2     5       7    9    9    1
         3    10       6    9    9    1
  6      1     3       7    8    8    4
         2     8       4    8    7    4
         3     8       5    8    6    1
  7      1     1       8    8    8    4
         2     3       7    4    6    4
         3     4       5    2    3    4
  8      1     4       6    6    4    5
         2     5       5    5    4    4
         3     9       5    5    2    4
  9      1     1       8    6    7    6
         2     1       8    7    7    5
         3     7       7    6    7    3
 10      1     2       5    9    5    4
         2     2       4    9    7    6
         3     2       5   10    4    5
 11      1     3      10    2    5    7
         2     6       5    2    1    5
         3     6       7    1    4    6
 12      1     3       9    9    5    8
         2     5       8    7    3    6
         3     8       7    4    2    5
 13      1     3       8    6    4    6
         2     5       5    5    4    5
         3    10       3    5    3    5
 14      1     5       9    9    4    5
         2     8       9    4    3    4
         3     9       8    4    1    2
 15      1     2       7    4    7    2
         2     7       6    2    6    2
         3     7       5    4    5    2
 16      1     4       6    8    4   10
         2     4       6    8    5    9
         3     5       4    7    3    7
 17      1     3       7    5    7    3
         2     5       5    5    7    3
         3    10       4    4    7    2
 18      1     6       6    9    8    7
         2     8       5    9    2    7
         3     8       5    8    3    7
 19      1     2       2    7    3    5
         2     9       1    5    2    2
         3     9       2    5    1    2
 20      1     1       8    3    2    8
         2     1       7    3    3    6
         3    10       6    2    2    3
 21      1     2       6    9    5    9
         2     4       4    7    4    9
         3     5       1    4    4    8
 22      1     1       7    8    9    7
         2     9       4    6    6    6
         3    10       4    2    6    4
 23      1     6       7    6    5    5
         2     7       5    5    3    4
         3     9       3    4    1    4
 24      1     3       6    4    5    4
         2     5       5    3    5    3
         3     8       3    2    5    3
 25      1     6       2    6   10   10
         2     9       1    3    8   10
         3     9       2    3    7   10
 26      1     1       4    2    4   10
         2     2       3    2    3    7
         3     7       3    2    1    5
 27      1     3       6    5    7    9
         2     4       6    5    3    8
         3    10       6    5    1    8
 28      1     2      10    3   10    9
         2     3       9    3    8    8
         3    10       7    2    7    5
 29      1     4       6    8    2    9
         2     7       5    6    2    8
         3     9       4    4    1    4
 30      1     2       5    4    6    4
         2     4       5    3    4    4
         3     5       2    3    2    4
 31      1     1       7    5    6   10
         2     8       6    4    6    7
         3    10       6    3    6    6
 32      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   31   28  139  142
************************************************************************
