************************************************************************
file with basedata            : me35_.bas
initial value random generator: 575239860
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  133
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       16       13       16
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   8
   3        3          3           7   9  17
   4        3          2           5  15
   5        3          3           9  13  16
   6        3          3          10  11  12
   7        3          2          10  13
   8        3          1          17
   9        3          2          12  19
  10        3          1          15
  11        3          2          14  15
  12        3          1          18
  13        3          2          18  19
  14        3          2          16  17
  15        3          2          16  19
  16        3          1          18
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     4      10    0
         2     7       0    9
         3     7       8    0
  3      1     1       0    8
         2     2       4    0
         3     4       0    7
  4      1     1       9    0
         2     6       2    0
         3     8       0    2
  5      1     4       0    3
         2     5       0    2
         3    10       4    0
  6      1     3       0    6
         2     7       3    0
         3    10       0    5
  7      1     4       0    6
         2     4       4    0
         3     8       2    0
  8      1     3       0    8
         2     4       0    4
         3     7       9    0
  9      1     1       0    7
         2     3       7    0
         3     3       0    6
 10      1     1       4    0
         2     9       3    0
         3    10       2    0
 11      1     1       4    0
         2     2       3    0
         3     8       2    0
 12      1     2       0    9
         2     8       1    0
         3     9       0    5
 13      1     4       8    0
         2     7       7    0
         3    10       0    7
 14      1     3       4    0
         2     7       0    6
         3     7       3    0
 15      1     2      10    0
         2     3       5    0
         3     4       4    0
 16      1     2       5    0
         2     4       0    9
         3     5       0    3
 17      1     5       0    6
         2     8       0    4
         3     8      10    0
 18      1     1       0    1
         2     4       8    0
         3     5       7    0
 19      1     4       0    8
         2     8       6    0
         3    10       3    0
 20      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   24   17
************************************************************************
