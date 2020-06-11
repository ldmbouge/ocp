************************************************************************
file with basedata            : cr355_.bas
initial value random generator: 526693928
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
    1     16      0       27        2       27
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           9  10  12
   3        3          2          13  14
   4        3          3           5   9  14
   5        3          2           6   7
   6        3          1          17
   7        3          2           8  10
   8        3          2          11  13
   9        3          2          11  13
  10        3          2          11  16
  11        3          2          15  17
  12        3          2          14  15
  13        3          2          15  16
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     3       7    4    5   10    6
         2     4       6    4    5   10    5
         3     9       3    3    4   10    4
  3      1     2       7    3    8   10    8
         2     3       7    3    6    8    6
         3     7       7    2    5    6    4
  4      1     4       3    7    8    6    9
         2     5       3    7    8    4    8
         3    10       2    7    8    4    5
  5      1     6       7    7    9    6    7
         2     7       6    3    6    5    6
         3     8       5    3    3    3    3
  6      1     2      10    9    8    9    4
         2     4       8    7    7    8    3
         3     7       8    6    4    8    3
  7      1     4       7   10    7    6    2
         2     5       7    8    5    3    2
         3     9       5    8    4    1    1
  8      1     2       1    4    9   10    5
         2     2       1    5    8   10    5
         3     5       1    2    6    6    1
  9      1     1      10    5    5    9    7
         2     4       9    5    5    9    5
         3     9       9    4    3    9    4
 10      1     1       7    7   10    3    7
         2     6       7    5    9    3    5
         3     8       7    4    8    2    1
 11      1     3      10    1    9    9    9
         2     4       8    1    7    4    6
         3    10       5    1    6    3    4
 12      1     5       9    8    5    8    4
         2     6       8    7    5    6    4
         3     7       5    6    5    2    3
 13      1     5       8    8    2    9    1
         2     6       5    7    2    9    1
         3     9       5    7    1    8    1
 14      1     5       5    6    7    9    4
         2     5       8    5    7    9    5
         3     6       5    4    5    8    1
 15      1     2       4    8    7    8    5
         2     6       4    7    5    7    4
         3     7       4    6    4    5    3
 16      1     6       8    7    8   10    8
         2     6       8    7    9    6    8
         3    10       2    6    6    5    7
 17      1     2       2    6    4   10    4
         2     7       2    6    4    8    4
         3     9       2    6    3    6    3
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   22   21   19  121   80
************************************************************************
