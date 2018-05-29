************************************************************************
file with basedata            : md222_.bas
initial value random generator: 498175800
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  113
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       15       13       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   8  10
   3        3          3           5   8   9
   4        3          2           8  12
   5        3          3           7  11  14
   6        3          1          16
   7        3          3          10  16  17
   8        3          3          11  13  14
   9        3          2          13  14
  10        3          1          13
  11        3          2          16  17
  12        3          1          15
  13        3          1          15
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       4    7    4    0
         2     5       3    4    2    0
         3     5       3    4    0    4
  3      1     1       9    9    0    4
         2     7       9    8    0    4
         3     9       8    8    0    3
  4      1     1      10    4    0    7
         2     4      10    4    7    0
         3     6      10    4    5    0
  5      1     2      10    9    5    0
         2     4       7    9    3    0
         3     4       9    8    5    0
  6      1     2       5    8    5    0
         2     4       5    6    0    7
         3     7       4    5    1    0
  7      1     2       5    8    0    4
         2     4       1    7    0    4
         3     4       3    7    4    0
  8      1     1      10    7   10    0
         2     1      10    7    0    7
         3     2       5    5   10    0
  9      1     2       6    6    0    4
         2     7       4    6    0    4
         3    10       4    4    9    0
 10      1     5       9    7    6    0
         2     6       8    7    4    0
         3     9       8    4    0    4
 11      1     2       5    5    0    5
         2     8       5    4    0    2
         3     9       5    2   10    0
 12      1     2       9    7    0    5
         2     6       6    7    0    3
         3     9       5    6    3    0
 13      1     1       9    5    0    3
         2     3       6    4    0    2
         3     8       5    2    3    0
 14      1     5       5    5   10    0
         2     7       4    5    5    0
         3     8       3    5    3    0
 15      1     4       5    5    7    0
         2     8       4    4    5    0
         3    10       4    3    0    7
 16      1     3       8    8    6    0
         2     5       4    5    6    0
         3     7       4    5    0    9
 17      1     5      10    8    6    0
         2     5      10   10    0    7
         3     6      10    5    6    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   25   23   95   77
************************************************************************
