************************************************************************
file with basedata            : me41_.bas
initial value random generator: 705020838
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  158
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       17        9       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  10  18
   3        3          3           5  10  17
   4        3          2          11  19
   5        3          3           6   8   9
   6        3          3          12  19  21
   7        3          3           9  11  13
   8        3          1          20
   9        3          2          14  16
  10        3          2          12  16
  11        3          2          12  17
  12        3          1          14
  13        3          2          14  15
  14        3          1          20
  15        3          2          16  17
  16        3          1          20
  17        3          1          21
  18        3          2          19  21
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     3       0    5
         2     6       6    0
         3     8       0    3
  3      1     4       0    9
         2     7       6    0
         3    10       0    5
  4      1     2       8    0
         2     2       0    6
         3     7       0    5
  5      1     2       0    9
         2     4       0    2
         3     6       4    0
  6      1     3       8    0
         2     3       0    3
         3     4       0    1
  7      1     2       0    8
         2     5       1    0
         3     8       0    4
  8      1     3       0    9
         2     6       3    0
         3     7       0    7
  9      1     2       0    6
         2     3       3    0
         3     7       0    5
 10      1     2       0    4
         2     2       8    0
         3     8       0    3
 11      1     1       7    0
         2     2       2    0
         3     6       0    8
 12      1     2       4    0
         2     3       3    0
         3    10       0   10
 13      1     4       0    5
         2     5       0    4
         3    10       0    2
 14      1     1       5    0
         2     4       2    0
         3    10       1    0
 15      1     1       0   10
         2     3       0    9
         3    10       7    0
 16      1     4       0    2
         2     6       9    0
         3     7       8    0
 17      1     6       0    4
         2     8       6    0
         3     9       0    3
 18      1     1       9    0
         2     2       6    0
         3     8       3    0
 19      1     2       8    0
         2     6       6    0
         3     8       0    8
 20      1     2       4    0
         2     8       0    1
         3    10       2    0
 21      1     1       0    6
         2     4       0    5
         3     5       1    0
 22      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
    8    9
************************************************************************
