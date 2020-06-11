************************************************************************
file with basedata            : md186_.bas
initial value random generator: 54100564
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  105
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       23        1       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1          14
   3        3          3           5   6  11
   4        3          2           5   8
   5        3          1           9
   6        3          3           7   8  10
   7        3          3           9  12  15
   8        3          2           9  12
   9        3          1          13
  10        3          2          12  15
  11        3          3          13  14  15
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
  2      1     1       6    0    8    4
         2     7       0    6    6    2
         3     9       4    0    2    2
  3      1     7       0   10    4    3
         2     7       7    0    4    3
         3     9       1    0    3    3
  4      1     3      10    0    6    4
         2     3       0    7    6    4
         3     3       0    9    4    4
  5      1     1       0    8    9    3
         2     7       0    7    6    2
         3     8       8    0    6    2
  6      1     1       0    6    2    8
         2     1       5    0    2    9
         3     2       4    0    2    5
  7      1     7       0    4    4   10
         2     7       2    0    4    9
         3     9       0    4    1    7
  8      1     9       7    0    7    7
         2    10       5    0    6    4
         3    10       0    8    6    3
  9      1     4       0    4    4    9
         2     8       7    0    3    8
         3    10       4    0    3    8
 10      1     1       8    0    7    7
         2     2       4    0    6    7
         3     7       0    3    4    6
 11      1     3       0    8    5    4
         2     4       0    7    5    4
         3     6       8    0    4    2
 12      1     1       4    0    7    8
         2     2       0    9    5    7
         3     7       0    4    5    6
 13      1     2       0    7   10    7
         2    10       5    0    8    3
         3    10       0    4    9    3
 14      1     4       0    8    7    8
         2     5       0    8    7    7
         3     9       4    0    3    5
 15      1     2       7    0    9    7
         2     3       0   10    9    6
         3     6       7    0    9    6
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   13   89   90
************************************************************************
