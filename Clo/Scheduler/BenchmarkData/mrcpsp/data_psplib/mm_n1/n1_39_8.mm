************************************************************************
file with basedata            : cn139_.bas
initial value random generator: 1003937130
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       15        9       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7  13
   3        3          3           5   9  12
   4        3          3           6   7  11
   5        3          3           6   8  16
   6        3          1          17
   7        3          2          10  14
   8        3          3          10  13  15
   9        3          3          10  11  13
  10        3          1          17
  11        3          1          16
  12        3          1          15
  13        3          1          17
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       7    5    6
         2     4       6    3    6
         3     6       1    2    3
  3      1     5       6    8   10
         2     8       5    8   10
         3     9       5    3    9
  4      1     5       4    2    4
         2     9       3    1    2
         3    10       2    1    1
  5      1     1       9    5    6
         2     1      10    8    5
         3     9       6    2    1
  6      1     2       9    4    9
         2     6       7    4    9
         3     7       7    4    8
  7      1     3       9    9    8
         2     4       8    8    8
         3    10       8    6    6
  8      1     3       3    9    4
         2     5       2    9    4
         3     7       1    8    4
  9      1     2       9    7    9
         2     4       6    6    6
         3    10       5    6    4
 10      1     5       5    4   10
         2     6       4    3    6
         3     9       4    3    5
 11      1     1      10   10    8
         2     8       7    9    8
         3     9       7    7    7
 12      1     1       7    3    9
         2     4       5    2    7
         3     6       4    2    5
 13      1     1       6    7    6
         2     3       6    6    6
         3     6       4    4    3
 14      1     1       9    8    9
         2     2       6    7    6
         3    10       4    6    4
 15      1     2       6    8   10
         2     2       6    9    8
         3    10       6    6    7
 16      1     3       6    8    5
         2     4       5    7    5
         3     5       3    5    4
 17      1     1       8   10    9
         2     1       9    9    7
         3    10       7    7    5
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   28   26   88
************************************************************************
