************************************************************************
file with basedata            : md239_.bas
initial value random generator: 23543602
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  125
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       15       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           6  13
   3        3          2           5  10
   4        3          2          10  12
   5        3          3           7   8   9
   6        3          3           7  10  14
   7        3          2          12  17
   8        3          3          11  13  14
   9        3          2          13  14
  10        3          1          16
  11        3          3          15  16  17
  12        3          1          15
  13        3          2          15  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       5    7    8    6
         2     6       3    5    7    3
         3     8       1    3    7    3
  3      1     1       7    8    4   10
         2     4       7    7    4    3
         3     4       6    8    4    6
  4      1     1       6    2    4    9
         2     6       6    2    4    8
         3    10       5    1    3    8
  5      1     1       6    9    8    9
         2     5       4    9    7    6
         3     7       2    8    7    2
  6      1     5       7   10    4    6
         2     5       7    8    5    5
         3     6       4    3    2    5
  7      1     3       4    8    4    8
         2     3       3    9    4    9
         3     8       3    6    4    5
  8      1     3       9    8    2    7
         2     7       8    7    1    6
         3     9       8    5    1    5
  9      1     5       6    8    7    7
         2     7       3    7    5    5
         3    10       3    7    3    4
 10      1     3       7    9    8    3
         2     3       7    9    7    4
         3     9       3    9    3    3
 11      1     1       6    6   10    8
         2     5       5    5    9    5
         3    10       5    5    9    4
 12      1     5       3    7    4    8
         2     6       2    4    4    7
         3    10       2    1    3    7
 13      1     3       1    6    5    6
         2     6       1    5    3    5
         3     7       1    3    2    4
 14      1     3       1    9    4    6
         2     4       1    6    3    5
         3     7       1    6    2    4
 15      1     3       8    8    6    3
         2     4       8    7    6    2
         3     5       6    5    2    2
 16      1     3       9    7    7    9
         2     5       7    5    5    7
         3     6       7    1    2    2
 17      1     2       9   10    6    4
         2     3       7    7    4    3
         3     9       4    7    4    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   27   75   88
************************************************************************
