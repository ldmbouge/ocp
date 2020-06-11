************************************************************************
file with basedata            : md315_.bas
initial value random generator: 150464065
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  150
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       24        5       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6  12
   3        3          2           8  11
   4        3          3          10  12  17
   5        3          1          13
   6        3          3           7  10  14
   7        3          2          15  19
   8        3          3           9  10  12
   9        3          2          13  15
  10        3          1          19
  11        3          3          13  16  18
  12        3          1          18
  13        3          2          17  19
  14        3          1          16
  15        3          2          16  18
  16        3          1          17
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     6       7    0    7    8
         2     7       0    6    6    6
         3     9       0    4    5    4
  3      1     3       7    0   10    7
         2     8       0    7    9    4
         3     9       0    7    8    3
  4      1     4       7    0   10   10
         2     4       0   10   10    7
         3     6       0   10   10    2
  5      1     1       5    0    2   10
         2     8       4    0    2    7
         3     8       0    5    2    8
  6      1     1       7    0    9    2
         2     3       0    5    6    2
         3     9       3    0    5    1
  7      1     2       0    6    2    6
         2     3       0    1    1    4
         3     3       6    0    1    6
  8      1     3       8    0    4    5
         2     4       5    0    3    5
         3     7       3    0    3    5
  9      1     6       0    5    8    8
         2     7       1    0    5    8
         3    10       0    4    3    8
 10      1     2       0    1    5    7
         2     5       0    1    3    5
         3    10       4    0    2    4
 11      1     2       4    0   10    8
         2     4       0    2    9    8
         3     5       2    0    9    7
 12      1     2       0    4    8    6
         2     2       8    0    7    6
         3     9       6    0    7    1
 13      1     4       8    0    9    7
         2     7       8    0    8    6
         3     9       0    2    6    6
 14      1     2       0    6    8    6
         2     3       0    2    6    5
         3     9      10    0    4    4
 15      1     7       0    3    7    7
         2     7       5    0    7    9
         3    10       0    3    7    5
 16      1     1       5    0    8    4
         2     2       5    0    7    4
         3     9       0    4    5    2
 17      1     2       6    0    9    8
         2     7       6    0    5    7
         3     8       3    0    3    3
 18      1     1       0    4    6    5
         2     2       1    0    3    5
         3    10       0    2    1    4
 19      1     8       0    7    4    9
         2     8       8    0    5    7
         3    10       0    7    3    5
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   23   22  127  125
************************************************************************
