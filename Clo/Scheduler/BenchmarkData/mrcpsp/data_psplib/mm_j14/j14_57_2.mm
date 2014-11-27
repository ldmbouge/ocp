************************************************************************
file with basedata            : md185_.bas
initial value random generator: 573121379
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  113
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       22        3       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   9
   3        3          3           7   8  10
   4        3          2           6  12
   5        3          2           8  11
   6        3          2          10  14
   7        3          1          11
   8        3          3          12  13  15
   9        3          1          11
  10        3          2          13  15
  11        3          3          13  14  15
  12        3          1          14
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       0    7   10    9
         2     7       6    0    9    7
         3     9       4    0    9    7
  3      1     1       2    0   10    5
         2     5       0    4    9    5
         3     7       2    0    9    4
  4      1     1       7    0    9    2
         2     3       4    0    4    2
         3     6       0    8    4    2
  5      1     4       3    0    6    9
         2     4       0    9    6    7
         3    10       0    8    6    4
  6      1     2       9    0    5    9
         2     7       0    9    5    8
         3    10       6    0    2    8
  7      1     1       0    5    9    3
         2     5       6    0    7    3
         3     5       7    0    6    3
  8      1     6       0    8    8    7
         2     6       9    0    8    8
         3     7       9    0    5    4
  9      1     4       0    6    9    9
         2     5       0    4    9    9
         3     8       8    0    8    7
 10      1     8       0    5   10    9
         2     8       7    0   10    8
         3    10       0    6   10    6
 11      1     1       0    9    7    5
         2     1       7    0    7    7
         3     5       4    0    4    3
 12      1     3       8    0    8    6
         2     6       0    6    8    6
         3     7       3    0    7    2
 13      1     4      10    0    5    8
         2     5       8    0    4    7
         3    10       5    0    4    7
 14      1     4       0   10    8    5
         2     5       0   10    6    5
         3     9       0   10    5    3
 15      1     2       0    8    8   10
         2     8       4    0    7    6
         3    10       0    7    6    4
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   10   15  112   99
************************************************************************
