************************************************************************
file with basedata            : md333_.bas
initial value random generator: 1992485151
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  160
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       35        9       35
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          10  15
   3        3          3           6  10  20
   4        3          2           5   7
   5        3          3           9  13  20
   6        3          2          12  16
   7        3          2           8  12
   8        3          3          11  14  19
   9        3          2          10  16
  10        3          3          12  14  17
  11        3          2          20  21
  12        3          1          18
  13        3          3          14  15  16
  14        3          1          21
  15        3          1          17
  16        3          2          18  21
  17        3          1          19
  18        3          1          19
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     8       7    9    0    5
         2     9       6    7    6    0
         3    10       5    5    6    0
  3      1     2       8    6    8    0
         2     6       5    5    0    4
         3     9       4    4    5    0
  4      1     8       7    8    0    9
         2     8       9    7    0   10
         3     9       5    6    0    7
  5      1     5       4    5    0    5
         2     8       4    5    0    4
         3     9       2    4    7    0
  6      1     7       2    6    4    0
         2     7       2    6    0    7
         3    10       2    5    4    0
  7      1     4       8   10    0    6
         2     4       8    9    5    0
         3     5       7    8    4    0
  8      1     2       4    3    4    0
         2     8       2    1    3    0
         3     8       3    2    0    3
  9      1     4       8   10    0    9
         2     5       6    6    3    0
         3     7       2    3    0    7
 10      1     3       8    7    0    7
         2     4       7    7    0    6
         3     6       6    7   10    0
 11      1     5       8    8    4    0
         2     7       8    7    4    0
         3     8       7    7    0    2
 12      1     4       8    6    0    6
         2     5       5    5    0    4
         3     7       4    2    7    0
 13      1     3       7    7    0    4
         2     4       7    6    0    1
         3    10       6    2    5    0
 14      1     4       4    6    0    2
         2     4       6    5    0    3
         3     7       2    4    1    0
 15      1     2       6    5    7    0
         2     3       6    4    5    0
         3     4       5    4    0    5
 16      1     6       5    7    7    0
         2     8       5    5    0    6
         3    10       4    3    5    0
 17      1     3       9    7    4    0
         2     7       5    5    0    2
         3     8       3    4    4    0
 18      1     7       6    5    7    0
         2     9       2    3    0    6
         3     9       5    4    7    0
 19      1     4       7    5    0    6
         2     7       5    4    6    0
         3     9       3    3    0    6
 20      1     4       8    2    7    0
         2     5       6    2    0    8
         3     7       5    1    0    4
 21      1     1       2    7    0   10
         2     5       2    7    0    5
         3     8       2    7    0    4
 22      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   14   13   51   63
************************************************************************
