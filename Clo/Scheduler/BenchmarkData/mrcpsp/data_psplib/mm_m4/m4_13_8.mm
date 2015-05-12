************************************************************************
file with basedata            : cm413_.bas
initial value random generator: 1609285493
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  126
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23        7       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        4          2          14  16
   3        4          3           5   8  13
   4        4          3           9  11  14
   5        4          2           6  11
   6        4          2           7  10
   7        4          1           9
   8        4          3           9  10  11
   9        4          2          12  15
  10        4          2          12  14
  11        4          3          12  15  16
  12        4          1          17
  13        4          1          16
  14        4          2          15  17
  15        4          1          18
  16        4          1          18
  17        4          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     4       5    8    0    8
         2     6       5    7    9    0
         3     9       5    7    3    0
         4     9       5    7    0    4
  3      1     7       5    5    5    0
         2     8       5    5    4    0
         3     8       5    4    5    0
         4    10       4    3    0    6
  4      1     2       7    9    7    0
         2     3       7    8    0    4
         3     4       7    8    4    0
         4     6       7    7    2    0
  5      1     1       2    9    5    0
         2     2       2    9    4    0
         3     6       2    8    0    4
         4     7       2    8    4    0
  6      1     1      10    3    9    0
         2     5       7    3    5    0
         3     5       6    3    6    0
         4     7       5    2    1    0
  7      1     3       6    6    0    8
         2     4       5    6    5    0
         3     5       4    4    0    6
         4     6       3    3    0    5
  8      1     6       6    9    0    4
         2     8       5    8    3    0
         3     9       5    7    2    0
         4     9       4    8    2    0
  9      1     4       6    4    0    6
         2     4       5    5    7    0
         3     8       3    3    0    6
         4    10       2    2    5    0
 10      1     1       8    2    8    0
         2     4       7    2    0    4
         3     5       7    2    6    0
         4     6       3    1    5    0
 11      1     1       8    4    0    2
         2     2       8    3    7    0
         3     4       7    3    0    1
         4     8       7    2    0    1
 12      1     1       8   10    9    0
         2     7       7    6    9    0
         3     7       4    7    0    5
         4     8       4    4    9    0
 13      1     1       7    8    9    0
         2     1       5    8    0   10
         3     3       5    7   10    0
         4     7       2    5    0    9
 14      1     3       7    4    0    7
         2     5       4    2    0    6
         3     9       4    1    0    4
         4     9       3    1    5    0
 15      1     4       8    9    0    6
         2     6       8    8    9    0
         3     7       7    7    0    5
         4     7       6    7    6    0
 16      1     2       4    8    0    3
         2     5       3    7    8    0
         3     8       2    4    7    0
         4     9       2    3    5    0
 17      1     5       9    7    9    0
         2     5       9    7    0    6
         3     7       9    6    9    0
         4     8       9    6    8    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   12   13   58   42
************************************************************************
