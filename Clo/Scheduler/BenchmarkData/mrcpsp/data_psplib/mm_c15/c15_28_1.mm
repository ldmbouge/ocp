************************************************************************
file with basedata            : c1528_.bas
initial value random generator: 16955
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  120
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       12        4       12
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1          15
   3        3          2          10  17
   4        3          2           5   9
   5        3          1           6
   6        3          3           7   8  11
   7        3          1          17
   8        3          2          14  15
   9        3          2          13  14
  10        3          2          11  12
  11        3          1          14
  12        3          2          15  16
  13        3          1          17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       9    0    0    5
         2     5       0    7    3    0
         3     8       0    6    0    4
  3      1     1       0    5    0    6
         2     2       0    1    5    0
         3     8       5    0    0    5
  4      1     1      10    0    0    2
         2     4       0    9    9    0
         3     6       9    0    7    0
  5      1     3       5    0    3    0
         2     4       4    0    3    0
         3     5       4    0    0    1
  6      1     1       6    0    0    3
         2     6       0    7    0    3
         3     8       4    0    0    2
  7      1     2       7    0    0    4
         2     3       0    6    3    0
         3     7       0    6    0    1
  8      1     1       7    0    0    7
         2     8       0    5    0    5
         3     9       5    0    0    3
  9      1     3       0    9    6    0
         2     4       0    9    0    5
         3    10       0    8    0    4
 10      1     2       2    0    5    0
         2     4       0    3    0    6
         3     6       0    2    0    4
 11      1     2       3    0    9    0
         2     4       0    5    6    0
         3     5       3    0    0    3
 12      1     3       3    0    4    0
         2     4       3    0    0    7
         3     8       3    0    0    6
 13      1     1       0    5    0    9
         2     5       1    0    8    0
         3    10       1    0    6    0
 14      1     2       0    5    0   10
         2     8       5    0    0    6
         3    10       4    0    5    0
 15      1     2       0    6    0    4
         2     4       0    2    5    0
         3     9       3    0    0    1
 16      1     3       0    7    0   10
         2     4       2    0    0    8
         3     6       0    7    0    5
 17      1     4       3    0    0    4
         2     4       0    3    2    0
         3     5       3    0    0    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   24   21   67   86
************************************************************************
