************************************************************************
file with basedata            : c2127_.bas
initial value random generator: 947967253
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  125
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       25       10       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   9  10
   3        3          3           6   7   9
   4        3          3           5   7   8
   5        3          3          10  11  13
   6        3          3           8  10  13
   7        3          2          12  16
   8        3          3          11  12  16
   9        3          2          11  14
  10        3          3          12  14  17
  11        3          2          15  17
  12        3          1          15
  13        3          2          14  17
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
  2      1     9       8    0    0    5
         2     9       0    7    6    0
         3    10       0    3    0    8
  3      1     4       3    0   10    0
         2     5       3    0    0    6
         3     7       2    0    3    0
  4      1     2       0    2    0    6
         2     5       8    0    0    6
         3    10       0    2    9    0
  5      1     3       4    0    0    3
         2     4       0    6    0    3
         3     6       4    0    0    2
  6      1     8       6    0    7    0
         2     9       0    6    6    0
         3    10       0    6    4    0
  7      1     4       7    0    0   10
         2     6       6    0    5    0
         3     7       4    0    5    0
  8      1     5       0    4    4    0
         2     7       9    0    0    8
         3    10       0    4    0    5
  9      1     4       0    6    8    0
         2     6       7    0    8    0
         3     7       5    0    8    0
 10      1     2       0    7    0    8
         2     8       8    0    4    0
         3     8       9    0    0    3
 11      1     5       0    2    0    4
         2     6       0    1    2    0
         3     8       0    1    1    0
 12      1     1       0    4    6    0
         2     4       0    3    0    9
         3     4       9    0    5    0
 13      1     3       0    5    0    9
         2     8       0    2    4    0
         3    10       0    2    3    0
 14      1     2       6    0    0    3
         2     2       0    7    3    0
         3     4       5    0    3    0
 15      1     3       6    0    3    0
         2     7       4    0    3    0
         3     9       0    6    0    6
 16      1     2       9    0    8    0
         2     7       9    0    6    0
         3     9       0    2    0    7
 17      1     2       7    0    2    0
         2     3       7    0    1    0
         3     6       5    0    0    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   25   15   81   92
************************************************************************
