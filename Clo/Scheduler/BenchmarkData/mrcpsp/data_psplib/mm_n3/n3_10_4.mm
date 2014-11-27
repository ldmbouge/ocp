************************************************************************
file with basedata            : cn310_.bas
initial value random generator: 753329325
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  131
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       15        5       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  11  13
   3        3          3           5   8  11
   4        3          2           6   7
   5        3          3           9  10  12
   6        3          3           8  10  16
   7        3          2          10  17
   8        3          1           9
   9        3          1          13
  10        3          1          15
  11        3          3          14  15  17
  12        3          2          13  16
  13        3          2          15  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     4       7    0    0   10    0
         2     9       6    0    0   10    6
         3    10       0    9    0    0    5
  3      1     3       1    0    0    0    7
         2     7       0    5    0    0    5
         3    10       0    5    9    0    0
  4      1     1       0    7    8    7    9
         2     5       0    7    0    0    5
         3     5       0    7    0    5    0
  5      1     4       0    7    9    0    0
         2     7       7    0    9    2    0
         3     9       2    0    0    1    0
  6      1     4       0    7    7    0    2
         2     5       0    5    0    4    0
         3     6       0    1    7    4    0
  7      1     3       9    0    3    0    0
         2     5       0    6    3    3    0
         3     7       0    2    0    0    7
  8      1     1       9    0    8    0    8
         2     6       7    0    4    0    7
         3     8       6    0    0    0    7
  9      1     1       8    0    0    2   10
         2     4       5    0    7    2    0
         3     9       0    3    5    0   10
 10      1     3       0    8    4    1    0
         2     9       0    8    0    0    6
         3    10       0    8    4    0    0
 11      1     2       0    9    6    6    0
         2     2       0    9    0    0    6
         3     7       2    0    6    6    0
 12      1     2       4    0   10    0    0
         2     7       3    0    0    0    5
         3    10       0    6   10    0    3
 13      1     1       9    0    0    7    0
         2     5       0    1    0    6    6
         3     7       8    0    8    0    4
 14      1     5       0    7    0    7    8
         2     8      10    0    0    0    8
         3     9       0    6    0    3    7
 15      1     5       0    6    0    0    7
         2     8       3    0    5    6    0
         3    10       2    0    5    0    6
 16      1     3       4    0    2    0    9
         2     3       4    0    0    3   10
         3     7       4    0    0    0    7
 17      1     1       7    0    7    7    0
         2     5       5    0    5    0    0
         3     7       0    5    0    0    9
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   17   16   47   33   64
************************************************************************
