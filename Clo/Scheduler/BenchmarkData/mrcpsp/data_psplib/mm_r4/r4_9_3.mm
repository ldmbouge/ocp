************************************************************************
file with basedata            : cr49_.bas
initial value random generator: 1574147068
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  115
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        7       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          10  11  12
   3        3          2           5  13
   4        3          3           7   9  12
   5        3          3           6   8  10
   6        3          1          12
   7        3          3          10  13  14
   8        3          2          15  16
   9        3          2          11  14
  10        3          2          15  16
  11        3          1          17
  12        3          3          14  16  17
  13        3          1          17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     6       0    5    9    0    0    3
         2     7       0    5    5    8    0    1
         3     7       8    0    0    0    0    3
  3      1     2       9    2    0    0    0    6
         2     2       0    8    0    0    0    6
         3     5      10    0    0    0    0    5
  4      1     2       8    8    8    0    9    0
         2     3       0    0    6    0    9    0
         3     3       5    0    0    0    0    6
  5      1     3       6    0    0    0    0    7
         2     6       0    5    7    7    0    7
         3     7       0    4    0    7    8    0
  6      1     2       6    0    7    9    0    4
         2     3       0    0    0    9    6    0
         3     8       6    0    0    9    1    0
  7      1     3       0    8    4    8    0    8
         2     4       0    7    2    0    5    0
         3     9       4    0    0    5    0    6
  8      1     1       0    5    4    0    7    0
         2     5       6    4    0    0    5    0
         3     5       8    0    2    0    2    0
  9      1     7       8    0    1    0    0    5
         2     7       0    6    0    0    1    0
         3     8       0    5    0    0    0    5
 10      1     3       2    0    4    6    7    0
         2     4       1    0    0    6    5    0
         3     5       1    0    0    0    0    4
 11      1     2       6    9    9    0    0    2
         2     6       6    4    0    6    0    1
         3     9       0    4    0    0    4    0
 12      1     5       2    0    0    0    0    6
         2     6       1    0    7    0    7    0
         3     7       1    1    0    2    0    5
 13      1     2       0    8    0    8    0    7
         2     7       5    0    6    2    6    0
         3     7       1    0    8    0    0    6
 14      1     4       0    7    0    0    6    0
         2     6       2    7    0    4    0    4
         3    10       0    0    0    3    0    4
 15      1     6       0    0    8    8    7    0
         2     7       0    5    7    5    0    6
         3     9       7    2    0    0    0    6
 16      1     4       7    0    6    4    0    3
         2     8       3    7    4    0    2    0
         3    10       0    0    0    3    1    0
 17      1     3       7    0    0    0    0    5
         2     5       6    6    0    4    0    4
         3     6       6    4    0    3    3    0
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   12    9    7   13   40   41
************************************************************************
