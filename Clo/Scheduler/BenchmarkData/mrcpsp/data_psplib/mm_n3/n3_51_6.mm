************************************************************************
file with basedata            : cn351_.bas
initial value random generator: 1595129920
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  125
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23        2       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6  11  12
   3        3          2          15  17
   4        3          2           5   6
   5        3          3           7   8   9
   6        3          3           7   8  16
   7        3          2          10  14
   8        3          1          10
   9        3          3          10  14  16
  10        3          1          13
  11        3          2          13  16
  12        3          1          13
  13        3          2          15  17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     4       0    8    4    6    5
         2     5       0    7    4    6    3
         3     6       0    6    3    3    3
  3      1     1      10    0    9    8    5
         2     1      10    0    7   10    4
         3     9       3    0    6    4    4
  4      1     1       0    7    8    2    6
         2     2       0    6    7    1    4
         3     4      10    0    5    1    3
  5      1     1       9    0    4    7    7
         2     8       0    5    3    5    7
         3    10       0    4    3    5    6
  6      1     4       0    9    9    5    2
         2     5       0    4    7    4    2
         3     9       0    3    6    3    2
  7      1     1       0   10    8    7    8
         2     9       5    0    6    5    6
         3     9       6    0    6    2    6
  8      1     1       0    5    6   10    7
         2     8       5    0    5    8    7
         3    10       0    4    4    5    6
  9      1     2       5    0    7    7    8
         2     9       4    0    6    4    7
         3    10       0    6    5    2    6
 10      1     5       0    7    9    8    7
         2     7       0    5    8    7    6
         3     9      10    0    5    7    6
 11      1     1       0    4    8    8    6
         2     7       7    0    8    8    5
         3     8       0    3    8    7    5
 12      1     3      10    0    7    8    6
         2     5       0    5    7    7    6
         3     6       0    3    7    3    5
 13      1     1       5    0    9    9    4
         2     2       0    6    6    4    3
         3     4       0    5    2    4    3
 14      1     3       3    0    3    6   10
         2     3       0    6    3    8   10
         3     6       4    0    3    3   10
 15      1     8       0    4    1    5    8
         2     9       0    2    1    3    6
         3    10       0    1    1    2    6
 16      1     3       0    7    9    7    5
         2    10       8    0    9    4    4
         3    10       0    5    8    4    2
 17      1     3       7    0    9    6    8
         2     4       7    0    6    5    7
         3     5       0    6    6    5    6
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   20   19  102  100   96
************************************************************************
