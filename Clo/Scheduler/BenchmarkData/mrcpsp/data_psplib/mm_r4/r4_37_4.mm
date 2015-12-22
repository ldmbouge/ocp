************************************************************************
file with basedata            : cr437_.bas
initial value random generator: 1116126555
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        3       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5  11  17
   3        3          3           6   9  10
   4        3          1           7
   5        3          3           6   8  10
   6        3          1          12
   7        3          2          10  14
   8        3          3          12  13  14
   9        3          2          11  17
  10        3          1          16
  11        3          3          12  13  14
  12        3          2          15  16
  13        3          2          15  16
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
  2      1     3       4    3    7    8   10    9
         2     8       3    3    7    8   10    8
         3    10       3    2    7    3    9    6
  3      1     1       9    3    8    6    8    2
         2     7       9    3    6    4    7    1
         3    10       7    3    2    3    5    1
  4      1     1       8    5   10    8    5    7
         2    10       4    4    8    8    5    5
         3    10       4    2    9    8    4    4
  5      1     3       4    7   10    7    5    7
         2     5       4    6    4    4    4    6
         3     6       3    6    1    3    3    5
  6      1     3       9    4    6    7    6   10
         2     5       7    4    4    7    6   10
         3     6       5    4    2    6    6   10
  7      1     1       7    4    9    9    6    3
         2     6       6    4    9    7    4    2
         3     7       6    4    9    6    1    1
  8      1     2       9    6    6    8    7    9
         2     3       9    6    4    5    4    7
         3     7       7    5    3    3    1    4
  9      1     1       8    2    7    6    3   10
         2     4       6    2    6    5    3    9
         3     9       4    2    5    5    2    8
 10      1     1       9    8    3    7    6    6
         2     4       8    6    3    7    4    3
         3    10       7    3    3    5    2    3
 11      1     2       6    8    9    4    8    8
         2     4       4    7    6    3    7    7
         3     8       1    5    4    3    4    6
 12      1     7       9    6    2    2    7    9
         2     8       8    4    2    2    3    8
         3     8       8    3    2    2    5    8
 13      1     1       9    6    9    4    2    8
         2     6       8    5    8    4    2    5
         3     7       7    4    7    3    2    4
 14      1     7       4    5   10    7    9    4
         2     7       4    6    9    7    9    4
         3    10       2    4    9    7    9    2
 15      1     3       8    9    4    4    3    3
         2     5       8    8    1    4    2    2
         3     5       7    7    3    4    3    2
 16      1     6       2    6    6   10    4    8
         2     6       2    6    5   10    3    9
         3     7       1    5    5   10    3    6
 17      1     3       6    7    6   10    7    5
         2     3       7    7    5    9    6    5
         3     4       4    7    3    5    5    4
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   13   11   13   13   70   83
************************************************************************
