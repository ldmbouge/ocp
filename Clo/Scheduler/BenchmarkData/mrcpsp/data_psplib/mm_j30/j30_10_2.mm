************************************************************************
file with basedata            : mf10_.bas
initial value random generator: 727208164
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  32
horizon                       :  241
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     30      0       28        1       28
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   8  14
   3        3          1          17
   4        3          3           5  15  24
   5        3          2           9  12
   6        3          3           7  18  22
   7        3          2          19  23
   8        3          2          10  19
   9        3          3          11  16  25
  10        3          2          23  26
  11        3          2          13  14
  12        3          1          30
  13        3          2          20  31
  14        3          2          26  31
  15        3          3          16  17  22
  16        3          1          20
  17        3          1          19
  18        3          3          20  24  25
  19        3          1          29
  20        3          2          21  30
  21        3          1          26
  22        3          3          28  30  31
  23        3          2          24  25
  24        3          1          27
  25        3          2          27  28
  26        3          2          27  28
  27        3          1          29
  28        3          1          29
  29        3          1          32
  30        3          1          32
  31        3          1          32
  32        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       4    0    5    0
         2     4       3    0    0    3
         3     8       0    8    1    0
  3      1     1       8    0    6    0
         2     3       6    0    3    0
         3     7       5    0    0    8
  4      1     1       0   10    0    3
         2     4       7    0    0    3
         3     9       0    8    0    3
  5      1     3       3    0    7    0
         2     9       2    0    5    0
         3    10       0    2    2    0
  6      1     1       7    0    8    0
         2     9       0    5    8    0
         3    10       4    0    8    0
  7      1     6       6    0    0    8
         2     9       0    9    3    0
         3    10       6    0    0    7
  8      1     1       3    0    2    0
         2     7       3    0    0    8
         3     9       2    0    0    5
  9      1     5       0    4    7    0
         2     8       3    0    5    0
         3    10       0    3    5    0
 10      1     5       9    0    9    0
         2     7       7    0    0    8
         3    10       0    6    0    6
 11      1     5       5    0    0    9
         2     6       4    0    0    7
         3     6       0    5    7    0
 12      1     1       0    7    0    5
         2     3       0    6   10    0
         3     7       8    0    5    0
 13      1     4       6    0    0    4
         2     7       4    0    0    3
         3     8       2    0    5    0
 14      1     1       7    0    7    0
         2     6       6    0    0    2
         3     9       0   10    7    0
 15      1     4       9    0    0   10
         2     5       0    4    8    0
         3    10       8    0    0   10
 16      1     2       8    0    7    0
         2     4       6    0    0    3
         3     9       0    3    4    0
 17      1     2       4    0    0    7
         2     6       0    6    0    7
         3    10       0    3    5    0
 18      1     2       8    0    0    9
         2     3       0   10    0    6
         3     3       8    0    0    3
 19      1     6       0    5    0    8
         2     7       0    4    0    6
         3     9       0    4    0    2
 20      1     1       4    0    5    0
         2     4       3    0    5    0
         3     7       0   10    5    0
 21      1     1       8    0    0   10
         2     6       7    0    9    0
         3     6       0    5   10    0
 22      1     1       0    4    7    0
         2     2       6    0    6    0
         3     6       0    3    0    6
 23      1     1       9    0    0    8
         2     4       6    0    8    0
         3     7       5    0    0    5
 24      1     2       7    0    0    2
         2     2       0    8    0    2
         3     6       0    4    4    0
 25      1     5       2    0    6    0
         2     6       1    0    6    0
         3     8       0    8    0    9
 26      1     2       0    7    0    2
         2     4       8    0    0    2
         3     5       6    0    0    1
 27      1     1       0    6    9    0
         2     2       0    4    3    0
         3     8       0    4    0    7
 28      1     1       8    0    2    0
         2     5       0    7    0    6
         3     9       7    0    0    4
 29      1     5       0    4    0   10
         2     7       0    3    0    9
         3     8       8    0    0    8
 30      1     7       7    0    0    7
         2     7       0    8    4    0
         3     8       0    8    0    7
 31      1     1       0    9    0    3
         2     4       4    0    7    0
         3     9       3    0    7    0
 32      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   20   23   89   91
************************************************************************
