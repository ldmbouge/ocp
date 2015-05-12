************************************************************************
file with basedata            : cm513_.bas
initial value random generator: 217355036
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  148
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        0       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          2           5  12
   3        5          3           8  10  14
   4        5          3           9  11  15
   5        5          3           6   7   9
   6        5          3          13  14  16
   7        5          3           8  10  14
   8        5          1          11
   9        5          3          10  13  16
  10        5          1          17
  11        5          1          13
  12        5          2          16  17
  13        5          1          17
  14        5          1          15
  15        5          1          18
  16        5          1          18
  17        5          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       8    1    0    3
         2     3       8    1    7    0
         3     8       7    1    6    0
         4     9       7    1    0    3
         5    10       6    1    4    0
  3      1     4       4    6    5    0
         2     6       2    6    3    0
         3     6       2    5    0    7
         4     6       2    6    0    5
         5     7       1    5    3    0
  4      1     1       5    4    0    6
         2     5       4    3    5    0
         3     7       4    2    5    0
         4     9       3    2    5    0
         5    10       3    2    4    0
  5      1     2       7    4    0    6
         2     2       7    5    5    0
         3     5       7    4    4    0
         4     6       7    2    0    7
         5     9       7    2    3    0
  6      1     1       7    8    0    9
         2     1       7    7    0   10
         3     4       7    7    0    9
         4     6       6    6    9    0
         5     9       2    5    0    8
  7      1     5       9    7    9    0
         2     7       6    7    8    0
         3     9       6    5    0    6
         4     9       6    4    8    0
         5    10       3    3    8    0
  8      1     3       4    8    0    8
         2     7       4    7    0    6
         3     8       4    5    0    1
         4     8       3    5    0    3
         5     9       3    4    8    0
  9      1     1      10    9    9    0
         2     2      10    8    0    3
         3     6       9    8    0    2
         4     8       8    7    7    0
         5    10       8    6    4    0
 10      1     3      10   10    0    7
         2     5       7    8    0    7
         3     6       5    6    0    7
         4     6       4    7    9    0
         5     7       3    5    0    7
 11      1     2       9    3    0    2
         2     4       8    3    0    2
         3     5       7    3    0    2
         4     8       6    3   10    0
         5    10       5    3    9    0
 12      1     5       6    4    0    6
         2     7       6    3    6    0
         3     7       6    3    0    5
         4     7       5    3    0    6
         5     9       5    3    4    0
 13      1     1       9    3    0    6
         2     1       9    3    8    0
         3     8       8    3    0    7
         4     9       8    2    6    0
         5    10       7    1    5    0
 14      1     1       9    7    9    0
         2     8       6    6    8    0
         3     8       7    5    0    8
         4     8       6    6    0    8
         5    10       4    5    0    6
 15      1     1       9    9    7    0
         2     3       8    8    0    6
         3     3       8    7    5    0
         4     5       5    4    3    0
         5     9       4    4    0    6
 16      1     1       6    7    9    0
         2     1       8    7    0    5
         3     5       5    6    9    0
         4     7       4    6    0    2
         5     9       3    5    8    0
 17      1     4       7    3    0    5
         2     5       5    3    3    0
         3     5       6    3    0    4
         4     7       4    3    0    3
         5    10       1    2    0    1
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   15   13   59   48
************************************************************************
