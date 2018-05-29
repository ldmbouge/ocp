************************************************************************
file with basedata            : cr420_.bas
initial value random generator: 1578254906
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17       12       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  10  14
   3        3          1          15
   4        3          3           5   7  11
   5        3          3           6  10  12
   6        3          3           8   9  13
   7        3          3           8  12  17
   8        3          1          15
   9        3          2          14  15
  10        3          2          13  16
  11        3          3          13  14  16
  12        3          1          16
  13        3          1          17
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     2       0    0    0    8    2    0
         2     7       0    3    0    7    1    0
         3    10       0    0    0    6    1    0
  3      1     1       0    0    8    5    4    0
         2     3       5    0    5    0    0    7
         3     5       0    0    5    0    0    6
  4      1     1       0    0   10    3    3    0
         2     2       0   10    0    0    0   10
         3     9       1    6    8    3    0    5
  5      1     3       7    6    0    0    0    7
         2     4       7    4    0    0    9    0
         3     6       0    0    2    0    9    0
  6      1     3       0    5    0    6    8    0
         2     4       0    5    0    5    8    0
         3     6       4    5    0    0    7    0
  7      1     4       0    2    0    0    5    0
         2     8       0    1    9    6    0   10
         3     9       0    0    4    4    3    0
  8      1     5       7    0    0    4    8    0
         2     7       5    8    7    4    8    0
         3     9       0    7    6    1    0    2
  9      1     5       8    3    0    5   10    0
         2     5       0    3    8    7    7    0
         3     8       0    0    5    0    7    0
 10      1     2       3    0    0    7    0    7
         2     5       3    0    0    3    9    0
         3     7       2    0    0    0    0    6
 11      1     4       7    7    0    0    3    0
         2     6       7    6    0    0    0    3
         3    10       5    6    0    0    1    0
 12      1     1       0    0    0    3    6    0
         2     1       0    0    5    4    5    0
         3    10       7    2    5    0    5    0
 13      1     5       8    2    0    0    0    8
         2     5       7    0    0    0    0    9
         3     9       4    0    0    0    0    5
 14      1     2      10    1    8    0    4    0
         2     6       8    0    7    6    4    0
         3    10       6    0    0    3    4    0
 15      1     1       4    0    5    0    5    0
         2     3       0    5    0    0    0    2
         3     9       0    0    5    9    4    0
 16      1     6       3    0   10    0    0    4
         2     6       3    7    0    0    2    0
         3     8       0    0   10    4    2    0
 17      1     3       6    0    2    0    0    7
         2     5       6    8    0    0    5    0
         3     8       1    8    2    0    2    0
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   30   18   25   19   68   52
************************************************************************
