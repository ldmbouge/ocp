************************************************************************
file with basedata            : md346_.bas
initial value random generator: 165472618
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  162
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       23       16       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   8  15
   3        3          3           6  10  15
   4        3          2           5   7
   5        3          3          12  13  17
   6        3          2           7  12
   7        3          1          17
   8        3          3           9  12  16
   9        3          1          10
  10        3          1          11
  11        3          2          14  20
  12        3          2          14  18
  13        3          3          15  19  20
  14        3          2          19  21
  15        3          1          18
  16        3          2          17  20
  17        3          2          18  19
  18        3          1          21
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     6       3    0    7    0
         2     7       1    0    0   10
         3    10       0    9    4    0
  3      1     3       6    0    6    0
         2     7       5    0    5    0
         3    10       5    0    4    0
  4      1     1       6    0    0    9
         2     7       5    0    8    0
         3     8       0    6    8    0
  5      1     1       0    5    7    0
         2     2       0    4    0    1
         3     7       0    2    6    0
  6      1     4       6    0    4    0
         2     7       1    0    0    5
         3     7       1    0    3    0
  7      1     4       0    7    2    0
         2     7       5    0    0    6
         3     7       0    6    2    0
  8      1     1       0    6    0    8
         2     4       0    3    0    6
         3    10       6    0    0    6
  9      1     1       0    9    0    8
         2     4       5    0    0    6
         3     8       0    7    8    0
 10      1     2       8    0    0    3
         2     2       7    0    4    0
         3     4       4    0    0    3
 11      1     3      10    0    0    8
         2     4       4    0    3    0
         3     4       0    7    5    0
 12      1     2       7    0    0    8
         2     8       6    0    0    7
         3     9       6    0    0    2
 13      1     1       0    8    6    0
         2     6       2    0    6    0
         3     9       0    8    4    0
 14      1     1       5    0    0    7
         2     4       2    0    0    2
         3     9       0    4    6    0
 15      1     3       8    0    4    0
         2     6       6    0    0    9
         3     9       0    3    0    8
 16      1     1       0    1    6    0
         2     3       8    0    4    0
         3     4       0    1    0    4
 17      1     6       0    8    0    8
         2     7       0    7    0    7
         3     7       4    0    3    0
 18      1     5       0    8    9    0
         2     9       3    0    5    0
         3    10       2    0    4    0
 19      1     5       0   10    0    6
         2     6       5    0    7    0
         3    10       4    0    6    0
 20      1     8       4    0    5    0
         2     9       4    0    0    4
         3    10       4    0    3    0
 21      1     1       7    0    0    9
         2     6       5    0    0    9
         3    10       2    0    2    0
 22      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   11   99  113
************************************************************************
