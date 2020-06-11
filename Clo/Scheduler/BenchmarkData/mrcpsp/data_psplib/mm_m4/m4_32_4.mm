************************************************************************
file with basedata            : cm432_.bas
initial value random generator: 445630988
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  118
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17        4       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        4          3           5   7  10
   3        4          3           6   8  15
   4        4          2          14  15
   5        4          3           8   9  12
   6        4          2           9  16
   7        4          3           8   9  12
   8        4          2          16  17
   9        4          1          11
  10        4          2          11  14
  11        4          1          17
  12        4          1          13
  13        4          2          14  15
  14        4          2          16  17
  15        4          1          18
  16        4          1          18
  17        4          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       2    7    7    0
         2     5       2    6    0    6
         3     7       1    3    0    5
         4     7       2    5    8    0
  3      1     2      10    7    0    8
         2     3      10    6    0    7
         3     5       9    6    0    7
         4     8       9    6    5    0
  4      1     3       6   10    0    5
         2     3       6   10   10    0
         3     4       4    8    0    4
         4     4       4    8    8    0
  5      1     3       8    7    6    0
         2     5       5    7    0    8
         3     5       6    6    0    8
         4     8       4    6    0    5
  6      1     1       8    6    7    0
         2     3       7    5    0    8
         3     4       5    4    6    0
         4     5       2    4    4    0
  7      1     2       8    8    0    7
         2     5       6    5    0    6
         3     5       4    5    4    0
         4     9       2    4    0    5
  8      1     2      10    7    0    6
         2     3      10    6    8    0
         3     7      10    6    4    0
         4     8      10    5    0    4
  9      1     1       8   10    0    8
         2     2       7    8    0    8
         3     4       7    5    0    8
         4     9       5    4    0    7
 10      1     2       9    8    7    0
         2     8       8    7    5    0
         3     9       6    4    0    6
         4    10       5    4    0    3
 11      1     3       8   10    6    0
         2     7       5    5    0    7
         3     9       2    3    0    5
         4     9       2    3    5    0
 12      1     2      10    6    3    0
         2     4       9    6    0   10
         3     7       9    6    0    5
         4     9       8    6    3    0
 13      1     2       8    8    2    0
         2     2       9    7    0    8
         3     8       8    5    0    8
         4     9       7    4    0    7
 14      1     2       3    8    8    0
         2     3       3    6    0    7
         3     4       2    4    6    0
         4     6       1    3    0    6
 15      1     5       8    7    0    3
         2     5       6    9    9    0
         3     6       4    4    8    0
         4     9       2    3    0    2
 16      1     1      10    7    6    0
         2     2      10    7    0    8
         3     2      10    7    5    0
         4     4       9    6    0    6
 17      1     1       7    8    5    0
         2     2       6    7    2    0
         3     4       2    7    0    7
         4     4       3    7    0    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   28   24   94  112
************************************************************************
