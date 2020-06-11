************************************************************************
file with basedata            : me44_.bas
initial value random generator: 26448390
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  169
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       24        4       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  10  18
   3        3          3           6   8   9
   4        3          2           5  17
   5        3          1          12
   6        3          2          15  16
   7        3          2          11  19
   8        3          2          14  18
   9        3          3          11  13  14
  10        3          2          14  17
  11        3          1          17
  12        3          2          13  15
  13        3          2          16  20
  14        3          3          15  20  21
  15        3          1          19
  16        3          2          18  19
  17        3          2          20  21
  18        3          1          21
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     3       6    0
         2     3       0    3
         3     8       0    2
  3      1     6       8    0
         2     7       0    9
         3     8       0    8
  4      1     3       6    0
         2     7       0    9
         3     7       4    0
  5      1     6       0    6
         2     6       7    0
         3     9       1    0
  6      1     3       0   10
         2     9       7    0
         3    10       0    6
  7      1     3       8    0
         2     4       4    0
         3     8       0    9
  8      1     1       7    0
         2     2       0    5
         3    10       5    0
  9      1     6       2    0
         2     6       0    6
         3     9       0    3
 10      1     2       5    0
         2     7       3    0
         3     8       0    5
 11      1     4       6    0
         2     6       0    6
         3    10       0    4
 12      1     1       5    0
         2     2       0   10
         3     6       3    0
 13      1     1       8    0
         2     4       0    9
         3    10       5    0
 14      1     4      10    0
         2     5       0    8
         3     6       0    1
 15      1     3       0    8
         2     9       5    0
         3    10       0    7
 16      1     1       0    8
         2     4       7    0
         3     7       6    0
 17      1     4       0   10
         2     6       1    0
         3    10       0    8
 18      1     1       0   10
         2     4       0    8
         3     6       6    0
 19      1     4       7    0
         2     8       0    9
         3     9       0    8
 20      1     3       6    0
         2     4       0    7
         3     9       0    5
 21      1     4       0    7
         2     8       3    0
         3     9       0    5
 22      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   31   41
************************************************************************
