************************************************************************
file with basedata            : cr514_.bas
initial value random generator: 1675798564
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  134
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21       14       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6  11
   3        3          3           9  13  15
   4        3          3           8   9  16
   5        3          3           7   8  13
   6        3          2          12  13
   7        3          3          10  14  15
   8        3          2          10  15
   9        3          2          10  11
  10        3          1          17
  11        3          1          17
  12        3          1          14
  13        3          2          16  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     5       7    4    7    7    6    0    2
         2     7       6    4    7    7    6    0    2
         3     8       6    4    7    6    6   10    0
  3      1     2       4    7    6    1    9    4    0
         2     5       4    7    5    1    4    0    7
         3     8       4    7    3    1    4    3    0
  4      1     1       8   10    2    4    2    0    3
         2     4       3    8    2    4    2    3    0
         3     4       4    8    2    4    2    0    1
  5      1     2       6    8    5    6    8    4    0
         2     5       5    7    4    6    8    0    4
         3     7       5    4    1    6    8    0    3
  6      1     1      10    9   10    8    3    0    8
         2     8      10    6    9    7    2    7    0
         3     9       9    6    8    7    1    4    0
  7      1     3       6    8    1    6    7    3    0
         2     9       5    7    1    4    5    0    8
         3    10       5    6    1    3    3    0    5
  8      1     4       6    6    8    7    9    8    0
         2     9       4    4    7    6    8    4    0
         3    10       4    4    6    3    5    0    3
  9      1     2       7    6    5    6    6    4    0
         2     6       5    5    4    5    5    0    7
         3     9       5    2    3    4    4    1    0
 10      1     7       6    5    9    7    7    0    7
         2     8       4    4    8    7    7    7    0
         3     8       6    4    8    7    5    0    6
 11      1     3       7    5    3    5    9    0    6
         2     5       7    5    3    5    9    4    0
         3    10       4    5    2    4    9    0    6
 12      1     7       6    9    2   10    3    7    0
         2     7       6    9    3   10    3    0    7
         3    10       6    6    2    3    3    0    2
 13      1     3      10    6    6    8    5    0    9
         2     6       7    6    6    8    5    0    9
         3     8       3    6    5    7    3    0    9
 14      1     4       7    8    7    7    9    7    0
         2     9       6    8    5    5    9    7    0
         3    10       4    6    5    3    8    6    0
 15      1     1       5   10    5    3    8    0    2
         2     2       3    7    5    3    7    6    0
         3     6       1    6    3    3    7    1    0
 16      1     4       7    7    2    5    4    0    5
         2     6       7    7    2    5    4    3    0
         3     7       6    6    1    3    1    1    0
 17      1     1       3    4    9    5    6    0    6
         2     4       3    4    7    4    6    0    4
         3    10       2    3    7    1    3    2    0
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   22   21   15   22   21   43   47
************************************************************************
