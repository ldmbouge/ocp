************************************************************************
file with basedata            : me28_.bas
initial value random generator: 1854879863
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        8       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7   8
   3        3          2           6  12
   4        3          3           5   6  11
   5        3          2          12  15
   6        3          2           9  10
   7        3          3           9  10  13
   8        3          2          10  16
   9        3          2          14  15
  10        3          2          14  15
  11        3          1          13
  12        3          2          16  17
  13        3          2          16  17
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
  2      1     1       0    3
         2     2      10    0
         3     8       6    0
  3      1     1       4    0
         2     4       0    4
         3     7       0    3
  4      1     1       0    7
         2     6       9    0
         3     6       0    6
  5      1     2       6    0
         2     4       2    0
         3     7       0    5
  6      1     8       6    0
         2     9       5    0
         3    10       0    5
  7      1     1       0    9
         2     3       2    0
         3     8       0    8
  8      1     5       9    0
         2     7       0    3
         3    10       0    1
  9      1     2       0    4
         2     4       8    0
         3     6       0    2
 10      1     3       0    7
         2     3       8    0
         3     6       7    0
 11      1     7       9    0
         2     7       0    3
         3    10       0    2
 12      1     4       4    0
         2     5       0    7
         3     8       0    3
 13      1     3       0    8
         2     9       4    0
         3    10       0    6
 14      1     1       0    7
         2     8       9    0
         3     9       6    0
 15      1     6       8    0
         2     9       0    1
         3    10       7    0
 16      1     2       6    0
         2     6       5    0
         3     8       0    8
 17      1     2       0    8
         2     6       0    6
         3     7       0    4
 18      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   30   24
************************************************************************
