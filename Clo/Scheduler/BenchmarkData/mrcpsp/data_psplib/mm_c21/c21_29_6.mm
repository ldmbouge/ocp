************************************************************************
file with basedata            : c2129_.bas
initial value random generator: 1059581217
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
    1     16      0       23       13       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   8
   3        3          3           6  11  12
   4        3          3           6   7   8
   5        3          3           7   9  10
   6        3          2           9  13
   7        3          3          13  14  17
   8        3          3           9  10  12
   9        3          2          14  16
  10        3          2          11  13
  11        3          3          14  16  17
  12        3          2          15  17
  13        3          2          15  16
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       3    7    0    5
         2     5       3    6    7    0
         3     9       2    4    5    0
  3      1     7      10    7    9    0
         2     8      10    5    8    0
         3    10       9    4    8    0
  4      1     2       6    3   10    0
         2     5       4    3    0    4
         3     6       4    3    0    3
  5      1     4       7    7    8    0
         2     4       7    7    0    8
         3     9       5    7    0    8
  6      1     5       8    6    0    9
         2     5       9    7    9    0
         3     7       4    3    1    0
  7      1     5       5    5    3    0
         2     9       4    4    2    0
         3     9       2    4    0    2
  8      1     2       5    8    0    6
         2     5       4    5    1    0
         3     5       5    3    2    0
  9      1     3       3    8    0    9
         2     7       2    6   10    0
         3     8       2    4    4    0
 10      1     1       3    5    3    0
         2     1       3    6    0    7
         3     4       3    2    0    4
 11      1     4       5    1    0    7
         2     4       5    1    6    0
         3     5       3    1    3    0
 12      1     4       6    1    8    0
         2     5       5    1    0    5
         3    10       4    1    2    0
 13      1     5       9    8    9    0
         2     9       8    7    4    0
         3    10       8    2    0    5
 14      1     1      10    5    4    0
         2     6       9    5    3    0
         3     8       9    4    1    0
 15      1     6       4    7    0    5
         2     9       3    5    0    2
         3     9       4    7    1    0
 16      1     1       8    5    4    0
         2     1      10    7    3    0
         3     8       5    3    0    6
 17      1     2       7    3    0    4
         2     5       7    3    0    2
         3     9       6    2    9    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   11  102   82
************************************************************************
