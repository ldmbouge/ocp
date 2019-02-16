************************************************************************
file with basedata            : md252_.bas
initial value random generator: 1698641352
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20        1       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7   8
   3        3          2          11  14
   4        3          3           5  13  14
   5        3          2           9  12
   6        3          3          13  14  16
   7        3          3           9  13  16
   8        3          3           9  10  12
   9        3          1          15
  10        3          2          11  15
  11        3          2          16  17
  12        3          1          17
  13        3          1          17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       7    0    9    9
         2     5       0    9    6    3
         3     5       3    0    4    7
  3      1     6       0    5    9    8
         2     6       6    0    9    8
         3    10       6    0    8    8
  4      1     2       0    5    9    2
         2     5       3    0    6    2
         3     6       0    5    3    2
  5      1     1       0    2    8    9
         2     7       0    2    6    7
         3     8       7    0    4    2
  6      1     2       0    6    8    4
         2     4       8    0    7    3
         3    10       0    6    7    1
  7      1     3       0    7    8   10
         2     4       0    6    6    7
         3    10       0    4    5    2
  8      1     7       0    8    5    9
         2     8       0    7    4    9
         3    10       0    6    2    9
  9      1     3       4    0    7    7
         2     6       3    0    5    5
         3     7       3    0    2    3
 10      1     6       7    0    9    8
         2     6       8    0    9    5
         3     7       0    3    7    2
 11      1     1       6    0    5    9
         2     5       4    0    5    7
         3     7       0    9    3    6
 12      1     1       3    0    2    9
         2     2       3    0    1    8
         3     7       0    6    1    7
 13      1     3       3    0    6    6
         2     5       0    9    5    3
         3     9       0    2    5    1
 14      1     1       6    0    9    7
         2     3       0    7    8    7
         3     3       4    0    9    7
 15      1     1       0    5    7    2
         2     3       0    4    7    2
         3     9       0    3    6    2
 16      1     1       9    0    8    8
         2     1       6    0    9    8
         3     6       2    0    5    4
 17      1     3       7    0    7    7
         2     9       7    0    6    6
         3    10       0    8    5    4
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   21   26  117  114
************************************************************************
