************************************************************************
file with basedata            : cn344_.bas
initial value random generator: 689377545
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  127
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       26        0       26
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   6
   3        3          2          13  17
   4        3          2           5   6
   5        3          3           7   8   9
   6        3          2           9  16
   7        3          3          10  11  16
   8        3          3          10  12  13
   9        3          2          10  11
  10        3          1          15
  11        3          2          15  17
  12        3          2          14  17
  13        3          1          14
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     6      10    0    9    5   10
         2    10       0    5    7    5    9
         3    10       9    0    9    5    9
  3      1     3       0    9    7    2    2
         2     5       3    0    7    2    2
         3     7       0    7    6    2    2
  4      1     8       0    7    5    5    6
         2     8       4    0    5    5    6
         3     9       0    7    5    3    5
  5      1     2       3    0    5    8    4
         2     5       0    6    5    4    3
         3     7       0    5    4    1    3
  6      1     1       0    8   10    3    5
         2     6       0    7   10    2    3
         3     7       0    7    9    1    1
  7      1     4       1    0    3    8    7
         2     6       1    0    3    6    7
         3     9       0    9    2    4    5
  8      1     5       0    5    5    7    6
         2     5       0    5    5    8    4
         3    10       6    0    5    7    4
  9      1     9       0    7    6    5    5
         2     9       0    7    5    7    5
         3    10       0    7    3    3    5
 10      1     2       0    9    7    8    7
         2     5       0    9    6    7    4
         3    10       0    8    6    5    1
 11      1     1       0    4   10    9    2
         2     6       9    0   10    9    2
         3     6      10    0    9    9    2
 12      1     4       3    0   10    7    9
         2     4       0    5    9    6   10
         3     5       0    5    6    5    9
 13      1     4       0    5    7    6   10
         2     4       0    6    6    6    9
         3     7       3    0    6    4    9
 14      1     1       0    7    9   10    7
         2     1       9    0   10   10    8
         3     2       0    7    8   10    7
 15      1     5       0    6    4   10    8
         2     6       0    5    3    6    6
         3     9       0    4    3    4    4
 16      1     4       6    0    6   10    8
         2     8       4    0    6    7    6
         3    10       0    3    6    5    5
 17      1     4       0    2    9    8    9
         2     5       0    2    6    6    6
         3     9       0    1    1    6    6
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   17   27  100   94   92
************************************************************************
