************************************************************************
file with basedata            : cn111_.bas
initial value random generator: 1989444993
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21       14       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5  11  16
   3        3          3           6  12  13
   4        3          2           8  12
   5        3          2          12  14
   6        3          2           7   9
   7        3          2           8  10
   8        3          1          11
   9        3          2          10  11
  10        3          3          14  15  16
  11        3          1          14
  12        3          2          15  17
  13        3          3          15  16  17
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     4       0   10    0
         2     9       0    8    8
         3     9       7    0    0
  3      1     2       5    0    8
         2     2       0    7    0
         3     7       6    0    0
  4      1     1       0    6   10
         2     5       7    0    9
         3     8       0    6    0
  5      1     6       8    0    0
         2     8       5    0    0
         3    10       0    9    4
  6      1     3       0    2    0
         2     6       6    0    0
         3     8       5    0    0
  7      1     3       6    0    0
         2     4       0    3    7
         3     6       0    3    6
  8      1     2       0    5    8
         2     2       9    0    0
         3     8       7    0    0
  9      1     3       9    0    9
         2     8       7    0    0
         3    10       0    8    8
 10      1     1       6    0    6
         2     3       0    6    5
         3     3       5    0    5
 11      1     4       0    4    0
         2     9       1    0    7
         3     9       0    2    2
 12      1     3       0    6   10
         2     9       9    0    9
         3    10       8    0    9
 13      1     6       0    7    0
         2     9       4    0    9
         3    10       0    4    0
 14      1     2       0    2    0
         2     7       0    1    0
         3     8       5    0    8
 15      1     2       5    0    0
         2     9       0   10    4
         3    10       0    8    0
 16      1     4       5    0    0
         2     6       4    0    0
         3     7       0    7    6
 17      1     5       5    0    4
         2     5       0    6    4
         3     7       4    0    0
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   21   20   61
************************************************************************
