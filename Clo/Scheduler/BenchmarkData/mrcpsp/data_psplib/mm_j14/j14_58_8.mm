************************************************************************
file with basedata            : md186_.bas
initial value random generator: 1620102531
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  122
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       26       12       26
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          10  11
   3        3          2           5   9
   4        3          3           5   6  12
   5        3          3           7   8  10
   6        3          3           7   9  15
   7        3          1          11
   8        3          2          11  15
   9        3          2          13  14
  10        3          2          13  15
  11        3          1          14
  12        3          2          13  14
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       0    4    7    6
         2     4       9    0    6    5
         3     5       0    4    6    5
  3      1     1       0    3    8    7
         2     5       6    0    7    4
         3     8       4    0    5    2
  4      1     9       7    0    5    4
         2     9       0    7    5    4
         3    10       7    0    5    1
  5      1     2       0    8    7    5
         2     6       8    0    7    3
         3     9       6    0    7    1
  6      1     1       7    0    5    9
         2     3       3    0    4    8
         3    10       0    6    3    6
  7      1     8       0    7    5    6
         2     9       0    6    4    5
         3    10       5    0    3    5
  8      1     3       0    9    4    5
         2     4       5    0    4    5
         3     8       0    8    4    4
  9      1     1       8    0    5    8
         2     6       0    3    4    6
         3     8       0    3    2    3
 10      1     2       0    5    4    5
         2     6       8    0    3    5
         3     9       0    4    2    4
 11      1     1       0    9    7    9
         2    10       0    9    6    8
         3    10       7    0    2    8
 12      1     2       0    2    9    9
         2     4       9    0    7    9
         3     9       0    2    5    8
 13      1     7       4    0    5    9
         2     8       0    5    4    4
         3     9       3    0    4    1
 14      1     6       7    0   10    7
         2     9       3    0    9    6
         3     9       0    5    9    5
 15      1     4       0    9    8    8
         2     6       0    6    8    8
         3     8       0    5    8    8
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   13   89   97
************************************************************************
