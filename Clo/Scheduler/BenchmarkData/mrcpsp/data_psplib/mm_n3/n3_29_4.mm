************************************************************************
file with basedata            : cn329_.bas
initial value random generator: 1393333847
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  132
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        6       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  10  12
   3        3          3           6  11  12
   4        3          3           5   6   8
   5        3          3           9  10  11
   6        3          2           9  16
   7        3          3          14  15  16
   8        3          3          11  12  13
   9        3          1          13
  10        3          1          14
  11        3          1          15
  12        3          2          15  17
  13        3          1          14
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     4       9   10    7    0    9
         2     5       7    8    0    0    7
         3     6       3    5    7    5    6
  3      1     5       6    9    4    5    7
         2     8       6    5    0    3    0
         3     9       5    4    0    0    5
  4      1     2       9    6    0    7    0
         2     3       6    5    0    6    0
         3     5       6    5    5    0    0
  5      1     4       6    6    0    3    3
         2     9       3    4    4    0    0
         3    10       3    3    0    0    2
  6      1     6       6    6    4    9    6
         2     8       2    3    0    9    0
         3     8       4    5    0    7    0
  7      1     3       5    9    6    4    0
         2     4       4    7    6    0    6
         3     5       4    7    0    3    0
  8      1     4       7    9    4    7    0
         2     5       5    9    0    0    7
         3     9       5    7    3    7    5
  9      1     1      10    8    5    3    5
         2     4       9    7    0    0    3
         3     6       9    3    5    0    0
 10      1     2       2    7    0    8    7
         2     6       2    5    8    0    0
         3     9       1    5    0    8    6
 11      1     2       8    4    0    6    7
         2     8       8    4    5    0    5
         3    10       6    3    0    4    4
 12      1     2       4    8    0    0    2
         2     8       4    4    9    2    2
         3    10       3    4    0    0    1
 13      1     4       7    8    0    7    0
         2     4       6    9    6    0    0
         3    10       6    6    5    0    6
 14      1     1       4    7    0    7    7
         2     2       4    7    0    0    3
         3    10       2    7    0    4    0
 15      1     4       7    7    0    5    6
         2     5       7    5    0    3    0
         3     9       5    4    0    0    4
 16      1     3       7    8    2    0    0
         2     6       3    7    0    0    7
         3     9       3    7    0    5    0
 17      1     5       5    8    0    0    9
         2     5       6    6    0    0    9
         3     7       3    4    0    0    6
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   14   14   69   83   94
************************************************************************
