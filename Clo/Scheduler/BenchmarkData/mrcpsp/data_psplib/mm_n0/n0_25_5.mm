************************************************************************
file with basedata            : me25_.bas
initial value random generator: 1072868480
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  118
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       14        8       14
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           6   7
   3        3          1           8
   4        3          3           5   8   9
   5        3          3           6  10  12
   6        3          2          16  17
   7        3          3           9  11  12
   8        3          2          15  17
   9        3          3          13  15  16
  10        3          2          11  13
  11        3          3          14  15  16
  12        3          1          13
  13        3          1          14
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     4       0    6
         2     6       3    0
         3    10       0    2
  3      1     6       0    6
         2     7       6    0
         3     9       3    0
  4      1     3       0    7
         2     4       0    5
         3     6       0    3
  5      1     1       5    0
         2     8       0   10
         3     9       4    0
  6      1     7       0    3
         2     7      10    0
         3     9       9    0
  7      1     2       8    0
         2     3       7    0
         3     7       6    0
  8      1     3       0    9
         2     4       4    0
         3     7       0    6
  9      1     3       0    8
         2     4       0    4
         3     8       0    2
 10      1     1       0    8
         2     4       0    5
         3     7      10    0
 11      1     6       0    4
         2     8       8    0
         3    10       7    0
 12      1     3       3    0
         2     5       0    8
         3     6       2    0
 13      1     3       0    5
         2     6       0    3
         3     9       6    0
 14      1     1       0    8
         2     3       0    6
         3     8       0    5
 15      1     1       4    0
         2     2       3    0
         3     3       0    1
 16      1     1       0    4
         2     2       0    3
         3     7       8    0
 17      1     1       0   10
         2     3       8    0
         3     3       0    9
 18      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   13   11
************************************************************************
