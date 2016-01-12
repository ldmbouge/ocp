************************************************************************
file with basedata            : mf60_.bas
initial value random generator: 1650874898
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
    1     30      0       31        6       31
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   9  13
   3        3          3           5  10  20
   4        3          1          29
   5        3          3           6  12  16
   6        3          3           7   8  30
   7        3          1          11
   8        3          3          17  22  24
   9        3          1          20
  10        3          2          15  16
  11        3          1          14
  12        3          1          19
  13        3          2          16  25
  14        3          1          28
  15        3          3          21  22  25
  16        3          2          18  19
  17        3          3          23  25  28
  18        3          3          21  27  30
  19        3          3          21  23  30
  20        3          1          22
  21        3          2          24  26
  22        3          3          23  27  28
  23        3          1          26
  24        3          1          31
  25        3          1          27
  26        3          1          29
  27        3          2          29  31
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
  2      1     3       0    4    6    4
         2     3      10    0    7    5
         3     7       0    3    6    3
  3      1     1       6    0    4    5
         2     3       5    0    3    4
         3     5       0    5    2    2
  4      1     4       0    8    4    8
         2     7       0    8    4    6
         3    10       0    8    3    4
  5      1     1       5    0   10    6
         2     5       0    7   10    2
         3     5       5    0   10    2
  6      1     1       5    0    8    9
         2     4       4    0    5    7
         3    10       0    6    3    7
  7      1     1      10    0    4    8
         2     2      10    0    4    6
         3     9      10    0    3    6
  8      1     1       0    8    5    7
         2     2       1    0    4    6
         3     3       0    5    3    5
  9      1     3       3    0    5    9
         2     6       0    3    5    7
         3     9       0    1    2    6
 10      1     1       0    6    7    7
         2     6       0    5    4    7
         3     8       0    5    2    6
 11      1     3       0    5    6    8
         2     6       0    3    5    7
         3     7       0    2    3    5
 12      1     6       6    0   10    5
         2     7       0    4   10    5
         3     8       0    4    9    4
 13      1     9       8    0    8   10
         2    10       0    8    5    8
         3    10       6    0    5    8
 14      1     1       5    0    5    2
         2     6       3    0    5    1
         3     6       0    3    5    2
 15      1     1       0    2    8    5
         2     4       0    2    6    5
         3     6       8    0    5    5
 16      1     1       9    0    8    6
         2     2       0    3    5    3
         3     5       2    0    4    3
 17      1     1       0    2    4    7
         2     5       0    2    3    6
         3     6       0    1    2    6
 18      1     4       0   10   10    9
         2     5      10    0   10    5
         3     8      10    0   10    2
 19      1     3       8    0   10    2
         2     6       0    3    9    1
         3     9       2    0    9    1
 20      1     2       9    0    9    9
         2     6       0    7    8    7
         3     7       7    0    8    5
 21      1     1       0    9   10    8
         2     2       1    0    6    7
         3     8       0    9    5    7
 22      1     1       0    9    5    7
         2     6       0    6    4    6
         3    10       0    5    2    4
 23      1     7       8    0   10    9
         2     8       0    3    9    9
         3     9       7    0    9    8
 24      1     1       4    0    3    5
         2     1       0    3    2    5
         3     8       0    3    1    4
 25      1     7       0    4    1    1
         2     9       2    0    1    1
         3    10       0    3    1    1
 26      1     1       7    0    8    5
         2     5       5    0    7    4
         3     6       4    0    7    4
 27      1     4       0    7    7    9
         2     7       6    0    7    7
         3    10       0    5    7    6
 28      1     7       8    0    7    7
         2     8       7    0    5    6
         3    10       0    7    3    5
 29      1     4       0    9    8    8
         2     5       0    9    6    5
         3     5       0    8    5    6
 30      1     5       5    0    4    5
         2     7       5    0    3    3
         3     8       5    0    2    3
 31      1     8       9    0    9    7
         2     9       9    0    8    7
         3    10       0    5    8    5
 32      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   36   25  204  198
************************************************************************
