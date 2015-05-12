************************************************************************
file with basedata            : cm423_.bas
initial value random generator: 20712
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  139
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21        1       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        4          2           6  13
   3        4          3           9  11  15
   4        4          2           5  11
   5        4          2           6   8
   6        4          2           7  14
   7        4          2          10  12
   8        4          3           9  12  15
   9        4          2          10  13
  10        4          2          16  17
  11        4          2          12  13
  12        4          2          16  17
  13        4          2          16  17
  14        4          1          15
  15        4          1          18
  16        4          1          18
  17        4          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       5    8   10    0
         2     4       5    5    0    6
         3     6       5    3    0    5
         4     7       5    2    0    3
  3      1     1       6    4    0    7
         2     2       5    3    0    7
         3     3       3    3    0    6
         4    10       2    2    0    6
  4      1     4       9    8    2    0
         2     5       8    7    0    7
         3     5       9    7    0    6
         4    10       6    6    0    4
  5      1     3       5    5    0    6
         2     8       4    4    0    4
         3     9       2    4    2    0
         4     9       3    3    7    0
  6      1     1       9    9    5    0
         2     2       9    8    4    0
         3     6       9    6    0    6
         4    10       8    3    3    0
  7      1     1       5    9    0    3
         2     4       5    8    9    0
         3     8       5    5    6    0
         4    10       5    2    0    2
  8      1     4       5    9    6    0
         2     7       5    8    6    0
         3     8       4    8    0    7
         4     9       2    5    6    0
  9      1     3       6    4    0    9
         2     5       5    3    6    0
         3     6       4    3    3    0
         4     8       2    2    0    8
 10      1     1       8    5    6    0
         2     4       7    4    6    0
         3     7       6    3    2    0
         4    10       5    2    0    6
 11      1     1       5    4    0    8
         2     7       4    4    0    8
         3     8       4    3    0    5
         4     9       2    3    6    0
 12      1     2       8    5    0    5
         2     3       7    5    0    4
         3     5       7    5    7    0
         4     6       7    4    4    0
 13      1     3       6   10    7    0
         2     4       5   10    0   10
         3     5       4   10    0    8
         4     9       3    9    4    0
 14      1     1       3    5    9    0
         2     3       2    5    8    0
         3     5       2    4    7    0
         4     7       1    3    7    0
 15      1     2       8   10    7    0
         2     7       7    7    0    5
         3    10       4    6    7    0
         4    10       5    5    0    1
 16      1     4       9    2   10    0
         2     5       8    2    0    7
         3     5       7    2    7    0
         4     8       7    2    0    6
 17      1     2       8    8    7    0
         2     2       6    8    0    4
         3     3       6    7    7    0
         4     7       3    6    6    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   20   80   74
************************************************************************
