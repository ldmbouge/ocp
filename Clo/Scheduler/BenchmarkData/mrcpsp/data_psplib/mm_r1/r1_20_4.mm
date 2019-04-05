************************************************************************
file with basedata            : cr120_.bas
initial value random generator: 499062867
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  145
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21        6       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           9  10
   3        3          3           5   6   8
   4        3          2           7  13
   5        3          3           7   9  10
   6        3          2           9  10
   7        3          3          12  15  17
   8        3          1          13
   9        3          3          13  14  15
  10        3          2          11  17
  11        3          2          12  15
  12        3          1          14
  13        3          2          16  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     5       3    5    0
         2     9       0    5    0
         3    10       3    3    0
  3      1     1       5    4    0
         2     6       0    0   10
         3     9       0    0    5
  4      1     2       9    0    8
         2     9       0    8    0
         3     9       0    0    5
  5      1     4       0    0    9
         2     7       8    0    7
         3     9       4    0    6
  6      1     4       6    7    0
         2     5       3    4    0
         3     7       1    0    5
  7      1     2       2    5    0
         2     4       0    0    6
         3     8       0    5    0
  8      1     3       0    0    6
         2     5       0    0    5
         3    10       0    5    0
  9      1     5       3    9    0
         2     8       3    6    0
         3    10       0    0    8
 10      1     5       3    0    8
         2     6       0    0    3
         3     9       0    4    0
 11      1     2       0    0    9
         2     9       0    0    8
         3     9       7    5    0
 12      1     1       0    0    7
         2     3       4    0    4
         3     9       2    0    3
 13      1     4       4    0    6
         2     6       0    5    0
         3     9       0    0    5
 14      1     1       9    0    6
         2     9       7    1    0
         3    10       7    0    5
 15      1     4       0    7    0
         2    10      10    0    8
         3    10       0    2    0
 16      1     2       0    7    0
         2     3       8    6    0
         3     7       6    4    0
 17      1     7       0    0    6
         2     9       9    3    0
         3    10       0    0    3
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   28   58   79
************************************************************************
