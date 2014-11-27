************************************************************************
file with basedata            : md357_.bas
initial value random generator: 18062
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  157
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       28       14       28
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   9  13
   3        3          3           6   9  12
   4        3          1           8
   5        3          1           6
   6        3          2           7   8
   7        3          3          10  14  15
   8        3          2          11  16
   9        3          2          10  17
  10        3          2          11  16
  11        3          2          18  21
  12        3          2          13  17
  13        3          1          19
  14        3          3          16  17  18
  15        3          3          19  20  21
  16        3          1          20
  17        3          2          19  21
  18        3          1          20
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       8    7    9    4
         2     5       6    9    7    5
         3     7       5    4    2    3
  3      1     5       6    4    7   10
         2     7       6    3    5   10
         3     9       6    2    3   10
  4      1     1       6    5    9    7
         2     4       6    4    9    6
         3     5       4    4    8    4
  5      1     4       8    3    4    8
         2     5       7    3    3    6
         3     7       5    3    2    2
  6      1     4       7    7    5    9
         2     5       6    7    4    9
         3     6       1    6    4    8
  7      1     1       7    9    3    6
         2     8       5    7    2    5
         3    10       5    6    1    3
  8      1     4       8    7    9    7
         2     5       8    7    8    7
         3     9       8    7    8    3
  9      1     3       7    5    5    7
         2     6       4    5    5    7
         3     8       4    3    3    5
 10      1     1       7    2    8    6
         2     8       4    2    8    5
         3     9       2    1    7    4
 11      1     2       7    4    6    6
         2     8       5    3    4    4
         3     9       2    1    3    4
 12      1     5       7    8    7    3
         2     6       6    6    7    3
         3     7       6    6    4    2
 13      1     4       8    7    6    3
         2     7       8    6    6    3
         3     8       6    6    6    2
 14      1     5       7    6    2    4
         2     5       8    6    1    6
         3     5       8    7    1    4
 15      1     7       7    3    9    8
         2     9       7    3    8    7
         3    10       6    2    8    6
 16      1     3       9    5    7    7
         2     4       9    5    4    4
         3     8       8    4    4    2
 17      1     1       9    9    8    7
         2     6       8    8    6    6
         3     9       7    7    4    6
 18      1     4       2   10    2   10
         2     4       3    9    2    9
         3     7       2    9    2    7
 19      1     7       2    4    6   10
         2     9       2    4    6    6
         3    10       1    3    2    4
 20      1     1       1    7    7    4
         2     4       1    7    4    3
         3     5       1    6    2    2
 21      1     3      10    4    6    6
         2     9       9    3    5    4
         3     9      10    2    6    5
 22      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   14   14   91   98
************************************************************************
