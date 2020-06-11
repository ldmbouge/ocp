************************************************************************
file with basedata            : cm253_.bas
initial value random generator: 1985301536
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  104
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       25       12       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          2           7   8
   3        2          3           6   8  12
   4        2          2           5  17
   5        2          3           7   8  11
   6        2          3          10  14  17
   7        2          3           9  13  14
   8        2          3           9  13  14
   9        2          1          10
  10        2          1          16
  11        2          2          15  16
  12        2          2          13  16
  13        2          1          15
  14        2          1          15
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       5    5    6    8
         2    10       4    4    5    1
  3      1     3       6    9    8    7
         2     5       4    3    4    7
  4      1     2       6    1    5    9
         2     2       8    1    6    8
  5      1     1       6    6    3    4
         2    10       5    5    3    4
  6      1     4       3    8    1    7
         2     9       3    6    1    7
  7      1     2       4    3   10    7
         2     8       4    3    9    3
  8      1     6       9    1    7    4
         2     9       9    1    6    3
  9      1     2      10    5    5    3
         2     2      10    4    7    3
 10      1     5       3    8    3    6
         2    10       3    4    1    3
 11      1     1      10    5    4    9
         2     4       8    4    4    8
 12      1     7      10   10    5    8
         2     8       8    9    4    7
 13      1     1       8    8    7    5
         2     5       4    3    7    3
 14      1     2       7    7    5    8
         2     4       6    6    5    8
 15      1     1       2    9   10    4
         2     3       2    8   10    1
 16      1     9       6    9    6    7
         2    10       1    8    5    1
 17      1     4       7    5    6    9
         2     5       6    4    2    8
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   14   90   98
************************************************************************
