************************************************************************
file with basedata            : cr413_.bas
initial value random generator: 836466103
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  132
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       24        4       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          10  15
   3        3          3           8  13  14
   4        3          3           5   6  11
   5        3          3          10  12  13
   6        3          3           7  13  15
   7        3          1          10
   8        3          2           9  16
   9        3          1          12
  10        3          1          14
  11        3          3          12  14  16
  12        3          2          15  17
  13        3          2          16  17
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     2       7    8    7    4    0    9
         2     2       6    8    7    4    2    0
         3     4       1    8    2    4    0    9
  3      1     6       5    6   10    8    0   10
         2     6       5    6    9    9    4    0
         3     8       4    6    8    7    4    0
  4      1     5       6    8    5    6    0    4
         2     9       4    5    3    2    1    0
         3     9       3    4    5    4    0    4
  5      1     2       8    8    7   10    0    1
         2     4       5    8    7    8    4    0
         3    10       4    8    7    6    4    0
  6      1     2       5    2    7   10    0    9
         2     4       4    2    7   10    0    3
         3     9       4    1    6    9    7    0
  7      1     1       5    7    8    8    6    0
         2     9       3    4    7    7    0    5
         3    10       3    4    5    6    0    4
  8      1     9       7    4    3   10    7    0
         2     9       6    4    3    8    8    0
         3    10       5    4    3    7    0    2
  9      1     1       6    3    6    7    5    0
         2     5       6    2    2    5    0    7
         3     5       4    2    3    5    0    7
 10      1     2       8    3    8    7    0   10
         2    10       7    3    7    5    7    0
         3    10       5    3    7    6    5    0
 11      1     3       8    7    6    2    0    3
         2     3       7    7    6    2    6    0
         3     5       6    7    5    2    0    4
 12      1     2      10    6    9    9    6    0
         2     2       9    6    6    9    0    8
         3     8       8    6    2    8    5    0
 13      1     4       5    7    6    6    0    8
         2     8       4    6    5    4    8    0
         3    10       4    5    5    3    6    0
 14      1     1       8    2    2    7    0    6
         2     5       8    1    2    6    0    3
         3     9       7    1    1    3    0    3
 15      1     1       6    9    9    5    9    0
         2     7       3    7    8    5    8    0
         3     8       3    7    6    4    8    0
 16      1     1       9    4    9    7    0    7
         2     5       6    3    9    6    0    7
         3     7       3    3    8    6    7    0
 17      1     6       8    9    8   10    4    0
         2     8       8    8    5   10    0    6
         3    10       6    7    1    9    4    0
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   13   12   14   15   46   50
************************************************************************
