************************************************************************
file with basedata            : md225_.bas
initial value random generator: 27199
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  135
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       28       11       28
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          13  17
   3        3          3           5   8  10
   4        3          3           7   8   9
   5        3          3           6  11  16
   6        3          2           7   9
   7        3          2          14  15
   8        3          2          16  17
   9        3          2          12  15
  10        3          3          11  12  13
  11        3          1          14
  12        3          1          14
  13        3          2          15  16
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       7    0    3    5
         2     5       0    5    3    5
         3     8       0    4    2    4
  3      1     4       7    0    9    7
         2     5       4    0    7    7
         3     7       4    0    3    6
  4      1     4       5    0    7    7
         2     4       0    6    8    8
         3     6       4    0    4    7
  5      1     1       6    0    5    5
         2     3       0    3    4    4
         3     6       3    0    3    2
  6      1     9       7    0    7    3
         2    10       0    8    4    2
         3    10       0    6    5    2
  7      1     7       0    4    7    3
         2     8       0    2    6    3
         3    10       4    0    5    3
  8      1     1       0    8    8   10
         2     5       0    7    7    5
         3    10       0    7    7    3
  9      1     2       8    0    9    5
         2     7       2    0    7    4
         3     7       0    2    6    5
 10      1     3       0    3    9    5
         2     4       0    2    5    4
         3     9       4    0    4    1
 11      1     6       7    0    7    4
         2     7       0   10    5    4
         3    10       0   10    1    4
 12      1     2       6    0   10    6
         2     5       4    0    7    4
         3    10       0    1    1    3
 13      1     2       0    3    8    6
         2     3      10    0    6    4
         3     9       6    0    6    2
 14      1     4       0    6   10    7
         2     8       9    0    9    4
         3     9       2    0    7    1
 15      1     3       0    4    7    8
         2     6       0    1    5    5
         3     7      10    0    3    5
 16      1     4       7    0    5    6
         2     7       0    7    4    3
         3     7       7    0    2    2
 17      1     3       0    9   10    6
         2     9       0    6    9    4
         3    10       5    0    9    2
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   10   12   81   62
************************************************************************
