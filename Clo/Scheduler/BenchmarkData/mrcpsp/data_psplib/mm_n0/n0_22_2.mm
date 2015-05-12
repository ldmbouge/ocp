************************************************************************
file with basedata            : me22_.bas
initial value random generator: 142723992
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  123
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       30       13       30
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           7
   3        3          3           5   6   9
   4        3          3           5   6   7
   5        3          3          10  11  14
   6        3          1          11
   7        3          2           8  12
   8        3          2           9  11
   9        3          3          13  14  15
  10        3          2          12  15
  11        3          2          13  15
  12        3          1          13
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     5       8    7
         2     5       6    8
         3     8       3    6
  3      1     2       5    6
         2     5       5    5
         3     7       3    4
  4      1     2       9    7
         2     4       8    5
         3     9       8    4
  5      1     2      10   10
         2     9      10    9
         3    10       9    9
  6      1     6       9   10
         2     7       7    9
         3     9       7    7
  7      1     8       8    4
         2     8       9    3
         3     9       5    3
  8      1     9       3    8
         2    10       3    4
         3    10       2    5
  9      1     1       8    9
         2     2       6    7
         3    10       2    4
 10      1     2       6   10
         2     6       5    7
         3    10       2    5
 11      1     2       7    8
         2     4       6    5
         3     9       6    4
 12      1     2       5    3
         2     2       4    4
         3    10       3    3
 13      1     4       7    6
         2     7       7    4
         3     7       6    5
 14      1     1       8    9
         2     4       4    8
         3     7       4    6
 15      1     6       9    3
         2     7       8    2
         3     8       7    2
 16      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   18   19
************************************************************************
