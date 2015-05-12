************************************************************************
file with basedata            : md339_.bas
initial value random generator: 1252545263
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  166
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       31        0       31
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           6  16
   3        3          3           7   9  13
   4        3          3           5   8  10
   5        3          2           7  21
   6        3          1          14
   7        3          1          14
   8        3          2           9  11
   9        3          3          12  17  18
  10        3          3          12  15  19
  11        3          3          12  14  15
  12        3          1          16
  13        3          2          17  20
  14        3          2          18  20
  15        3          2          16  17
  16        3          2          20  21
  17        3          1          21
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
  2      1     2       0    8    6    0
         2     4       4    0    3    0
         3     4       0    4    0    5
  3      1     3       0    5    8    0
         2     4       0    4    8    0
         3    10       4    0    0    7
  4      1     7       0    3    0    7
         2     8       0    2    5    0
         3    10      10    0    0    5
  5      1     7       6    0    0    8
         2     7       0    2    0    8
         3    10       5    0    9    0
  6      1     4       0    6    4    0
         2     5       4    0    0    7
         3    10       4    0    0    3
  7      1     6       6    0    9    0
         2     7       0    3    0    4
         3     9       1    0    7    0
  8      1     1       0    3    9    0
         2     9       8    0    0    5
         3    10       7    0    7    0
  9      1     1       9    0    4    0
         2     1       8    0    0    6
         3     4       0    6    0    6
 10      1     5       3    0    0    6
         2     7       0    8    8    0
         3    10       0    1    0    4
 11      1     4       6    0    6    0
         2     5       0    2    0    7
         3     6       0    2    4    0
 12      1     1       5    0    4    0
         2     1       0    3    4    0
         3     9       0    3    0    8
 13      1     3       0    9    0    9
         2     6       6    0    0    9
         3     6       0    5    2    0
 14      1     2       0    6    0    3
         2     5       8    0    6    0
         3     6       0    3    2    0
 15      1     5       0    7    0    5
         2     6       0    7    0    4
         3     9       2    0    0    3
 16      1     2       0   10    0    3
         2     7       5    0    0    2
         3     9       0   10    9    0
 17      1     7       0    6    0    4
         2     8       0    6    7    0
         3     9       0    4    7    0
 18      1     3       3    0    0    6
         2     5       0    7    0    2
         3     9       0    6    8    0
 19      1     6       0    8    0    9
         2     8       6    0    9    0
         3    10       4    0    0    8
 20      1     1       0    8    0    6
         2     4       0    8    6    0
         3     6       7    0    4    0
 21      1     3       0   10    0    8
         2    10       0    7    0    6
         3    10       8    0   10    0
 22      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   17   97   93
************************************************************************
