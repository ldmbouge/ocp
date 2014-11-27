************************************************************************
file with basedata            : cn160_.bas
initial value random generator: 813062795
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  128
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        2       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          15  17
   3        3          3           6   7   8
   4        3          3           5   7   9
   5        3          2           6   8
   6        3          1          11
   7        3          3          10  11  12
   8        3          3          10  12  16
   9        3          3          13  14  15
  10        3          2          14  15
  11        3          2          13  17
  12        3          1          14
  13        3          1          16
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     2       2    0    8
         2     4       2    0    5
         3     5       0    5    5
  3      1     3       0    5    5
         2     9       0    3    3
         3     9       5    0    3
  4      1     1       0    3    8
         2     8       0    1    7
         3     8       0    3    6
  5      1     1       0    6    7
         2     3       9    0    7
         3     5       5    0    6
  6      1     1       0    8    3
         2     7       8    0    2
         3    10       6    0    1
  7      1     2       7    0   10
         2     6       0    4    8
         3     8       0    3    8
  8      1     2       0    7    2
         2     5       4    0    2
         3     6       0    6    1
  9      1     3       3    0    8
         2     4       0    9    7
         3     9       2    0    4
 10      1     8       9    0    6
         2     8       0    8    6
         3    10       0    6    5
 11      1     2       8    0    3
         2     4       6    0    2
         3     9       0    1    2
 12      1     3       8    0    7
         2     8       7    0    5
         3     9       3    0    3
 13      1     2      10    0    8
         2     7       0   10    4
         3    10       0    8    1
 14      1     3       0    4    7
         2     3       8    0    8
         3     8       0    4    4
 15      1     5       0    5    8
         2     8       5    0    7
         3    10       0    5    6
 16      1     2       0    8    4
         2     3       2    0    2
         3     9       0    6    1
 17      1     1       0   10    8
         2     2       6    0    7
         3     3       3    0    7
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   25   33  103
************************************************************************
