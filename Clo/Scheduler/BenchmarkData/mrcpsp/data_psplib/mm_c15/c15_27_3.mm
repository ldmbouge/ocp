************************************************************************
file with basedata            : c1527_.bas
initial value random generator: 807630212
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17        8       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8  11
   3        3          3           6   8  17
   4        3          2           5  17
   5        3          1          10
   6        3          3           7   9  12
   7        3          1          13
   8        3          1           9
   9        3          1          15
  10        3          1          13
  11        3          1          13
  12        3          1          14
  13        3          1          16
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       0    2   10    0
         2     3       1    0    0    7
         3     8       0    3    8    0
  3      1     7       0    4    0    7
         2     7       6    0    0    6
         3    10       5    0    0    5
  4      1     4       0    2    9    0
         2     5       7    0    9    0
         3     8       6    0    6    0
  5      1     1       0    7    7    0
         2     3       0    7    0    4
         3     5       3    0    4    0
  6      1     2       5    0    0    5
         2     4       4    0    3    0
         3     5       3    0    3    0
  7      1     2       0    6    4    0
         2     5       0    6    3    0
         3     8       0    6    0    6
  8      1     3       7    0    6    0
         2     4       7    0    0    6
         3    10       0    3    2    0
  9      1     2       7    0    0    8
         2     7       0   10    7    0
         3     8       0    6    0    5
 10      1     1       3    0    9    0
         2     6       3    0    0    5
         3    10       3    0    0    4
 11      1     1       5    0    7    0
         2     7       0    9    0    7
         3     8       3    0    0    5
 12      1     1       9    0    0    5
         2     3       5    0    6    0
         3     9       0    1    2    0
 13      1     3       0    4    8    0
         2     7       4    0    0    5
         3     8       3    0    3    0
 14      1     1       0    4    7    0
         2     2       9    0    6    0
         3     6       7    0    6    0
 15      1     5       0    5    1    0
         2     7       0    5    0    2
         3     8       7    0    1    0
 16      1     1       0    9   10    0
         2     9       4    0    0    9
         3    10       0    6   10    0
 17      1     2       0    4    0    5
         2     2       9    0    6    0
         3     3       8    0    6    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   19  100   81
************************************************************************
