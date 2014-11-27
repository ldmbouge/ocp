************************************************************************
file with basedata            : cm228_.bas
initial value random generator: 19386
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  121
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       36        2       36
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          3           8  13  14
   3        2          1           5
   4        2          3           6   8  14
   5        2          2           6  14
   6        2          3           7   9  17
   7        2          2          10  13
   8        2          3          12  15  17
   9        2          3          10  11  12
  10        2          1          15
  11        2          2          13  15
  12        2          1          16
  13        2          1          16
  14        2          2          16  17
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       2    0    0    5
         2     9       2    0    8    0
  3      1     5       0    3    3    0
         2     6       4    0    3    0
  4      1     3       0    7    5    0
         2     5       0    6    0    2
  5      1     3       3    0    0    4
         2    10       3    0    0    3
  6      1     4       0    1    0    6
         2     9       2    0    0    5
  7      1     5       0    3    0    5
         2    10       5    0    0    4
  8      1     1       6    0    0    8
         2     9       6    0    0    5
  9      1     3       7    0    0    5
         2     6       0    5    0    4
 10      1    10       4    0    0    8
         2    10       0    5    7    0
 11      1     2       4    0    2    0
         2     7       4    0    0    6
 12      1     3       0   10    0    8
         2     8       7    0    0    5
 13      1     1       0    7    9    0
         2     8       0    6    8    0
 14      1     4       0    8    0    8
         2     6       3    0    5    0
 15      1     9       0    7    1    0
         2    10       8    0    0    9
 16      1     3       0    6    0    7
         2     3      10    0    0    7
 17      1     4       6    0    0    7
         2     5       0   10    0    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   22   22   40   88
************************************************************************
