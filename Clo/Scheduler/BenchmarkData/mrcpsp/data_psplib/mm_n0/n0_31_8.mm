************************************************************************
file with basedata            : me31_.bas
initial value random generator: 971551697
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21        0       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5  15
   3        3          3           5   7  15
   4        3          3           6   8  10
   5        3          2          16  17
   6        3          3          12  14  17
   7        3          2           9  14
   8        3          3           9  11  12
   9        3          1          17
  10        3          2          11  12
  11        3          2          13  14
  12        3          1          13
  13        3          2          15  16
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     3       7    7
         2     8       7    5
         3     9       6    4
  3      1     2       5    5
         2     7       4    5
         3     8       1    4
  4      1     1      10    7
         2     8       7    6
         3     9       5    6
  5      1     2       7    6
         2     3       7    3
         3    10       4    1
  6      1     1       7    3
         2     5       4    2
         3     5       6    1
  7      1     1       5    7
         2     6       5    6
         3    10       5    5
  8      1     4       9    5
         2     9       4    4
         3    10       3    3
  9      1     3      10    5
         2     3       8    7
         3     5       6    2
 10      1     6       5    9
         2     6       6    8
         3    10       2    7
 11      1    10       4    7
         2    10       5    3
         3    10       3    8
 12      1     2       8    6
         2     8       7    5
         3    10       7    4
 13      1     1       9    9
         2     3       8    7
         3     6       8    6
 14      1     1       7    3
         2     2       6    2
         3     6       4    2
 15      1     1       2    7
         2     3       2    5
         3     6       2    2
 16      1     3       9    6
         2     4       5    4
         3     6       3    3
 17      1     2       6    9
         2     5       4    8
         3    10       3    4
 18      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   28   24
************************************************************************
