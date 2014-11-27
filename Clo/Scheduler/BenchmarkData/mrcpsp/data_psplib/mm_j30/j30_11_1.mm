************************************************************************
file with basedata            : mf11_.bas
initial value random generator: 18843
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
    1     30      0       35       26       35
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1          30
   3        3          3           5   6  26
   4        3          3           7  16  17
   5        3          2          10  14
   6        3          3           8  10  15
   7        3          2           9  14
   8        3          3          13  17  23
   9        3          2          24  27
  10        3          3          11  19  21
  11        3          3          12  22  31
  12        3          1          24
  13        3          2          14  20
  14        3          3          18  21  22
  15        3          2          16  24
  16        3          3          23  25  29
  17        3          2          21  22
  18        3          2          19  25
  19        3          1          27
  20        3          2          28  31
  21        3          2          25  27
  22        3          1          30
  23        3          1          31
  24        3          1          29
  25        3          1          30
  26        3          1          28
  27        3          1          28
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
  2      1     5       8    0    6    0
         2     9       0    5    0    6
         3    10       0    4    6    0
  3      1     4       0    7    7    0
         2     5       0    5    7    0
         3     9       0    4    3    0
  4      1     1       5    0    0    7
         2     2       5    0    0    5
         3     5       0    3    0    4
  5      1     6       9    0    0    6
         2     7       8    0    0    3
         3     9       6    0    2    0
  6      1     3       5    0    8    0
         2     4       5    0    0    6
         3    10       4    0    2    0
  7      1     6       8    0    0    8
         2     7       0    4    0    6
         3     8       8    0    5    0
  8      1     1       5    0    7    0
         2     4       0    8    4    0
         3     5       0    8    3    0
  9      1     1       0    8    0    2
         2     9       0    6    9    0
         3    10       0    2    8    0
 10      1     1       0    9    0    5
         2     2       6    0    0    3
         3    10       5    0    1    0
 11      1     5       8    0    3    0
         2     6       0    1    0    7
         3     7       2    0    0    5
 12      1     4       0    7    0    9
         2     6       0    6    4    0
         3     7       0    4    0    9
 13      1     1       0    1    2    0
         2     4       0    1    1    0
         3     9       0    1    0    2
 14      1     5       4    0    0    9
         2     5       4    0    7    0
         3     6       0   10    4    0
 15      1     3       6    0    9    0
         2     4       0    5    0    9
         3     8       6    0    7    0
 16      1     1       9    0    0    5
         2     3       5    0    0    4
         3     6       3    0    0    4
 17      1     7       7    0    4    0
         2     7       0    6    0    8
         3     8       0    3    0    3
 18      1     1       0    8    0    5
         2     1       9    0    5    0
         3     4       7    0    4    0
 19      1     6       0    3    0    6
         2     8       5    0    5    0
         3     9       3    0    4    0
 20      1     3       1    0    0    9
         2     6       0    3    0    6
         3    10       0    3    0    2
 21      1     4       3    0    0    3
         2     5       0    2    7    0
         3     6       0    2    6    0
 22      1     4       0    6    0    6
         2     8       7    0    5    0
         3    10       0    5    2    0
 23      1     1       0    7    0    9
         2     2      10    0    0    8
         3     7      10    0    8    0
 24      1     6       8    0    0    6
         2     9       6    0    8    0
         3     9       0    5    0    5
 25      1     3       9    0   10    0
         2     5       0    8    0    9
         3    10       0    2    0    5
 26      1     3      10    0    0    9
         2     6       0    8    4    0
         3     7       9    0    3    0
 27      1     7      10    0   10    0
         2     9       8    0    0    5
         3     9       0    7   10    0
 28      1     1       0    7    0    9
         2     1       0    8    0    5
         3     2       1    0    9    0
 29      1     5       0    7    6    0
         2     6       0    7    4    0
         3     9       0    7    3    0
 30      1     1       7    0    0    6
         2     6       5    0    0    3
         3     7       0    8    8    0
 31      1     2       0    7    4    0
         2     5       0    5    4    0
         3     6       6    0    0    4
 32      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   32   28   86   93
************************************************************************
