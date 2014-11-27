************************************************************************
file with basedata            : md280_.bas
initial value random generator: 944659809
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  126
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       19        6       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  11  13
   3        3          1           8
   4        3          3           5  11  17
   5        3          2           6   7
   6        3          3           9  13  15
   7        3          2          15  19
   8        3          3          15  16  17
   9        3          3          10  14  18
  10        3          2          12  16
  11        3          2          12  14
  12        3          1          19
  13        3          2          14  18
  14        3          1          16
  15        3          1          18
  16        3          1          19
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     6       9    8    0    6
         2     8       7    8    3    0
         3    10       6    7    3    0
  3      1     2       9    4    8    0
         2     4       7    3    0    2
         3     9       4    3    2    0
  4      1     2       2    6    9    0
         2     5       2    5    9    0
         3    10       2    4    0    5
  5      1     3       6    7    0    7
         2     4       5    6    5    0
         3     9       5    3    0    6
  6      1     2       2    7    0    4
         2     4       2    3    0    4
         3     4       2    4    0    2
  7      1     1       5    8    0   10
         2     1       5    9    0    9
         3    10       2    2    0    8
  8      1     5       6    8    0    9
         2     6       6    7    6    0
         3     9       5    7    0    9
  9      1     2       6   10    7    0
         2     4       5    7    4    0
         3     8       5    5    4    0
 10      1     5      10   10    0    3
         2     8       9    5    9    0
         3    10       9    4    0    2
 11      1     2       7    9   10    0
         2     4       3    4   10    0
         3     4       2    6    0    8
 12      1     2       8    5    0    3
         2     2       9    1   10    0
         3     2       5    6    9    0
 13      1     2       9    7    8    0
         2     3       8    7    7    0
         3     9       8    7    0    4
 14      1     2      10    8    0    2
         2     2      10    8    8    0
         3     3       9    8    8    0
 15      1     1       8    7    7    0
         2     4       7    6    0    4
         3     5       7    3    0    1
 16      1     1       4    8    0    8
         2     3       2    7    0    7
         3     9       2    7    8    0
 17      1     2       6    8    0    8
         2     4       5    6    0    8
         3     4       3    5    6    0
 18      1     2       7    1    2    0
         2     3       7    1    0    3
         3     6       7    1    1    0
 19      1     3       9    5    0   10
         2     5       6    3    5    0
         3     5       7    2    5    0
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   36   41   84   75
************************************************************************
