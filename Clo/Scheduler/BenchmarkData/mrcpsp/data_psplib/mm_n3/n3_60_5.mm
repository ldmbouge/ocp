************************************************************************
file with basedata            : cn360_.bas
initial value random generator: 264841288
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  122
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       11       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  11  13
   3        3          2           6  12
   4        3          2           5   8
   5        3          3          11  13  14
   6        3          1          14
   7        3          2          10  15
   8        3          3           9  10  14
   9        3          3          12  13  17
  10        3          2          16  17
  11        3          3          12  16  17
  12        3          1          15
  13        3          1          16
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     1       0    6    3    6   10
         2     5       0    5    2    3    8
         3    10       4    0    2    3    7
  3      1     3       0    6    3    6    9
         2     6       3    0    3    5    7
         3    10       2    0    3    4    6
  4      1     4       6    0    7    9    6
         2     5       2    0    7    8    6
         3     6       0    9    7    8    5
  5      1     2       0    9    8    5    8
         2     3       4    0    5    3    7
         3     8       4    0    5    1    5
  6      1     2       6    0    3    6    9
         2     2       7    0    4    6    7
         3     7       0    7    3    5    5
  7      1     2       0    8    5   10    6
         2     3       8    0    4    9    6
         3     5       0    3    1    9    6
  8      1     6       6    0    7    8    8
         2     9       5    0    5    8    7
         3    10       0    6    3    7    7
  9      1     2       0    6   10    7    9
         2     3       8    0    8    6    9
         3     4       0    5    7    3    8
 10      1     2       0    8   10    7    9
         2     4       0    8    9    7    8
         3     7       0    8    9    6    5
 11      1     5       0    4    9    5    5
         2     7       3    0    9    4    4
         3     9       3    0    9    4    1
 12      1     5       0    8    7    1    6
         2     8       0    4    3    1    6
         3     9       4    0    1    1    5
 13      1     3       0    4    9    7    7
         2     7       0    3    5    5    7
         3    10       9    0    2    3    7
 14      1     2       2    0    7    5    9
         2     4       1    0    5    5    7
         3     5       0    7    4    2    6
 15      1     2       0    9    6    9    4
         2     3       3    0    5    8    4
         3     6       0    7    3    8    4
 16      1     1       0    9    6    9   10
         2     5       0    5    5    8    9
         3     8       7    0    5    8    9
 17      1     1       0    2    4    8    9
         2     7       1    0    3    7    5
         3     8       0    2    2    7    4
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   21   23  105  108  124
************************************************************************
