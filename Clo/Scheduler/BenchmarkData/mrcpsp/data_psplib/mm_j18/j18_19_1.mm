************************************************************************
file with basedata            : md275_.bas
initial value random generator: 12803
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
    1     18      0       20        0       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5  10  15
   3        3          3           6   8  11
   4        3          2          15  16
   5        3          1           7
   6        3          2           9  19
   7        3          2          12  17
   8        3          2          13  14
   9        3          3          13  16  17
  10        3          2          12  13
  11        3          3          14  15  17
  12        3          2          14  16
  13        3          1          18
  14        3          1          19
  15        3          2          18  19
  16        3          1          18
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       0    9    0    8
         2     6       0    8    0    7
         3     9       3    0    6    0
  3      1     1       0    9    0    5
         2     7       0    9    7    0
         3     9       0    9    5    0
  4      1     6       6    0    5    0
         2     8       1    0    5    0
         3     8       0    3    3    0
  5      1     1       0    7    0    9
         2     8       0    6    3    0
         3     8       2    0    0    9
  6      1     3       0    9    0    7
         2     4       0    8    9    0
         3     5       0    6    0    5
  7      1     1       0    5    9    0
         2     2      10    0    8    0
         3     4       1    0    7    0
  8      1     2       9    0    4    0
         2     5       8    0    0    8
         3     7       0    8    3    0
  9      1     4       0    6    0    4
         2     4       7    0    0    8
         3     7       0    6    6    0
 10      1     5       8    0    0   10
         2     6       6    0    0   10
         3     9       5    0    4    0
 11      1     3       0    8    7    0
         2     4       3    0    7    0
         3     6       0    7    0    9
 12      1     4       9    0    0    4
         2     6       9    0    0    3
         3    10       0    6    0    3
 13      1     3       0    9    0    7
         2     4       0    5    9    0
         3     7       0    4    8    0
 14      1     7       0    3    8    0
         2     8       5    0    0    9
         3     9       5    0    3    0
 15      1     3       0    4    0    9
         2     5       0    1    6    0
         3     5       7    0    5    0
 16      1     4       6    0    0    6
         2     6       0    5    0    3
         3    10       6    0    3    0
 17      1     3       0    9    0    6
         2     3       0    5    3    0
         3     7       0    3    1    0
 18      1     2       0   10    0    3
         2     5       9    0    9    0
         3     7       5    0    5    0
 19      1     3       0    6    7    0
         2     3       8    0    0   10
         3     4       0    6    0   10
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   29   81   89
************************************************************************
