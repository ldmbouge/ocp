************************************************************************
file with basedata            : me43_.bas
initial value random generator: 565225141
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  155
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       21       15       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   9  11
   3        3          2           5   8
   4        3          2           5   9
   5        3          3           6  15  16
   6        3          1          19
   7        3          2           8  10
   8        3          2          12  17
   9        3          3          13  14  17
  10        3          3          13  16  17
  11        3          2          20  21
  12        3          3          14  18  20
  13        3          1          20
  14        3          2          15  19
  15        3          1          21
  16        3          1          18
  17        3          1          18
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
  2      1     4       0    9
         2     8       4    0
         3     9       1    0
  3      1     1       4    0
         2     2       0    4
         3    10       0    3
  4      1     3       8    0
         2     4       6    0
         3     5       0    2
  5      1     2       3    0
         2     2       0    8
         3     8       0    3
  6      1     7       7    0
         2    10       0    4
         3    10       3    0
  7      1     2       0    7
         2     7       7    0
         3     7       0    5
  8      1     4       0    6
         2     5       0    5
         3     5       3    0
  9      1     6       6    0
         2     8       0    3
         3     8       5    0
 10      1     1       0    4
         2     7       0    3
         3    10      10    0
 11      1     1       0    3
         2     3       5    0
         3     5       4    0
 12      1     3       0    3
         2     5       5    0
         3     5       0    2
 13      1     3       8    0
         2     6       0   10
         3     9       0    7
 14      1     2       0    5
         2     5       0    3
         3     9       9    0
 15      1     4       0    8
         2     6       7    0
         3     7       0    3
 16      1     2       5    0
         2     5       0    9
         3     9       0    4
 17      1     4       8    0
         2     5       0    2
         3     9       0    1
 18      1     5       0    4
         2     7       6    0
         3     8       5    0
 19      1     1       6    0
         2     8       5    0
         3     9       0    4
 20      1     1       0    4
         2     3       3    0
         3     6       2    0
 21      1     2       6    0
         2     5       0    6
         3     7       3    0
 22      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   23   18
************************************************************************
