************************************************************************
file with basedata            : md160_.bas
initial value random generator: 2034002367
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  124
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       24       12       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5  10
   3        3          3           6   8  13
   4        3          3           8   9  10
   5        3          2           7  12
   6        3          1          10
   7        3          2           8   9
   8        3          1          11
   9        3          3          13  14  15
  10        3          2          11  12
  11        3          2          14  15
  12        3          2          14  15
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     4       4    9    7    0
         2     8       2    6    0    4
         3    10       2    6    5    0
  3      1     3       2    7    0    5
         2     7       2    6    0    3
         3     9       2    5    2    0
  4      1     1       6    5    0    9
         2     9       5    4    0    8
         3    10       3    1    0    8
  5      1     3       9    9    7    0
         2     4       5    9    6    0
         3     6       1    9    3    0
  6      1     2       8    7    4    0
         2     7       6    7    0    5
         3     9       6    7    4    0
  7      1     2       9    2    0    8
         2     6       6    2    3    0
         3     9       1    1    0    3
  8      1     3       4    8    0    9
         2     4       4    6    8    0
         3     9       4    5    6    0
  9      1     6       7   10    0    5
         2     9       5    9    0    5
         3     9       5   10    2    0
 10      1     1       3    5    0    7
         2     1       4    5    5    0
         3     9       1    2    3    0
 11      1     2       4    6   10    0
         2     6       3    5    0    7
         3    10       3    5   10    0
 12      1     1       8    5    8    0
         2     7       7    4    8    0
         3    10       7    2    7    0
 13      1     9       8    4    7    0
         2     9       9    4    0    3
         3    10       6    4    0    1
 14      1     7       9    7    9    0
         2     7       9    9    0    6
         3     8       8    7    0    2
 15      1     2       9    4    2    0
         2     2       9    4    0    6
         3     6       9    3    0    6
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   27   21   74   74
************************************************************************
