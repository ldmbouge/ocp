************************************************************************
file with basedata            : mf40_.bas
initial value random generator: 64905385
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  32
horizon                       :  252
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     30      0       25       10       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           8
   3        3          3           5  13  24
   4        3          3           7  10  12
   5        3          2           6  27
   6        3          3          19  20  28
   7        3          1          14
   8        3          2           9  14
   9        3          1          11
  10        3          3          17  19  24
  11        3          1          29
  12        3          2          16  17
  13        3          3          15  18  25
  14        3          3          15  20  22
  15        3          2          23  31
  16        3          3          19  20  29
  17        3          3          21  26  28
  18        3          3          22  23  31
  19        3          1          21
  20        3          1          23
  21        3          1          30
  22        3          2          26  27
  23        3          1          26
  24        3          1          25
  25        3          2          27  28
  26        3          1          30
  27        3          1          30
  28        3          2          29  31
  29        3          1          32
  30        3          1          32
  31        3          1          32
  32        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       6    8    9    6
         2     8       6    8    7    5
         3     9       6    8    6    3
  3      1     2       6    4    9    8
         2     7       4    4    8    5
         3     8       2    4    8    5
  4      1     2       9    5    4    3
         2     8       8    5    4    2
         3    10       8    5    3    2
  5      1     2       9    9    3    8
         2     4       7    8    2    7
         3    10       4    8    1    7
  6      1     2       9    8    9    8
         2     9       8    7    4    4
         3    10       7    7    4    4
  7      1     1       9    5    7    3
         2     5       8    2    4    3
         3     5       8    1    5    2
  8      1     3      10   10    7   10
         2     6       3    9    5    9
         3     6       5    9    5    7
  9      1     9       5    9    4    3
         2     9       6    7    1    3
         3     9       3    7    5    4
 10      1     1       9    6    7    3
         2     7       7    5    6    3
         3    10       5    2    6    3
 11      1     3       1    5    9   10
         2     6       1    4    6    9
         3    10       1    3    3    9
 12      1     4       9    6    6    9
         2     4       8    7    6    9
         3     8       7    4    3    9
 13      1     2       3   10   10    7
         2     2       3    9    8    8
         3     4       3    6    8    6
 14      1     1       8    8    5    9
         2     9       5    7    4    8
         3    10       5    6    2    8
 15      1     3       5    2    7    6
         2     8       4    1    4    3
         3    10       4    1    3    3
 16      1     2      10    7    5    7
         2     9      10    5    4    5
         3    10       9    4    4    5
 17      1     2       5    3    4    6
         2     5       4    2    4    5
         3     6       3    2    1    5
 18      1     1      10    8    5    9
         2     9      10    8    4    8
         3    10       9    7    4    6
 19      1     1       7    4    4    7
         2     2       6    3    2    6
         3     3       4    3    2    4
 20      1     6       7    4    7    7
         2     7       6    2    4    6
         3    10       5    1    4    6
 21      1     4       6    7    6    7
         2     4       4    8    6    7
         3    10       1    6    6    5
 22      1     1       5    4    3    9
         2     5       3    3    3    9
         3     7       3    2    3    8
 23      1     3       5    8    5    8
         2     4       5    7    4    7
         3     9       3    6    4    7
 24      1     1       7    8    5    4
         2     1       6    8    6    4
         3     9       5    6    5    4
 25      1     4       6    9    5    7
         2     5       4    8    3    6
         3    10       3    7    2    5
 26      1     3       7    6    7    9
         2     3       6    8    6    9
         3     6       4    2    3    7
 27      1     1       9    9    7    8
         2     7       7    9    7    8
         3     8       3    8    3    8
 28      1     2       6    9   10    6
         2     2       7    8    7    6
         3     6       4    7    6    6
 29      1     3       5    6    6    9
         2     6       4    5    5    7
         3    10       4    3    3    7
 30      1     5       7    8    5    6
         2     7       5    7    4    5
         3     9       4    5    4    5
 31      1     1       8   10    6   10
         2     8       7    9    6    9
         3    10       6    9    4    9
 32      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   45   45  133  180
************************************************************************
