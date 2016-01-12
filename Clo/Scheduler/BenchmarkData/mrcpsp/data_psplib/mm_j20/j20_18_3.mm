************************************************************************
file with basedata            : md338_.bas
initial value random generator: 233432899
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  145
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       18       17       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8  12
   3        3          2           9  11
   4        3          3           7  10  14
   5        3          1           6
   6        3          1          18
   7        3          1           8
   8        3          3           9  16  18
   9        3          3          13  17  19
  10        3          3          13  15  17
  11        3          3          13  14  19
  12        3          1          17
  13        3          1          20
  14        3          2          16  21
  15        3          2          16  18
  16        3          1          20
  17        3          2          20  21
  18        3          2          19  21
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       0   10    8    0
         2     4       0    9    0    9
         3     9       0    9    2    0
  3      1     6       6    0    0    1
         2     8       4    0    0    1
         3    10       0    2    4    0
  4      1     4       9    0    8    0
         2     8       9    0    0    5
         3    10       6    0    6    0
  5      1     3       7    0    0    6
         2     3       0    4    0    6
         3     4       0    3    0    4
  6      1     2       0    7    9    0
         2     3       0    6    0    1
         3     3       3    0    9    0
  7      1     1       6    0    0    7
         2     3       0    4    5    0
         3     9       3    0    3    0
  8      1     1       0    5    0    8
         2     1       0    5    6    0
         3     2       5    0    0    8
  9      1     6       0    6    0    6
         2    10       9    0    0    5
         3    10       0    5    5    0
 10      1     1       7    0    0    4
         2     3       0    9    0    3
         3     8       0    8    4    0
 11      1     4       0    9    0    6
         2     6       0    9    9    0
         3     7       3    0    7    0
 12      1     2       0    7    1    0
         2     6      10    0    0    3
         3     8       9    0    0    2
 13      1     4       0    8    9    0
         2     7       0    6    9    0
         3     9       6    0    0    9
 14      1     2       6    0    6    0
         2     3       0    8    3    0
         3     5       0    7    0    7
 15      1     6       0    9    7    0
         2    10       0    4    5    0
         3    10       2    0    7    0
 16      1     4      10    0    8    0
         2     5       0    2    1    0
         3     7       3    0    0    9
 17      1     5       5    0    0    3
         2     5       0    4    0    4
         3     7       5    0    7    0
 18      1     3       0    7    0    6
         2     7       0    5    0    3
         3    10       0    4    3    0
 19      1     4       7    0    0    2
         2     6       0    8    0    2
         3     6       0    1    3    0
 20      1     1       0    7    0    7
         2     2       5    0    7    0
         3     3       0    7    0    1
 21      1     1       0    8    0    7
         2     1       0    6    2    0
         3     8       7    0    0    6
 22      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   21   19   85   81
************************************************************************
