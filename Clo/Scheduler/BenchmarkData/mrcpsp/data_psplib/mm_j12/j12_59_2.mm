************************************************************************
file with basedata            : md123_.bas
initial value random generator: 1174194597
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  81
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       15        9       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           9  10  13
   3        3          3           5   8   9
   4        3          3           6   7  11
   5        3          3           7  10  11
   6        3          2           8  10
   7        3          1          13
   8        3          2          12  13
   9        3          2          11  12
  10        3          1          12
  11        3          1          14
  12        3          1          14
  13        3          1          14
  14        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       0    8    6    8
         2     5       4    0    5    5
         3     7       4    0    5    2
  3      1     4       0    5    9    5
         2     7       0    4    7    4
         3     7       7    0    6    4
  4      1     1       0    7    9    3
         2     6       0    6    9    3
         3     7       0    4    8    3
  5      1     2       7    0    8    5
         2     3       5    0    7    5
         3     6       4    0    6    4
  6      1     7       0    3    8    5
         2    10       6    0    3    5
         3    10       5    0    5    5
  7      1     2       0    5    8    5
         2     5       0    4    4    5
         3     5       6    0    5    5
  8      1     1       0    4    5    4
         2     2       0    3    4    3
         3     6       0    2    2    3
  9      1     3       0    6   10    4
         2     8       0    4   10    4
         3     9       3    0   10    4
 10      1     3       0    7    6    5
         2     4       0    4    5    3
         3     8       5    0    3    1
 11      1     1       6    0    6    6
         2     1       0    5    6    5
         3     4       0    3    5    3
 12      1     4       0    3    8    7
         2     6       9    0    8    5
         3     6       0    2    7    4
 13      1     3       9    0    4    6
         2     4       0    3    3    5
         3     6       0    2    3    5
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   16   16   87   63
************************************************************************
