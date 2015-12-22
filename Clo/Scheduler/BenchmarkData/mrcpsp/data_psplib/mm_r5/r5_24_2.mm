************************************************************************
file with basedata            : cr524_.bas
initial value random generator: 1721864446
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21        7       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           8  13  14
   3        3          3           5   6  11
   4        3          3           7  10  12
   5        3          3           9  12  13
   6        3          1          12
   7        3          3          11  14  16
   8        3          2           9  10
   9        3          1          17
  10        3          2          11  17
  11        3          1          15
  12        3          2          15  16
  13        3          1          16
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     5       3    6    7    7    3    0    8
         2     6       3    6    5    5    3    6    0
         3     7       2    5    5    5    2    0    6
  3      1     4       3    4    7    8   10    7    0
         2     8       3    3    6    8    6    0    7
         3    10       2    1    5    8    6    0    3
  4      1     2       9    8    7    7    4    0    7
         2     4       9    7    5    7    4    0    6
         3    10       8    2    5    7    2    0    6
  5      1     2       9    8    5    4    6   10    0
         2     3       7    8    5    2    5    9    0
         3     9       5    7    5    2    3    8    0
  6      1     2       8    4    7    7   10    7    0
         2     6       5    3    4    6    6    2    0
         3     7       4    2    3    4    4    0    4
  7      1     2       5    4    9    3    8    0    8
         2     5       3    4    9    2    8    0    6
         3     8       2    3    8    2    8    4    0
  8      1     4       5    4    5    6    5    4    0
         2     6       3    3    5    5    3    0    4
         3     6       3    4    3    5    3    0    6
  9      1     3       6    7    7   10    8    0   10
         2     4       5    7    7    9    8    6    0
         3    10       5    6    6    9    7    5    0
 10      1     3       8    6    1    5    4    3    0
         2     9       7    4    1    5    3    2    0
         3     9       7    5    1    3    3    3    0
 11      1     5       9    7    6    8    4    0    4
         2     6       8    4    6    8    3    5    0
         3     8       8    4    4    7    3    0    3
 12      1     3       9   10    4    2    9    2    0
         2     9       8   10    4    2    9    0    6
         3     9       9    9    3    2    9    0    3
 13      1     3       2   10    9    4    8    0    4
         2     6       2    9    7    3    3    0    2
         3     9       2    9    6    1    3    0    1
 14      1     2       7    9    7    7    2    0    8
         2     4       5    9    6    7    2    5    0
         3     6       3    9    6    6    1    0    4
 15      1     4       7    9    8    9    6    9    0
         2     7       5    4    6    6    3    0    7
         3     7       4    1    5    8    3    0    7
 16      1     1       7    6    9    7    7    2    0
         2     5       6    3    8    7    6    0    4
         3     7       5    1    7    5    3    2    0
 17      1     2       2    5    8   10    5    0    9
         2     6       2    5    7    8    3    0    9
         3     8       1    4    3    8    3    6    0
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   29   33   25   24   24   60   71
************************************************************************
