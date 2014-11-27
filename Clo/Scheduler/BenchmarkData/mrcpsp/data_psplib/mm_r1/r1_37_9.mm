************************************************************************
file with basedata            : cr137_.bas
initial value random generator: 2067839626
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  121
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21       13       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7  13
   3        3          1           6
   4        3          3           5   6   8
   5        3          2           9  15
   6        3          3          11  12  14
   7        3          3           9  12  15
   8        3          2          10  11
   9        3          2          10  11
  10        3          1          17
  11        3          1          16
  12        3          2          16  17
  13        3          3          14  16  17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     3       8    3    6
         2     4       8    3    5
         3     8       7    3    5
  3      1     2       8    8    6
         2     6       8    8    2
         3     6       7    8    5
  4      1     4       8    8    6
         2     5       8    7    5
         3     7       8    6    4
  5      1     3       9    9    2
         2     5       7    7    1
         3     7       4    4    1
  6      1     3       4    6    7
         2     4       4    5    7
         3     5       3    3    6
  7      1     5       9    8    3
         2     5       8    9    3
         3     6       8    3    2
  8      1     3       8   10    1
         2     3       9    9    1
         3     4       7    5    1
  9      1     4       6    9    7
         2     5       6    5    6
         3     7       5    4    4
 10      1     3       6    6    4
         2     4       5    6    3
         3     9       5    5    2
 11      1     1       6    7    3
         2     1       5    6    4
         3    10       3    5    2
 12      1     7       3    7   10
         2     9       2    5    5
         3     9       3    3    7
 13      1     1       7    9    6
         2     3       7    8    5
         3     9       5    5    2
 14      1     1       5    3    7
         2     4       4    2    5
         3     9       3    1    3
 15      1     2       7    6    8
         2     5       7    3    6
         3    10       6    1    4
 16      1     6       7    9    9
         2     8       7    5    9
         3    10       5    3    8
 17      1     2       8    5    8
         2     2       9    5    7
         3     5       4    5    2
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   14   77   63
************************************************************************
