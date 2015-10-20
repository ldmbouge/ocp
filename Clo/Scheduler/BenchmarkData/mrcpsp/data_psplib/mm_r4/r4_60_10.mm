************************************************************************
file with basedata            : cr460_.bas
initial value random generator: 1960719319
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       25       12       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7  13
   3        3          2           8   9
   4        3          3           5   6  13
   5        3          3           8   9  10
   6        3          2          12  16
   7        3          3           9  11  16
   8        3          1          15
   9        3          1          14
  10        3          2          11  12
  11        3          2          14  15
  12        3          1          14
  13        3          3          15  16  17
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     3       0    9    0    6   10    5
         2     4      10    0    0    0    9    3
         3     5       3    1    5    0    9    2
  3      1     1       4    7    4    1   10    8
         2     4       0    0    4    0    9    7
         3     6       3    0    3    0    8    6
  4      1     3       5    3    0    5    3    9
         2     4       0    2    4    4    2    9
         3     5       4    0    0    0    2    6
  5      1     5       4    0    0    4    6    5
         2     6       3    0    0    3    6    5
         3     9       0    0    7    0    6    4
  6      1     4       8    0   10    0   10    2
         2     4       8    5    0    0   10    2
         3    10       7    3    0    0   10    2
  7      1     5       0    9    0    6   10    9
         2     7       0    0    0    6   10    8
         3     9       0    0    0    5   10    7
  8      1     1       0    0    0    8    8    7
         2     4       2    0    9    0    6    6
         3    10       1    0    5    7    4    5
  9      1     1       8    0    7    0    7    8
         2     4       7    0    0    9    6    7
         3     9       7    0    0    8    2    6
 10      1     1       0    4    0    0    7    9
         2     6       4    4    0    8    5    8
         3     7       1    4    5    0    5    6
 11      1     3       0    0    6    0    8    6
         2     8       7    0    0    0    6    5
         3    10       0    7    1    6    4    4
 12      1     1       6    0    0    0    5    6
         2     4       5    0    0    6    4    5
         3     7       5    0    0    0    2    3
 13      1     7       0    8    0    7    2    6
         2     8       7    5    5    7    2    5
         3    10       4    0    0    6    2    4
 14      1     7       0    0    0    8    7   10
         2     9       0    0    5    0    7    7
         3    10       8    0    4    7    5    6
 15      1     1       0    0    7    0    9    6
         2     2       7    0    7    4    8    5
         3     7       0    2    0    0    8    2
 16      1     2       7    0    3    8    8    6
         2     4       6    8    2    7    6    6
         3    10       0    8    0    7    4    6
 17      1     6       8    8    9    6    7    9
         2     8       0    0    2    0    7    8
         3     9       8    0    0    0    5    6
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   21   22   24   32  117  111
************************************************************************
