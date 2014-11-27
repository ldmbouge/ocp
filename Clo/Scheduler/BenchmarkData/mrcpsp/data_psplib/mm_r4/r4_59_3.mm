************************************************************************
file with basedata            : cr459_.bas
initial value random generator: 1638575742
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
    1     16      0       20        7       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   9  13
   3        3          3           5   8  11
   4        3          3           6   9  13
   5        3          3           7  12  17
   6        3          2          11  16
   7        3          2          14  15
   8        3          3           9  10  15
   9        3          1          12
  10        3          2          16  17
  11        3          1          15
  12        3          1          14
  13        3          2          14  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     2       7    7    0    7    7   10
         2     3       0    0    0    3    4    9
         3     6       6    4    0    0    4    8
  3      1     3       0    0    5    0    7    9
         2     6       2    0    0    0    5    9
         3     7       2    7    5    0    1    9
  4      1     1       0    0    0    8   10    9
         2     2       0    0    6    0   10    8
         3     4       0    6    0    8    9    4
  5      1     4       5    0    0    0   10    5
         2     8       3    0    0    0    7    4
         3    10       1    0    0    0    5    3
  6      1     5       6    0    7    0    1    6
         2     8       0    7    6    8    1    3
         3     8       0    8    0    8    1    5
  7      1     6       0    0    8    9    6    8
         2     9       5    0    8    6    4    4
         3     9       5    4    7    0    5    3
  8      1     5       8    8    0    7    7    7
         2     8       0    7    9    0    4    4
         3     9       0    0    7    0    3    4
  9      1     3       0    4    0    0    8   10
         2     7       0    4    0    8    7   10
         3     8       4    0    3    8    5   10
 10      1     3       0    0    6    5    7    4
         2     3       0    0    5    8    9    4
         3     5       9    9    0    0    4    3
 11      1     1       0    4    5    0    7    7
         2     3       6    2    3    1    7    7
         3     6       3    0    3    0    7    7
 12      1     2       0    0    6    4    8    3
         2     7       0    7    0    3    6    3
         3     9       8    7    5    2    4    2
 13      1     1       0    0    0    5    9    8
         2     4       2    0    0    4    8    6
         3     9       2    8    6    0    7    6
 14      1     5       0    7    0    4    8    9
         2     9       0    5    7    2    8    6
         3     9       0    0    9    1    6    7
 15      1     1       0    0    0    5    9    8
         2     7       0    3    0    0    5    7
         3    10       0    0    9    0    1    6
 16      1     2       5    0    5    0    5    4
         2     3       0    3    4    2    5    3
         3     8       2    0    4    0    2    2
 17      1     2       0    0    7    0    8    8
         2     6       0    2    0    3    8    5
         3     7       0    2    7    1    8    5
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   15   22   23   25  119  115
************************************************************************
