************************************************************************
file with basedata            : md265_.bas
initial value random generator: 405321368
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  147
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       23       15       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           8  10  15
   3        3          3           5   7   9
   4        3          3           6   8  15
   5        3          3          10  11  14
   6        3          2          17  18
   7        3          3          14  16  18
   8        3          1          12
   9        3          1          15
  10        3          2          13  16
  11        3          2          16  17
  12        3          2          13  14
  13        3          2          18  19
  14        3          1          17
  15        3          1          19
  16        3          1          19
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       5    0    0    1
         2     5       0    6    4    0
         3     8       4    0    1    0
  3      1     2      10    0    4    0
         2     5       0    6    3    0
         3     9       0    6    0    6
  4      1     4       5    0    0    3
         2     5       4    0    7    0
         3    10       0    2    0    2
  5      1     2       4    0    7    0
         2     3       0    5    6    0
         3     3       0    5    0    3
  6      1     7       3    0    7    0
         2     9       2    0    6    0
         3    10       2    0    0    5
  7      1     4       0    8    0    4
         2     5       0    7    0    4
         3    10       0    5    7    0
  8      1     2       8    0    8    0
         2     5       5    0    8    0
         3     7       0    1    7    0
  9      1     6      10    0    0    8
         2     8       9    0    0    6
         3    10       6    0    0    3
 10      1     1       0    5    0    7
         2     2       7    0   10    0
         3     9       0    4    7    0
 11      1     6       8    0    3    0
         2     7       0    3    2    0
         3    10       6    0    0    1
 12      1     7       0    5    4    0
         2     8       5    0    3    0
         3    10       0    5    3    0
 13      1     6       3    0    4    0
         2     6       0    7    3    0
         3     8       3    0    0    3
 14      1     1       0    9    0    9
         2     3       0    5    0    6
         3     3       4    0    6    0
 15      1     1       7    0    0   10
         2     9       0    7    0    8
         3    10       7    0    0    7
 16      1     2       0    6    0    8
         2     6       0    3    0    5
         3     8       4    0    0    2
 17      1     1       4    0    8    0
         2     1       0    6    9    0
         3     4       0    4    0    1
 18      1     4       5    0    8    0
         2     7       0   10    6    0
         3    10       0    6    0    6
 19      1     2       0    5    0    2
         2     2       0    4    2    0
         3     8       8    0    0    2
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   14    8   50   45
************************************************************************
