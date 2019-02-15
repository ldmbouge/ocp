************************************************************************
file with basedata            : cr433_.bas
initial value random generator: 98051158
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23       13       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           9  11  14
   3        3          3           5   6   7
   4        3          1          11
   5        3          2          12  14
   6        3          1           9
   7        3          3           8   9  10
   8        3          3          14  15  17
   9        3          2          12  16
  10        3          3          11  12  16
  11        3          2          15  17
  12        3          1          13
  13        3          2          15  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     3       6    0    0    3    7    5
         2     7       0   10    0    3    5    5
         3     9       3    0    0    3    1    4
  3      1     5       7    8    0    0    5    3
         2     5       0    8    8    7    3    3
         3     8       8    7    7    0    1    3
  4      1     1       9    0    8    5    4   10
         2     3       8    0    2    0    2    4
         3     4       0    6    0    0    2    2
  5      1     3       0    9    0    8   10    7
         2     8       0    1    6    0    8    6
         3     8       0    0    0    7    9    6
  6      1     5       4    0    0   10    5    9
         2     8       4    6    0    0    5    9
         3     9       0    5    7    7    2    9
  7      1     5       6    6    5    9    8    9
         2     7       0    0    0    7    7    8
         3     8       5    0    0    4    5    6
  8      1     5       4    9    4    8    3    7
         2     6       4    9    0    0    3    5
         3    10       0    0    3    5    2    4
  9      1     1       0   10    2    6    9    2
         2     2       0    7    2    2    6    2
         3    10       7    0    0    0    4    2
 10      1     4       0    7    0    4    7   10
         2     8       8    6    7    0    7    8
         3     9       0    5    0    0    6    8
 11      1     1       0    4    0    0    7    5
         2     8       0    0    8    0    6    5
         3    10       3    0    7    4    3    5
 12      1     1       0    3    0    0    9    9
         2     5       0    0    9    5    5    8
         3     7       0    0    9    0    5    5
 13      1     1       6    0    2    1    5    9
         2     6       3    0    0    0    4    7
         3     8       0    1    1    0    4    6
 14      1     4       7    0    7    4    9   10
         2     8       6    0    7    0    7    8
         3     9       1    0    7    0    5    6
 15      1     1       0    8    8   10    5    8
         2     3       0    8    7    9    5    5
         3     5       7    4    0    0    5    1
 16      1     4       0    0    6    0    2    9
         2     7       0    0    0    9    2    7
         3    10       0    8    0    0    1    6
 17      1     3       0    6    0    0    9    5
         2     3       0    4    0    0    9    6
         3     5       6    0    0    0    8    4
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
    7   13   11   10   73   87
************************************************************************
