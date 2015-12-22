************************************************************************
file with basedata            : c2116_.bas
initial value random generator: 497677802
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  140
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       24       14       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   9  10
   3        3          3           5   7  10
   4        3          3           6   7  11
   5        3          3           6   8   9
   6        3          3          12  13  14
   7        3          2           8  12
   8        3          3          13  14  16
   9        3          2          12  15
  10        3          3          11  14  16
  11        3          2          13  15
  12        3          2          16  17
  13        3          1          17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       5    3    6    0
         2     2       5    3    0    7
         3    10       3    2    6    0
  3      1     4       7    3    7    0
         2    10       5    2    0    5
         3    10       4    1    0    8
  4      1     3       5    8    4    0
         2     4       5    8    0    9
         3    10       4    8    4    0
  5      1     2       5    4    4    0
         2     9       3    4    3    0
         3    10       3    3    3    0
  6      1     2       6    7    2    0
         2     6       6    6    0    8
         3     9       3    6    1    0
  7      1     6       4    5   10    0
         2     9       4    5    0    1
         3     9       4    4    0    2
  8      1     1       3    7    4    0
         2     1       3    7    0    6
         3     9       3    6    0    2
  9      1     1      10   10    0    7
         2     3       9    7    0    6
         3    10       9    6    0    6
 10      1     6       8    4    7    0
         2     7       7    3    4    0
         3     8       6    3    0    7
 11      1     1       6    8    0    3
         2     3       4    8    6    0
         3     5       4    7    0    3
 12      1     2       4    3    0    7
         2     2       3    4    0    9
         3     9       2    3    8    0
 13      1     1       7    7    0    8
         2     6       7    5    0    7
         3     8       6    4    0    5
 14      1     6       5    7    5    0
         2     7       3    5    0    7
         3     9       3    3    4    0
 15      1     4       7    9    0    6
         2     5       5    7    0    5
         3     6       3    7    0    5
 16      1     7       5    4    9    0
         2     9       4    4    9    0
         3    10       4    2    6    0
 17      1     7       5    7    0    4
         2     7       7    6    0    3
         3     8       2    5    0    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   28   26   41   55
************************************************************************
