************************************************************************
file with basedata            : cr54_.bas
initial value random generator: 1721884004
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  125
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       30        9       30
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          15  16  17
   3        3          2           7  17
   4        3          1           5
   5        3          3           6   7  10
   6        3          3           8   9  13
   7        3          2           9  13
   8        3          2          11  12
   9        3          3          11  12  16
  10        3          3          12  13  17
  11        3          1          14
  12        3          1          14
  13        3          2          15  16
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     2       0    0    0    6    6    6    0
         2     2       0    0    0    4    5    0    2
         3     9       0    0    0    0    3    7    0
  3      1     2       3    0    0    0    7    7    0
         2     4       0    6    0    0    0    7    0
         3     5       0    4   10    7    0    1    0
  4      1     7      10    2    0    0    6    6    0
         2     8       9    0    3    3    5    4    0
         3     9       9    0    0    3    3    0    4
  5      1     4       0    0    3   10    0    7    0
         2     6       7    6    0    0    7    3    0
         3     8       0    5    0    4    6    0    8
  6      1     1       0    6    0    0    0    0    5
         2     4       6    0    8    5    0    0    3
         3     5       0    0    6    0    2    4    0
  7      1     1       6    0    0    6    0    0    7
         2     3       0    7    7    4    5    8    0
         3     4       3    0    0    0    5    4    0
  8      1     5       8    0    0    0    8    0    6
         2     6       4    0    4    7    0    0    5
         3    10       0    9    0    7    0    4    0
  9      1     3       6    5    8    3    0    7    0
         2     4       0    0    0    2    0    5    0
         3     6       5    1    0    2    0    0    1
 10      1     2       0    0    0    0    6    0    8
         2     5       0   10    0    7    0    8    0
         3    10       9    0    6    5    3    4    0
 11      1     2       0    0    0    4    2   10    0
         2     2       6    0    5    0    0   10    0
         3     6       4    0    0    0    0    0    4
 12      1     6       4    9    2    9    2    0    9
         2     6       8   10    2    0    0    0    8
         3    10       0    0    2    0    0    0    5
 13      1     4       0    0    7    8    0    0   10
         2    10       8    7    3    7    6    4    0
         3    10       8    0    3    7    6    0    8
 14      1     5       3    0    7    0    7    7    0
         2    10       0    0    0    7    3    0    2
         3    10       0    6    0    0    3    1    0
 15      1     2       0    4    3    6    9   10    0
         2     9       2    0    0    5    0    7    0
         3     9       0    0    2    4    0    0    2
 16      1     2       0    9   10    0   10    0   10
         2     3       0    6    7    0    0    7    0
         3     4       4    0    7    0    9    0    4
 17      1     4       7    0    5    0    0    3    0
         2     6       7    6    4    0    9    2    0
         3    10       6    0    0    9    0    2    0
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   29   27   21   27   23   27   23
************************************************************************
