************************************************************************
file with basedata            : cn342_.bas
initial value random generator: 60017853
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  122
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20        2       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          11  13  16
   3        3          3           7   8  10
   4        3          2           5  11
   5        3          3           6   9  12
   6        3          3           7  10  13
   7        3          3          15  16  17
   8        3          2          13  15
   9        3          2          10  15
  10        3          2          14  16
  11        3          1          12
  12        3          1          17
  13        3          1          14
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     8       5    0    7    8    6
         2     9       0    9    7    8    5
         3     9       2    0    6    8    5
  3      1     5       0    5    8    8    6
         2     9       7    0    4    6    6
         3    10       0    5    1    6    2
  4      1     1       8    0   10    9    6
         2     4       7    0   10    7    6
         3     7       0    3    9    5    6
  5      1     6       6    0    7   10    7
         2     7       4    0    7   10    6
         3     9       1    0    7    9    4
  6      1     1       7    0    6    6    4
         2     8       7    0    5    6    4
         3    10       2    0    5    5    3
  7      1     1       0    8    5    4    4
         2     2       0    4    2    2    4
         3     3       3    0    2    2    4
  8      1     2       3    0    5    8    3
         2     3       0    5    5    5    3
         3    10       3    0    4    3    1
  9      1     4       5    0    9    5    7
         2     6       0    3    6    5    7
         3     6       0    5    5    5    7
 10      1     6       0   10    4   10   10
         2     7       8    0    4   10   10
         3     7       0    9    4   10    9
 11      1     1       0    7    2    5    8
         2     7       5    0    2    5    8
         3     8       4    0    2    3    7
 12      1     4       0    7    4    6    7
         2     6       0    6    4    6    6
         3     7       5    0    4    5    6
 13      1     1       8    0    8    8    5
         2     4       0    2    6    8    4
         3     9       4    0    6    8    3
 14      1     1       6    0    7   10   10
         2     7       0    7    6    8    8
         3     8       0    7    1    7    7
 15      1     4       0    3    8    4   10
         2    10       3    0    6    4    4
         3    10       0    1    6    4    4
 16      1     1      10    0    4    8    6
         2     2      10    0    3    7    6
         3     3       0    5    2    7    5
 17      1     2       0    5   10   10    8
         2     5       0    4   10    9    8
         3     6       1    0   10    9    8
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   13   11   89  108   94
************************************************************************
