************************************************************************
file with basedata            : c2162_.bas
initial value random generator: 19746
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  121
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       15        2       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   8   9
   3        3          3           6   7   8
   4        3          3           5   6   9
   5        3          3           7   8  10
   6        3          3          11  12  14
   7        3          2          13  14
   8        3          3          14  15  16
   9        3          3          11  13  17
  10        3          3          11  12  17
  11        3          2          15  16
  12        3          2          13  15
  13        3          1          16
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     4       9    5    9    4
         2     5       8    4    9    3
         3     9       8    2    8    2
  3      1     3       9    9    5    7
         2     4       7    8    3    5
         3     7       6    7    3    2
  4      1     1       6    8    8    9
         2     5       5    8    6    9
         3     6       4    6    4    8
  5      1     1       6    8    5    9
         2     7       5    8    5    9
         3     9       4    8    4    6
  6      1     4       3    4    7    8
         2     5       2    3    6    8
         3     8       2    2    6    7
  7      1     3      10    4   10    7
         2     4       7    3    6    6
         3     8       6    3    3    4
  8      1     3      10    7    5    7
         2     4       8    2    4    7
         3     4       8    5    3    6
  9      1     1       5    4   10    3
         2     1       7    4    9    3
         3     4       5    4    8    3
 10      1     1       7    2    1    4
         2     5       4    2    1    4
         3    10       3    2    1    4
 11      1     3       9    4    3   10
         2     8       8    3    2    9
         3     9       8    2    2    7
 12      1     4       4    9    8    7
         2     5       3    6    7    7
         3    10       1    2    7    3
 13      1     1       3    8    8   10
         2     3       2    8    6    6
         3     4       2    8    4    3
 14      1     2      10    8    6    5
         2     8       5    8    6    4
         3     9       5    7    6    4
 15      1     3       9   10    8    6
         2     4       6    9    8    6
         3    10       5    7    4    3
 16      1     1       8    4    5    9
         2     3       7    2    4    7
         3     7       4    1    4    4
 17      1     3       8    9    5   10
         2     6       5    7    4    9
         3     7       5    7    2    7
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   18  103  115
************************************************************************
