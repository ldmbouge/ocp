************************************************************************
file with basedata            : md86_.bas
initial value random generator: 1353045043
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  93
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       17        7       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8   9
   3        3          3           6   8   9
   4        3          2           6   9
   5        3          3           7  11  13
   6        3          3           7  10  11
   7        3          1          12
   8        3          1          10
   9        3          3          10  11  12
  10        3          1          13
  11        3          1          14
  12        3          1          14
  13        3          1          14
  14        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       6    3    8    0
         2     6       6    3    6    0
         3     7       6    2    6    0
  3      1     5      10    4    0    4
         2     5      10    4    5    0
         3     8       9    4    4    0
  4      1     3       6    3    8    0
         2     7       5    2    5    0
         3     9       5    2    0    6
  5      1     2       5    7    0    6
         2     2       5    7   10    0
         3     3       3    6    7    0
  6      1     1       3    9    0    5
         2     6       3    7    0    5
         3     8       2    2    0    5
  7      1     1       7    5    0    9
         2     5       5    5    6    0
         3     7       4    4    0    8
  8      1     1       8    9    8    0
         2     4       7    9    8    0
         3    10       6    7    7    0
  9      1     3       5    4    0    7
         2     5       4    3    8    0
         3     7       1    3    0    6
 10      1     3       7    9    6    0
         2     5       4    5    5    0
         3     6       1    4    0    7
 11      1     2      10    2    0   10
         2     7      10    2    0    8
         3    10      10    1    0    7
 12      1     2       5    5    6    0
         2     8       5    5    0    8
         3     9       4    2    5    0
 13      1     6       7    7    0   10
         2     6       9    7    7    0
         3     9       5    5    0    8
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   16   15   57   57
************************************************************************
