************************************************************************
file with basedata            : cm230_.bas
initial value random generator: 12626787
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  91
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        7       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          3           5   7  15
   3        2          3           5  10  12
   4        2          2           6  10
   5        2          2           9  16
   6        2          3          14  15  17
   7        2          3           8  10  11
   8        2          2           9  13
   9        2          1          17
  10        2          2          13  14
  11        2          1          12
  12        2          2          13  14
  13        2          2          16  17
  14        2          1          16
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       6    7    0    5
         2     2       5    5    0    4
  3      1     1       3   10    8    0
         2     9       1    6    0    6
  4      1     7       6    5    5    0
         2     7       3    1    0    7
  5      1     4       7    8    0    9
         2     4       3    5    5    0
  6      1     5       3    8    5    0
         2     7       3    7    4    0
  7      1     5       8    7    7    0
         2     7       2    5    7    0
  8      1     1       4    5    7    0
         2     5       2    3    7    0
  9      1     3       2   10    0    2
         2     3       4    3    0    3
 10      1     1       5    6    0    5
         2     3       3    6    4    0
 11      1     2       6    7    0    7
         2     7       4    1    6    0
 12      1     1       1   10    6    0
         2    10       1    4    0    1
 13      1     2       4    7    0    9
         2     4       3    7    0    7
 14      1     3       5    8    0    7
         2     7       5    6    0    5
 15      1     1       5   10    3    0
         2     5       3    3    2    0
 16      1     3       9   10    7    0
         2     9       6   10    5    0
 17      1     2       7    1    0    9
         2     2       7    1    5    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   14   21   68   68
************************************************************************
