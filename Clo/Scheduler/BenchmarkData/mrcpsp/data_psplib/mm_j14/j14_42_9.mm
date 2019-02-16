************************************************************************
file with basedata            : md170_.bas
initial value random generator: 1599540435
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  111
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       17       10       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   8
   3        3          3           9  10  11
   4        3          2           6  11
   5        3          2          13  15
   6        3          2           7   9
   7        3          3          10  12  15
   8        3          3          10  11  15
   9        3          2          12  14
  10        3          2          13  14
  11        3          1          14
  12        3          1          13
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     4       0    8    7    3
         2     5       0    7    6    2
         3     6       0    7    3    1
  3      1     2       3    0    5    6
         2     8       3    0    4    3
         3     8       0    2    4    4
  4      1     2       6    0    8    4
         2     7       0    7    6    3
         3     8       5    0    2    1
  5      1     1       4    0    4    9
         2     2       4    0    4    8
         3     7       0    5    3    6
  6      1     2       3    0    7    6
         2     2       1    0    8    5
         3     6       0    2    6    5
  7      1     3       0    4   10    4
         2     5       0    4    4    3
         3     5       0    4    1    4
  8      1     7       0    4    8    5
         2    10       0    2    2    4
         3    10       4    0    4    5
  9      1     1       5    0    4    8
         2     8       5    0    3    6
         3     9       0    4    2    5
 10      1     3       7    0    6    7
         2     3       0    3    6    5
         3     6       7    0    6    5
 11      1     5       0    4    7    6
         2     9       9    0    5    5
         3    10       5    0    4    5
 12      1     3       6    0    3    8
         2     7       0    9    2    7
         3     9       0    7    2    4
 13      1     1       0    9    8    1
         2     3       4    0    6    1
         3    10       0    7    5    1
 14      1     1       0    5    9    7
         2     5       8    0    7    7
         3     8       6    0    7    6
 15      1     6       0    8    8    8
         2     9       0    8    6    5
         3     9       0    8    7    4
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
    8   13   74   68
************************************************************************
