************************************************************************
file with basedata            : cn126_.bas
initial value random generator: 491865623
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  144
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       30        8       30
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   8
   3        3          3           6   9  13
   4        3          2          12  13
   5        3          3          11  14  16
   6        3          2           7  16
   7        3          2          12  17
   8        3          2           9  10
   9        3          1          14
  10        3          3          11  14  16
  11        3          1          13
  12        3          1          15
  13        3          2          15  17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     6       7    0    7
         2     9       0    9    0
         3     9       5    0    7
  3      1     5       0    7    0
         2     7      10    0    7
         3     7       0    2    5
  4      1     2       8    0    3
         2     6       0    7    0
         3    10       3    0    3
  5      1     1       0    3    7
         2     8       0    2    0
         3    10       3    0    0
  6      1     2       0    5    7
         2     5       0    4    4
         3     8       5    0    0
  7      1     6       0    8    3
         2     8       0    5    0
         3     9       0    3    2
  8      1     3       6    0    6
         2     7       5    0    0
         3     7       0    4    2
  9      1     2      10    0    0
         2     4       0    2    0
         3    10       9    0    7
 10      1     4       0    6    6
         2     7       0    3    0
         3     9       4    0    3
 11      1     1       7    0    0
         2     2       5    0    0
         3     7       0    7    0
 12      1     8       0    7    5
         2    10       0    7    0
         3    10       6    0    0
 13      1     3       9    0    9
         2     3       8    0   10
         3    10       0    4    0
 14      1     7       8    0    6
         2     7       0    6    0
         3     9       8    0    0
 15      1     8       0    1    0
         2     9       7    0    4
         3    10       3    0    0
 16      1     2       3    0    4
         2     4       0    7    0
         3    10       0    6    0
 17      1     3       0    7    8
         2     9       4    0    7
         3     9       5    0    0
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   13   15   90
************************************************************************
