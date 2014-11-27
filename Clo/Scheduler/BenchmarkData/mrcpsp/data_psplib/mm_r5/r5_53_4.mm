************************************************************************
file with basedata            : cr553_.bas
initial value random generator: 715051229
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  139
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       31        4       31
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           9  12  13
   3        3          1          10
   4        3          1           5
   5        3          3           6   7   8
   6        3          2          11  14
   7        3          3           9  10  13
   8        3          3          12  13  14
   9        3          3          15  16  17
  10        3          2          11  17
  11        3          1          12
  12        3          1          15
  13        3          2          15  16
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     2       6    9    8    5   10    2   10
         2     9       5    7    7    3    6    2    4
         3    10       4    7    4    2    4    1    1
  3      1     2       8    7   10   10    2   10    2
         2     3       7    6    9    9    2   10    1
         3    10       5    3    9    9    1   10    1
  4      1     3      10    4    4    8   10    2    7
         2     6      10    4    4    6    5    2    7
         3    10       9    2    4    6    3    2    4
  5      1     1       6    7    6    7    9    5    7
         2     1       8    6    6    7    9    4    7
         3     2       3    6    3    4    8    3    4
  6      1     1       9    4    5    6   10    6    1
         2     1       9    5    5    7    9    7    1
         3    10       9    4    2    6    6    5    1
  7      1     4       6    8   10    8    7    3   10
         2     4       5    7    9    9    7    2   10
         3     7       1    6    8    6    6    1    9
  8      1     1       7   10    5    5    6    9    4
         2     7       7    7    5    5    5    6    3
         3     9       7    6    5    4    5    5    2
  9      1     5       9    8    4    2    7    4    8
         2     7       8    7    4    2    6    3    7
         3     8       8    6    2    1    4    2    5
 10      1     6       7    2    7    6    5    7   10
         2     8       3    2    6    4    5    6    5
         3     8       4    2    5    5    2    6    5
 11      1     6       7    5    5    8    5    6    3
         2     7       7    5    4    7    4    5    3
         3    10       7    5    4    7    2    4    2
 12      1     6       3    8    6    6    5    8    7
         2     9       3    7    5    5    3    5    6
         3    10       2    7    2    2    2    5    5
 13      1     1       4    5    7    7    7    5    3
         2     1       4    5    7    5    6    6    4
         3     7       3    5    4    3    3    5    3
 14      1     3       7    6    4    6    8    5    7
         2     7       5    4    2    4    7    5    5
         3    10       3    4    2    3    5    3    2
 15      1     5       5    8    6    7    7    3    8
         2     9       5    6    3    7    6    3    7
         3    10       3    6    2    7    5    3    4
 16      1     7       8    8   10    9    6    7    5
         2     7       8    9   10    8    6    7    5
         3     8       7    8    7    7    5    6    3
 17      1     8       7    4    7    8    7    4    7
         2     9       7    2    6    4    5    4    7
         3    10       4    1    1    4    3    4    6
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   13   12   12   13   12   82   89
************************************************************************
