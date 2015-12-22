************************************************************************
file with basedata            : cn337_.bas
initial value random generator: 1317463422
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       13        7       13
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7   9
   3        3          3          12  15  16
   4        3          3           5   6  13
   5        3          2          12  14
   6        3          2           8  10
   7        3          3           8  11  17
   8        3          2          14  16
   9        3          2          10  11
  10        3          1          12
  11        3          2          13  14
  12        3          1          17
  13        3          2          15  16
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
  2      1     3       6    8    5    2    2
         2     4       6    8    5    2    1
         3    10       5    7    5    2    1
  3      1     1       9    6    4    8    7
         2     5       9    6    4    7    6
         3    10       9    4    2    3    6
  4      1     3       6    9    7    9    7
         2     4       5    6    7    7    4
         3     8       5    2    6    5    3
  5      1     6       6    9    3    7    7
         2     8       6    9    3    6    7
         3    10       5    8    2    6    5
  6      1     2       5    2    6    9    8
         2     3       4    2    5    8    6
         3     5       3    1    2    7    4
  7      1     1       9    9    9    3    6
         2     3       8    7    6    2    6
         3     8       8    6    4    2    5
  8      1     2       8    6    5    5    2
         2     7       1    5    4    5    1
         3     7       1    6    3    5    2
  9      1     3       4    7    4    4    9
         2     6       3    5    4    4    8
         3     8       2    3    2    3    7
 10      1     4       8    4    6    6    2
         2     4       9    3    6    8    2
         3     6       7    2    6    2    1
 11      1     1       9    9   10    9    7
         2     4       7    7    9    9    7
         3    10       6    7    9    8    7
 12      1     1       6    7    3    9    7
         2     1       6    9    5   10    6
         3     9       6    7    1    9    3
 13      1     1      10    5    7    5    4
         2     6       9    4    7    3    3
         3    10       8    4    6    2    2
 14      1     1       5    7    4    8    7
         2     1       5    8    4    8    5
         3     3       5    3    3    8    2
 15      1     3       8   10    4    8    8
         2     4       5    6    3    7    8
         3     8       5    4    2    5    8
 16      1     2      10    7   10    9    3
         2     4       6    6   10    8    2
         3     8       5    3   10    5    1
 17      1     1       9    7    8    7    6
         2     2       8    7    8    6    6
         3    10       8    5    7    1    5
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   15   13   77   83   69
************************************************************************
