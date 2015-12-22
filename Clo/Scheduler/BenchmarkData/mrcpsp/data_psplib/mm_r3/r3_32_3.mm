************************************************************************
file with basedata            : cr332_.bas
initial value random generator: 2010883238
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  112
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20       15       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           9  13
   3        3          3           7  11  13
   4        3          3           5   6   8
   5        3          3           9  10  11
   6        3          2          10  17
   7        3          2          16  17
   8        3          2          11  14
   9        3          2          15  16
  10        3          2          12  13
  11        3          3          12  15  17
  12        3          1          16
  13        3          1          14
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     1       9    9    5    7    0
         2     2       6    7    5    0    4
         3     2       2    7    4    7    0
  3      1     2       7    9    4    0    7
         2     6       7    8    2    0    6
         3     9       4    8    1    3    0
  4      1     7       7    4    3    0    5
         2     7       6    4    4    5    0
         3    10       4    4    3    5    0
  5      1     1       7    6    9    0    9
         2     2       6    6    8    3    0
         3     7       5    6    7    0    1
  6      1     3       8   10    5    0    8
         2     5       7    7    5    9    0
         3     7       3    5    4    7    0
  7      1     1       8    6   10    9    0
         2     3       7    4   10    6    0
         3     8       4    3   10    0    2
  8      1     1       6    6    6   10    0
         2     1       7    7    6    0    5
         3     8       3    4    5    9    0
  9      1     3       8    5   10    9    0
         2     5       6    5    7    5    0
         3     9       3    4    6    0    1
 10      1     1       7    4    7    4    0
         2     2       5    4    5    0    8
         3     2       5    4    6    0    5
 11      1     3       5    8    6    0    8
         2     7       4    8    6    0    4
         3     9       4    8    5    4    0
 12      1     1       7    6   10    5    0
         2     4       5    6    5    1    0
         3     5       4    6    3    0    1
 13      1     2       2    7   10    0    5
         2     2       2    6    8    8    0
         3     6       2    4    4    0    5
 14      1     2       8    4    8    0   10
         2     4       6    3    4    0    8
         3     5       1    3    2    0    6
 15      1     1       2   10    8    0    7
         2     3       2    5    7    7    0
         3     6       1    4    3    6    0
 16      1     8       3   10    2    0    3
         2     8       3    9    2    0    4
         3    10       1    3    1    0    2
 17      1     2       8    3    4    3    0
         2     5       7    3    4    0    6
         3     9       5    3    3    0    4
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   23   23   24   86   90
************************************************************************
