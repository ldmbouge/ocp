************************************************************************
file with basedata            : cr330_.bas
initial value random generator: 1900634013
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  117
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       11       12       11
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8  11
   3        3          2           9  14
   4        3          3           6   9  13
   5        3          2           6   7
   6        3          2          10  17
   7        3          3           9  12  13
   8        3          2          15  16
   9        3          3          10  16  17
  10        3          1          15
  11        3          1          13
  12        3          2          14  15
  13        3          2          14  16
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     2       4   10    8    0    5
         2     8       3    8    8    6    0
         3     9       1    6    7    6    0
  3      1     2       5    7    8    8    0
         2     5       2    7    7    7    0
         3     7       1    7    3    6    0
  4      1     2       9   10    6    2    0
         2     2       8    9    6    0    5
         3     6       7    6    5    0    2
  5      1     1       5   10    9    5    0
         2     2       5    8    7    3    0
         3     4       5    7    4    0    2
  6      1     2       3    5    7   10    0
         2     8       2    5    5    0    6
         3     9       2    4    3    0    4
  7      1     1       6    8    6    0    8
         2     4       6    7    4    0    5
         3     5       4    7    4    0    4
  8      1     2       9    8    4    0    8
         2     6       7    6    3    0    6
         3     9       6    4    2    6    0
  9      1     1       7    5    6    7    0
         2     4       6    5    5    0    8
         3     5       4    5    5    0    2
 10      1     5       6    9    3    5    0
         2     6       6    8    2    0    5
         3     9       5    6    2    0    5
 11      1     3       5    9    7    4    0
         2     4       3    7    6    2    0
         3     9       2    5    6    0    4
 12      1     2       9    8   10    0    4
         2     3       9    8    8    9    0
         3     6       7    8    7    8    0
 13      1     1       4    5    5    0    7
         2     1       5    5    5    8    0
         3     7       4    3    4    7    0
 14      1     1       4   10    4    0    9
         2     3       2    9    4    0    7
         3     6       1    9    3    0    5
 15      1     1       5    6    8    0    7
         2     3       2    5    6    0    6
         3    10       1    5    5   10    0
 16      1     2       6    8    7    9    0
         2     3       4    8    4    0    3
         3     8       3    8    1    0    3
 17      1     2       2    9    7    8    0
         2     8       2    7    7    8    0
         3     8       2    8    7    0    4
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   16   20   19   97   85
************************************************************************
