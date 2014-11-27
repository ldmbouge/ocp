************************************************************************
file with basedata            : md302_.bas
initial value random generator: 624511834
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  128
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       24        9       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1          13
   3        3          3           5   7  18
   4        3          3           6  13  15
   5        3          2          10  11
   6        3          3           8   9  17
   7        3          2          10  12
   8        3          1          11
   9        3          3          10  14  16
  10        3          1          19
  11        3          2          12  14
  12        3          1          16
  13        3          3          14  17  18
  14        3          1          19
  15        3          3          16  17  18
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
  2      1     3      10   10    8    4
         2     4       5   10    3    3
         3     7       3    9    1    3
  3      1     2       7    8    6    4
         2     2       7    6    5    7
         3     3       6    5    3    3
  4      1     3       6    7    2    8
         2     4       5    7    2    8
         3     8       5    5    1    3
  5      1     2       3    6    7    7
         2     4       2    6    7    6
         3     6       1    6    6    5
  6      1     3       7    4    4    9
         2     7       6    3    4    5
         3     8       6    2    2    3
  7      1     2       5    2    9    5
         2     3       4    2    8    4
         3     5       3    1    7    2
  8      1     5       7    5    7    8
         2     6       7    5    5    6
         3     7       6    5    3    5
  9      1     3       8    8    8    8
         2     6       8    7    6    7
         3     9       7    7    3    7
 10      1     3       3    6    7    7
         2     3       5    6    8    5
         3     6       1    6    2    5
 11      1     1       3   10    9    5
         2     1       4    9    9    5
         3     2       2    7    8    5
 12      1     4       6    8    8    7
         2     5       5    5    3    6
         3     5       4    5    6    3
 13      1     1       2    2    6   10
         2     7       2    2    5    5
         3     8       1    2    4    4
 14      1     2       2    3    8    5
         2     2       2    2    7    6
         3     9       2    2    1    2
 15      1     3       9   10    8    4
         2     3      10   10    7    5
         3     9       8   10    7    4
 16      1     2       2    6    6    8
         2     5       2    6    6    7
         3     9       2    6    5    5
 17      1     3       2    8    7    9
         2     6       2    7    6    6
         3    10       1    3    6    2
 18      1     3       5    4    6    8
         2     4       4    3    4    6
         3     7       4    3    2    3
 19      1     6       8    5    8    8
         2     8       6    3    7    8
         3    10       4    2    7    7
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   18   18   98  100
************************************************************************
