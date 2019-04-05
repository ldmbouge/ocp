************************************************************************
file with basedata            : cm559_.bas
initial value random generator: 5699
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  144
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       14        3       14
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          3           5   8  15
   3        5          3           9  11  15
   4        5          2           7   8
   5        5          3           6  10  14
   6        5          2           7  13
   7        5          3           9  11  12
   8        5          3           9  10  13
   9        5          1          17
  10        5          3          11  12  17
  11        5          1          16
  12        5          1          16
  13        5          1          16
  14        5          1          17
  15        5          1          18
  16        5          1          18
  17        5          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       0    9    6    8
         2     4      10    0    5    6
         3     6       9    0    4    5
         4     9       9    0    3    4
         5     9       0    8    1    4
  3      1     1       6    0    6    8
         2     7       0   10    5    8
         3     8       5    0    4    5
         4     9       4    0    2    4
         5     9       0    8    2    5
  4      1     3       5    0    3    7
         2     6       3    0    3    5
         3     6       0    9    3    4
         4    10       3    0    2    3
         5    10       0    4    2    4
  5      1     1       0    9    5    9
         2     2       0    9    4    8
         3     7       8    0    3    8
         4     8       0    9    3    7
         5    10       6    0    3    6
  6      1     6       0    9    7    7
         2     7      10    0    6    7
         3     8       1    0    6    4
         4     8       0    7    5    5
         5    10       0    5    5    4
  7      1     1       7    0    8    8
         2     6       6    0    6    7
         3     8       0    5    6    6
         4     9       4    0    4    4
         5    10       0    5    4    4
  8      1     1       0    2    9    7
         2     3       0    2    7    7
         3     4       8    0    7    6
         4     7       0    2    4    5
         5    10       0    1    3    5
  9      1     1       0    6    6    9
         2     2       5    0    6    8
         3     3       3    0    5    5
         4     6       0    3    3    5
         5     7       0    3    2    4
 10      1     2       0    8   10    5
         2     6       9    0    9    4
         3     7       0    8    6    3
         4     8       6    0    5    3
         5    10       0    8    4    2
 11      1     2       8    0    6    9
         2     2       0    7    5    9
         3     3       0    6    5    9
         4     4       0    6    3    7
         5     9       0    4    3    5
 12      1     1       4    0   10    9
         2     3       0    2    8    8
         3     3       2    0    8    7
         4     4       1    0    5    6
         5     6       0    2    4    5
 13      1     1       0    9   10    5
         2     5       0    8    6    5
         3     7       0    8    4    5
         4     9       5    0    3    4
         5     9       0    7    2    3
 14      1     4       0    7    8    4
         2     5       7    0    8    4
         3     5       0    6    8    3
         4     6       7    0    6    3
         5     8       0    4    4    2
 15      1     2       9    0    8    6
         2     8       7    0    6    3
         3     8       0    4    5    5
         4    10       7    0    4    2
         5    10       0    1    3    3
 16      1     2       8    0    8    8
         2     3       0    2    8    7
         3     5       0    2    7    5
         4     8       0    2    7    3
         5     8       5    0    7    4
 17      1     1       9    0    9    7
         2     4       6    0    8    5
         3     7       0    4    6    5
         4     8       6    0    6    3
         5     9       0    4    4    2
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   20   26  119  116
************************************************************************
