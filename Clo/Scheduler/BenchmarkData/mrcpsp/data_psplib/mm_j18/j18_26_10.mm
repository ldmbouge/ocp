************************************************************************
file with basedata            : md282_.bas
initial value random generator: 555914326
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  131
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       17        7       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   9  17
   3        3          3           5   6  12
   4        3          3           5   7  13
   5        3          1          14
   6        3          3           8  16  18
   7        3          3          10  11  12
   8        3          2          10  13
   9        3          2          14  18
  10        3          2          14  17
  11        3          1          15
  12        3          2          15  19
  13        3          1          19
  14        3          1          19
  15        3          2          16  18
  16        3          1          17
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       6    0    7    0
         2     6       0    4    7    0
         3     7       4    0    7    0
  3      1     4       5    0    6    0
         2     4       0   10    7    0
         3     6       5    0    0    6
  4      1     5      10    0    0    6
         2    10       6    0    0    4
         3    10       0    4    0    3
  5      1     2       0    3    0    9
         2     5       6    0    0    6
         3     6       0    3    1    0
  6      1     3       0    9    9    0
         2     7       0    3    7    0
         3     9       9    0    6    0
  7      1     1       0    9    7    0
         2     2       0    8    5    0
         3     8       7    0    0   10
  8      1     1       7    0    6    0
         2     2       6    0    0    2
         3     6       0    4    5    0
  9      1     1       2    0    7    0
         2     5       0    7    7    0
         3     6       0    6    0    1
 10      1     2       5    0    0   10
         2     6       0    8    0    9
         3     9       1    0    0    8
 11      1     3       0    7    0    7
         2     4       0    7    0    6
         3     7       6    0    4    0
 12      1     1       5    0    0    5
         2     4       0    8   10    0
         3     5       3    0    0    4
 13      1     1       0    2    0    7
         2     2       0    1    5    0
         3     9       3    0    5    0
 14      1     1       6    0    5    0
         2     1       0    8    0    3
         3     6       0    4    6    0
 15      1     1       0   10    9    0
         2     4       7    0    0    6
         3    10       5    0    0    2
 16      1     5       3    0    0    7
         2     8       0   10    0    5
         3     9       0   10    0    4
 17      1     2       0   10    9    0
         2     3       0    9    8    0
         3     5       6    0    0    5
 18      1     3       0    7    0    5
         2     4       0    6    8    0
         3     4       5    0    0    4
 19      1     1       0    5    0    3
         2     8       0    5    6    0
         3     9       7    0    4    0
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   11   13  101   92
************************************************************************
