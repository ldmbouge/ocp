************************************************************************
file with basedata            : md81_.bas
initial value random generator: 1177415275
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  90
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       15        2       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   6
   3        3          2           8   9
   4        3          3           7   8  10
   5        3          2          11  12
   6        3          3           8   9  10
   7        3          2           9  12
   8        3          1          13
   9        3          2          11  13
  10        3          3          11  12  13
  11        3          1          14
  12        3          1          14
  13        3          1          14
  14        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       8    0    5    0
         2     3       0    2    3    0
         3     5       6    0    0    3
  3      1     1       9    0    7    0
         2     6       0    3    0    3
         3     6       0    3    4    0
  4      1     1       0    8   10    0
         2     7       7    0    9    0
         3     9       6    0    9    0
  5      1     5       0    7    0    5
         2     5       5    0    0    5
         3    10       4    0    0    3
  6      1     1       9    0    0    7
         2     4       0    9    0    1
         3     6       0    7    6    0
  7      1     2       0    3    5    0
         2     6       3    0    0    3
         3     9       0    2    0    3
  8      1     5       6    0    0    9
         2     6       0    9    0    8
         3     8       0    3    0    6
  9      1     4       0    9    7    0
         2     4       9    0    0    6
         3     7       5    0    0    5
 10      1     5       5    0    0   10
         2     5       0    3    9    0
         3     5       7    0    9    0
 11      1     7       8    0    0    2
         2     9       0    7    3    0
         3     9       4    0    7    0
 12      1     1       6    0    0   10
         2     2       4    0    9    0
         3     6       2    0    0    5
 13      1     3       5    0    0    8
         2     5       0   10    0    8
         3    10       0    2    0    5
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
    8    7   51   53
************************************************************************
