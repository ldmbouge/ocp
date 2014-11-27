************************************************************************
file with basedata            : cr356_.bas
initial value random generator: 1521970343
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21        6       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   9  12
   3        3          2           5  16
   4        3          3           6   7  12
   5        3          1           8
   6        3          3          11  13  14
   7        3          3          11  13  14
   8        3          1          10
   9        3          2          11  17
  10        3          2          14  15
  11        3          2          15  16
  12        3          3          13  15  17
  13        3          1          16
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     5       8    8    8    6    9
         2     8       8    7    6    6    8
         3    10       8    6    4    5    8
  3      1     9       7    6    9    7    6
         2    10       6    5    7    5    4
         3    10       5    6    7    5    3
  4      1     2       5    2   10    9    9
         2     3       5    2   10    8    8
         3    10       3    2   10    7    7
  5      1     2       9    7    9   10    7
         2     6       8    6    9   10    7
         3     8       8    1    8    9    7
  6      1     1       8    4    6    7    7
         2     4       4    4    4    6    4
         3     6       4    2    4    3    2
  7      1     4       9    9    7    8    6
         2     6       8    6    6    8    5
         3     9       8    5    5    7    2
  8      1     3      10    7    9    8    7
         2     8       8    7    7    6    6
         3     9       6    6    1    5    3
  9      1     2       5    9    8    6   10
         2     8       3    9    6    6   10
         3     8       3    9    7    6    9
 10      1     2       3    3    9    3   10
         2     5       3    2    8    3    8
         3    10       3    2    7    2    6
 11      1     3       1    7    9   10    7
         2     6       1    6    9    7    6
         3     7       1    6    9    5    5
 12      1     7       8    8    9    9    3
         2     8       8    7    8    8    3
         3    10       8    5    7    4    2
 13      1     1       9    7    8   10    9
         2     3       7    4    8    9    7
         3     4       5    3    8    9    6
 14      1     3       9    8    6    7    9
         2     4       7    8    5    7    9
         3    10       5    7    2    7    8
 15      1     2       3    5    8    6    9
         2     3       3    4    7    5    6
         3     4       3    4    4    4    5
 16      1     7       8    9    3    7    6
         2     7       6   10    4    5    8
         3     9       3    9    3    3    6
 17      1     2       8    5    8    3    8
         2     3       8    5    7    2    6
         3     6       8    5    6    2    5
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   37   36   39  108  114
************************************************************************
