************************************************************************
file with basedata            : me32_.bas
initial value random generator: 122323567
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  138
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       29        4       29
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   9
   3        3          3           8  16  17
   4        3          3           8   9  17
   5        3          3          10  11  12
   6        3          3           7  10  12
   7        3          2           8  11
   8        3          1          15
   9        3          1          11
  10        3          1          13
  11        3          2          15  16
  12        3          2          13  15
  13        3          2          14  16
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
  2      1     1       6    4
         2     5       6    3
         3     7       5    1
  3      1     2       8    6
         2     4       6    5
         3     9       4    2
  4      1     1       9    3
         2     6       8    3
         3     7       6    2
  5      1     6       8    8
         2     9       8    7
         3    10       4    4
  6      1     4       8   10
         2     7       7   10
         3    10       5    9
  7      1     2       3    8
         2     7       2    6
         3    10       2    5
  8      1     4       7    3
         2     7       5    2
         3    10       4    2
  9      1     3       7    2
         2     4       5    2
         3     8       4    2
 10      1     4       6    2
         2     7       5    1
         3     8       3    1
 11      1     1      10    5
         2     5       7    3
         3    10       5    1
 12      1     8       8    2
         2     9       7    1
         3     9       5    2
 13      1     3       9    6
         2     6       8    5
         3     9       6    2
 14      1     7       8    8
         2     7       6    9
         3    10       5    7
 15      1     2       6    5
         2     2       5    6
         3     6       2    4
 16      1     2       5   10
         2     4       4    8
         3     5       3    8
 17      1     4       4    6
         2     8       4    3
         3    10       3    3
 18      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   31   26
************************************************************************
