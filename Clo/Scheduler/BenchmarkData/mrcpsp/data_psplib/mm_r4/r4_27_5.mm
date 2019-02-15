************************************************************************
file with basedata            : cr427_.bas
initial value random generator: 1010173818
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  132
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       26        3       26
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8  10
   3        3          3           5   6   7
   4        3          3           7  10  13
   5        3          2           9  16
   6        3          3          11  13  15
   7        3          2           9  16
   8        3          2           9  12
   9        3          2          11  14
  10        3          1          17
  11        3          1          17
  12        3          3          13  15  17
  13        3          1          16
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     4       7    0    0    7    7    0
         2     9       4    0    7    6    0    8
         3    10       0    8    7    0    5    0
  3      1     4       0    4    7    0    4    0
         2     8       0    4    0    0    0    9
         3     9       0    0    3    0    4    0
  4      1     2       0    0    4    0    9    0
         2     7       0   10    0    7    7    0
         3     8       0    9    4    0    4    0
  5      1     3       6    5    0    0    0    5
         2     8       0    5    0    0    0    3
         3    10       5    0    2    0   10    0
  6      1     1       7    5   10    0    1    0
         2     3       0    0    5    0    0    4
         3     5       4    0    0    3    1    0
  7      1     6       7   10    6    0    5    0
         2     9       6    0    0    0    0    4
         3    10       0    7    6    6    0    3
  8      1     1       4    0    0    0    9    0
         2     7       0    0    2    0    9    0
         3     9       3    0    0    7    0    2
  9      1     5       0    8    0    0    6    0
         2     6       6    2    0    0    0    3
         3     6       0    2    6    6    4    0
 10      1     1       5    7    0    8    0    8
         2     3       2    0    0    6    8    0
         3     9       1    0    4    6    3    0
 11      1     2       0    0    7    8    9    0
         2     2       6    0    8    0    8    0
         3     9       0    0    7    7    8    0
 12      1     4      10    5    0   10    8    0
         2     9       8    4    0    0    0    4
         3     9       0    4    0   10    0    4
 13      1     1       2    0    7   10    0    2
         2     5       0    6    0    0    3    0
         3     5       2    8    5    9    2    0
 14      1     3       6    0    3    6    0    5
         2     4       3    4    0    0    0    3
         3     4       0    0    1    0    4    0
 15      1     3       7    9    0    0    7    0
         2     9       2    0    9    8    0    2
         3    10       0    0    6    5    1    0
 16      1     3       8    1    7    0    7    0
         2     3       0    0    0    5    6    0
         3     9       8    0    5    0    6    0
 17      1     9       0    0    2    0    0    4
         2     9       0    9    0    0    8    0
         3    10       0    6    0    9    2    0
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   22   18   19   20  105   60
************************************************************************
