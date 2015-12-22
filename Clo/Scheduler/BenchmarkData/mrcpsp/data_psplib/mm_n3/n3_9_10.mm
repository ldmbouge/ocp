************************************************************************
file with basedata            : cn39_.bas
initial value random generator: 1492330285
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  113
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       29       13       29
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   9  15
   3        3          2           7   8
   4        3          3           5   6  15
   5        3          2           8   9
   6        3          3           7   8   9
   7        3          2          10  12
   8        3          2          13  14
   9        3          1          12
  10        3          3          11  14  17
  11        3          1          13
  12        3          3          13  14  17
  13        3          1          16
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
  2      1     5       0    5    0    7    7
         2     8       0    4    4    0    7
         3    10       7    0    0    5    0
  3      1     6       0    5    0    0    6
         2     6       4    0    0    9    5
         3     8       0    4    0    3    5
  4      1     5       0    4    0    6    0
         2     5       5    0    6    3    0
         3     7       5    0    4    0    8
  5      1     3       0    8    4    0    0
         2     4       2    0    0    6    0
         3     6       1    0    0    5    0
  6      1     4       0    5    0    7    0
         2     9       0    5    9    0    0
         3     9       8    0    9    0    0
  7      1     4       0    2    0    0    8
         2     7       0    1    0    0    8
         3     8       7    0    6    0    0
  8      1     3       3    0    5    2    0
         2     8       0   10    5    2    7
         3     9       0    6    5    1    0
  9      1     1       0    6    0    9    0
         2     3       7    0    9    8    0
         3     4       6    0    7    0    7
 10      1     6       9    0    8    7    0
         2     7       8    0    0    7    0
         3     7       0    1    0    7    0
 11      1     4       7    0    0    7    5
         2     5       0    1    4    5    0
         3    10       5    0    0    0    5
 12      1     4       4    0    0    9    9
         2     4       0    7    8   10    0
         3     5       4    0    0    8    0
 13      1     1       9    0    2    0    5
         2     4       0    7    0    4    3
         3     4       2    0    0    0    3
 14      1     9       0    1    0    0    9
         2     9       0    2    0    4    0
         3    10       8    0    0    4    0
 15      1     2       0    4   10    0    0
         2     2       3    0    7    6    0
         3     4       0    3    2    4    0
 16      1     1       0    3    3    7    4
         2     1       9    0    0    0    5
         3     3       0    3    3    0    0
 17      1     3       0    6    8    0    0
         2     5       0    4    8    4    7
         3     9       0    2    8    0    0
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
    5    7   51   56   46
************************************************************************
