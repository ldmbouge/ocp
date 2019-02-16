************************************************************************
file with basedata            : md220_.bas
initial value random generator: 572361673
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       24        5       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           8  11  15
   3        3          3           9  10  14
   4        3          3           5   7   8
   5        3          3           6  12  14
   6        3          3           9  13  16
   7        3          2          10  15
   8        3          2          14  17
   9        3          2          15  17
  10        3          1          11
  11        3          2          12  16
  12        3          1          13
  13        3          1          17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       2    0    5    0
         2     4       2    0    1    0
         3     7       0    3    0    8
  3      1     1      10    0    8    0
         2     8       0    2    0    5
         3     8       3    0    6    0
  4      1     4       3    0    0    9
         2     8       0    7    0    8
         3     9       0    1   10    0
  5      1     7       0    5    0    5
         2     8      10    0    0    5
         3     9       9    0    7    0
  6      1     1       9    0   10    0
         2     7       8    0    0    7
         3     8       0    3    5    0
  7      1     3       3    0    6    0
         2     8       0    7    0    3
         3     9       0    6    2    0
  8      1     2       6    0    0    3
         2     5       0    8    0    3
         3     6       0    8    0    2
  9      1     2       7    0    0    8
         2     3       0    9    0    7
         3     9       7    0    8    0
 10      1     7       8    0    7    0
         2     8       4    0    7    0
         3     9       2    0    6    0
 11      1     1       9    0    5    0
         2     5       0   10    0    2
         3     6       8    0    4    0
 12      1     3       5    0    7    0
         2     3       5    0    0    2
         3     9       3    0    6    0
 13      1     1       0   10    8    0
         2     3       3    0    5    0
         3     7       0    9    0    1
 14      1     3       0    9    8    0
         2     8       0    5    0    4
         3    10       0    4    5    0
 15      1     2       7    0    0    8
         2     5       5    0    0    1
         3     9       5    0    5    0
 16      1     9       9    0    0    6
         2     9       0    7    9    0
         3    10       7    0    7    0
 17      1     1       0    6    4    0
         2     6       5    0    0    8
         3     8       4    0    0    8
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   21   20  107   79
************************************************************************
