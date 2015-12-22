************************************************************************
file with basedata            : md244_.bas
initial value random generator: 1889156324
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  120
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       15       13       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5  14  16
   3        3          3           6  11  14
   4        3          3           6   8  11
   5        3          3           9  12  15
   6        3          3           7  10  13
   7        3          2          12  15
   8        3          2           9  14
   9        3          1          13
  10        3          2          12  16
  11        3          1          13
  12        3          1          17
  13        3          1          17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       0   10    6    1
         2     4       0    8    4    1
         3    10       4    0    2    1
  3      1     1       0    5    6    7
         2     3       0    4    5    5
         3     7       0    4    4    4
  4      1     1       4    0   10    1
         2     2       2    0    7    1
         3     3       0    3    4    1
  5      1     8       0    2    9    7
         2     8       8    0    7    8
         3     9       6    0    4    7
  6      1     1       9    0   10    5
         2     4       0    8    8    4
         3     5       0    5    7    3
  7      1     1       3    0   10    5
         2     8       0    6   10    3
         3     9       0    4   10    2
  8      1     3       9    0    7    4
         2     8       0    4    5    4
         3     9       0    3    3    4
  9      1     1       0    7    9    4
         2     1       8    0    8    6
         3     4       0    8    2    3
 10      1     1       8    0    7   10
         2     3       5    0    5    7
         3     9       0    7    2    7
 11      1     5       4    0    2    6
         2     7       0    4    2    4
         3     9       0    4    1    3
 12      1     4       6    0    9    7
         2     9       0    5    8    7
         3     9       0    8    8    6
 13      1     1       6    0    8    7
         2     1       0   10    8    7
         3     9       6    0    7    7
 14      1     6       1    0    3    7
         2     7       1    0    2    7
         3     9       1    0    1    6
 15      1     3       7    0    8    4
         2     4       6    0    4    2
         3     5       2    0    1    1
 16      1     4       9    0    7   10
         2     4       0    8    7    8
         3     5       9    0    6    3
 17      1     2       0    8    7    4
         2     5       0    5    6    4
         3     9       9    0    1    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   28   23  104   84
************************************************************************
