************************************************************************
file with basedata            : cr330_.bas
initial value random generator: 426036891
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       24        4       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   9  12
   3        3          3           8  15  16
   4        3          1           5
   5        3          3           6   7  11
   6        3          3          13  15  17
   7        3          2          10  12
   8        3          1          11
   9        3          3          10  11  13
  10        3          2          16  17
  11        3          1          14
  12        3          3          13  14  15
  13        3          1          16
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     4       2    6    4    9    0
         2     5       2    5    4    8    0
         3     9       1    5    4    5    0
  3      1     3       8    9   10    8    0
         2     5       8    7    7    8    0
         3     6       5    1    5    8    0
  4      1     4       7    5   10    6    0
         2     6       7    4   10    4    0
         3    10       7    3    9    2    0
  5      1     1       8    9    7    0    6
         2     2       6    8    7    0    3
         3     6       6    8    6   10    0
  6      1     2       4    6    6   10    0
         2     3       4    5    5    0    9
         3     5       4    3    4    6    0
  7      1     7       7    8    6    0    6
         2     7      10    8    7    6    0
         3     9       1    8    5    3    0
  8      1     2       9    4    9    0    6
         2     5       5    4    9    0    5
         3     9       5    3    7    9    0
  9      1     3       6    9    7    7    0
         2     6       5    8    5    4    0
         3     8       5    8    5    1    0
 10      1     2       8    8    2    0    6
         2     5       7    8    1    5    0
         3     8       1    5    1    3    0
 11      1     1       3    3    3    7    0
         2     6       2    2    3    0    7
         3     8       2    1    1    5    0
 12      1     4       2   10    3    0    9
         2     5       2    7    2    0    9
         3     6       1    6    1    4    0
 13      1     5      10    5    9    8    0
         2     6      10    3    8    5    0
         3     9      10    2    8    5    0
 14      1     3       8    9    8    6    0
         2     6       8    7    6    0    3
         3    10       7    4    5    5    0
 15      1     6      10    6    8    0    4
         2     9       8    6    2    0    4
         3     9       9    5    5    0    4
 16      1     1      10    5    9    0    8
         2     4       9    5    8    6    0
         3    10       8    4    8    4    0
 17      1     5       7    5    8    4    0
         2     5       9    6    8    0    6
         3     8       7    4    8    0    2
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   20   16   17  105   70
************************************************************************
