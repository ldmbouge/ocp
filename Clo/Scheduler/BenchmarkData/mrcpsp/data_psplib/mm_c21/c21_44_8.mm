************************************************************************
file with basedata            : c2144_.bas
initial value random generator: 1292974007
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  141
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17        2       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           9  10  11
   3        3          3           5   7   9
   4        3          3           6   9  13
   5        3          2           6  11
   6        3          3           8  10  14
   7        3          3           8  10  13
   8        3          3          12  15  16
   9        3          2          14  17
  10        3          3          12  15  16
  11        3          2          12  13
  12        3          1          17
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
  2      1     2       5    0    9    4
         2     8       0    1    7    4
         3    10       4    0    5    3
  3      1     3       7    0   10    2
         2     3       0    9    9    2
         3     9       7    0    8    2
  4      1     5       0    9    6    5
         2     5       9    0    6    7
         3     7       7    0    6    1
  5      1     3       6    0    9    6
         2     7       6    0    7    4
         3     8       0    6    4    4
  6      1     1       8    0    4    8
         2     9       4    0    2    8
         3    10       0    7    1    7
  7      1     4       0    3    8    5
         2     6       0    2    7    5
         3    10       1    0    1    4
  8      1     5       7    0    9    5
         2     5       0    3    8    5
         3     9       8    0    8    2
  9      1     2       3    0    4   10
         2     6       0    5    3   10
         3    10       3    0    3    9
 10      1     1       0    6    7    9
         2     7       8    0    6    7
         3     8       5    0    6    5
 11      1     3       0    4    5    6
         2     4       8    0    4    6
         3     7       6    0    4    4
 12      1     1       6    0    7    5
         2     5       4    0    5    4
         3     9       1    0    2    4
 13      1     3       0    8    9    5
         2     5       0    6    8    5
         3     9       5    0    8    2
 14      1     2      10    0    3    5
         2     2       0    4    3    5
         3     8       9    0    3    4
 15      1     3       6    0    3    5
         2     8       3    0    3    3
         3     9       2    0    2    3
 16      1     1       3    0    8   10
         2     3       3    0    8    9
         3     8       2    0    7    9
 17      1     3       5    0    4    9
         2     7       5    0    3    8
         3    10       5    0    3    7
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   21   19   88   86
************************************************************************
