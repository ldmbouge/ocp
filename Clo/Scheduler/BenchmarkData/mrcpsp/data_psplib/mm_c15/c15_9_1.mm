************************************************************************
file with basedata            : c159_.bas
initial value random generator: 27857
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18       14       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7   8
   3        3          1          15
   4        3          3           5   6  10
   5        3          2           8  15
   6        3          2          14  16
   7        3          1          11
   8        3          3           9  12  13
   9        3          1          11
  10        3          1          16
  11        3          1          17
  12        3          1          17
  13        3          1          17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       0    6    3    0
         2     2       3    0    3    0
         3     8       0    6    2    0
  3      1     1       0    6    0    9
         2     3       0    5    0    5
         3     4       0    5    0    2
  4      1     3       0    8    0    9
         2     5       3    0    3    0
         3     9       0    6    0    8
  5      1     1       0    5    3    0
         2     5       0    3    2    0
         3    10       4    0    2    0
  6      1     2       6    0    0   10
         2     7       5    0    4    0
         3     7       6    0    0    8
  7      1     1       8    0    0    6
         2     3       8    0    9    0
         3     5       7    0    9    0
  8      1     2       4    0    5    0
         2     3       0    6    1    0
         3     6       2    0    0    9
  9      1     4       0    5    9    0
         2     5       6    0    9    0
         3     7       0    4    0    4
 10      1     3       4    0    0    5
         2     8       0    7    0    4
         3    10       0    6    6    0
 11      1     3       0    2    9    0
         2     4       6    0    6    0
         3     9       4    0    6    0
 12      1     2       7    0    6    0
         2     3       7    0    5    0
         3     9       0    6    0    5
 13      1     1       0    6    0    8
         2     2       7    0    0    7
         3     7       0    6    6    0
 14      1     1       7    0    6    0
         2     4       0    7    4    0
         3    10       0    7    3    0
 15      1     2       6    0    0    5
         2     5       0    1    0    3
         3    10       5    0    5    0
 16      1     4       4    0    0    7
         2     8       0    9    0    5
         3     9       0    6    2    0
 17      1     5       0    4    6    0
         2     6       5    0    0   10
         3     9       0    4    0    9
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   10   12   48   45
************************************************************************