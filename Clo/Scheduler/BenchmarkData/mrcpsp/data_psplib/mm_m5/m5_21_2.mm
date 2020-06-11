************************************************************************
file with basedata            : cm521_.bas
initial value random generator: 1711989523
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  132
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       13        1       13
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          2           5   8
   3        5          3           7   8  10
   4        5          3           7   8  15
   5        5          2           6  11
   6        5          3           7   9  12
   7        5          1          13
   8        5          1          11
   9        5          3          10  16  17
  10        5          1          15
  11        5          2          13  17
  12        5          3          13  14  17
  13        5          1          16
  14        5          2          15  16
  15        5          1          18
  16        5          1          18
  17        5          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1      10    4    9    0
         2     1      10    4    0    5
         3     8       6    4    9    0
         4     9       5    4    8    0
         5     9       5    4    0    4
  3      1     1       8    8    8    0
         2     1       8    9    7    0
         3     2       8    6    7    0
         4     4       8    5    5    0
         5    10       7    4    3    0
  4      1     3       9    7    0    8
         2     3       9    6    9    0
         3     4       8    6    0    8
         4     8       8    5    0    7
         5     9       8    4    8    0
  5      1     4       7    5    4    0
         2     4       7    5    0    6
         3     5       7    3    4    0
         4     6       5    2    3    0
         5     6       5    1    4    0
  6      1     2       6    6    9    0
         2     3       5    6    0    8
         3     4       5    6    0    3
         4     5       4    5    8    0
         5     5       4    5    0    2
  7      1     1       7    9    4    0
         2     7       6    9    0    3
         3     9       6    8    4    0
         4    10       4    8    2    0
         5    10       5    8    1    0
  8      1     1      10    3    0    5
         2     1      10    4    0    4
         3     1      10    4    4    0
         4     6      10    2    4    0
         5     8      10    2    1    0
  9      1     2       6    4    8    0
         2     2       6    4    0    8
         3     3       5    3    0    4
         4     5       5    2    0    3
         5     5       5    2   10    0
 10      1     3       5    8    0    7
         2     3       5    8    8    0
         3     5       5    5    6    0
         4     7       5    4    4    0
         5     9       4    3    0    7
 11      1     3       3    4    7    0
         2     6       3    4    0    9
         3     8       3    3    0    7
         4     8       3    2    0    8
         5    10       2    2    4    0
 12      1     1       7    4    6    0
         2     3       6    4    6    0
         3     4       5    3    5    0
         4     5       3    2    5    0
         5     8       1    1    4    0
 13      1     4       7    9    0   10
         2     4       9    9    8    0
         3     4       9    8    0    9
         4     7       5    7    0    8
         5     9       3    6    0    6
 14      1     4       8    5    2    0
         2     6       6    5    0    6
         3     7       6    2    1    0
         4     7       5    3    0    4
         5    10       2    1    1    0
 15      1     1       3    3   10    0
         2     2       3    2   10    0
         3     3       3    2    0    6
         4     6       3    2    9    0
         5     8       3    1    0    6
 16      1     1       6    4    0    5
         2     2       5    4    0    3
         3     6       5    3    9    0
         4     6       4    3    0    3
         5     7       4    2   10    0
 17      1     3       9    8    0    7
         2     5       8    7    0    7
         3     6       6    6    3    0
         4     8       4    4    3    0
         5     9       4    3    2    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   15   14   85   70
************************************************************************
