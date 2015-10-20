************************************************************************
file with basedata            : c2143_.bas
initial value random generator: 1559908653
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  127
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19        5       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          10  11  13
   3        3          3           6   7   9
   4        3          3           5   9  13
   5        3          3           8  12  14
   6        3          2           8  12
   7        3          3           8  10  13
   8        3          3          11  15  17
   9        3          3          10  11  14
  10        3          2          12  16
  11        3          1          16
  12        3          2          15  17
  13        3          2          14  17
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       7    0    9    8
         2     3       0    9    9    8
         3     5       4    0    8    8
  3      1     3       0    9    6   10
         2     4       0    5    6    8
         3     8       0    4    6    4
  4      1     1       0    7    6    6
         2     3       0    6    5    5
         3     7       3    0    5    5
  5      1     1       6    0    6    4
         2     7       0    3    4    3
         3     7       0    4    4    1
  6      1     2       0    7    4    5
         2     4       0    7    2    3
         3     7       0    6    1    1
  7      1     4       4    0    6    4
         2     7       4    0    5    4
         3     7       0    2    4    4
  8      1     5       0    6    7    4
         2     7       9    0    6    3
         3     9       7    0    6    3
  9      1     3       5    0    3    7
         2     3       4    0    4    7
         3     6       3    0    3    7
 10      1     3       7    0    8    7
         2     5       7    0    6    6
         3     8       0    5    5    2
 11      1     4       0    7    6    6
         2     8       0    6    6    2
         3     8       0    7    5    1
 12      1     3       0    4    7    3
         2    10       2    0    6    1
         3    10       4    0    4    1
 13      1     1       4    0   10    8
         2     6       0    7    8    6
         3    10       4    0    6    4
 14      1     6       7    0    9    2
         2     8       6    0    7    2
         3     9       0    5    7    2
 15      1     2       0    3    5    3
         2     7       5    0    3    3
         3     7       0    1    3    3
 16      1     3       5    0    8   10
         2     6       5    0    6    5
         3    10       5    0    5    5
 17      1     6       5    0    6    6
         2     6       0    6    6    6
         3     9       0    5    6    6
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   20   93   75
************************************************************************
