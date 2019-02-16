************************************************************************
file with basedata            : cr516_.bas
initial value random generator: 2105903167
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  137
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       27        0       27
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   7
   3        3          1          16
   4        3          2           5  12
   5        3          2           8  13
   6        3          2          11  15
   7        3          2           8   9
   8        3          3          14  15  17
   9        3          2          10  12
  10        3          3          13  14  15
  11        3          2          12  13
  12        3          2          14  17
  13        3          2          16  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     3       8    9    7    6   10    0    3
         2     4       6    5    6    6   10    9    0
         3     8       4    1    3    6    9    0    2
  3      1     1       5    6    9    1    7    0    5
         2     1       5    5    9    1    7    4    0
         3    10       3    5    9    1    7    4    0
  4      1     5       6    5    2    7    9    0    8
         2     8       5    5    2    7    6   10    0
         3     8       6    1    1    7    8    0    5
  5      1     7       7    5    5    4    6    0    9
         2     8       4    5    5    4    6    7    0
         3    10       3    3    2    3    6    0    6
  6      1     6       9    7    3    9    5    0    6
         2     6      10    8    3    8    5    5    0
         3    10       8    5    3    7    4    5    0
  7      1     1       4    9    5    4    4    8    0
         2     6       4    9    4    4    4    0    6
         3     7       4    9    4    4    1    0    2
  8      1     6       4    5   10    9    8    9    0
         2     7       4    5    6    5    8    6    0
         3     8       3    4    3    5    8    3    0
  9      1     4       5    5    4    3    5    5    0
         2     7       4    5    4    2    3    4    0
         3    10       3    2    1    1    2    0    5
 10      1     5       6    9    6    8    9    0    7
         2     6       4    9    6    8    6    5    0
         3     8       3    8    5    7    3    3    0
 11      1     1       7    5    7    6    7    5    0
         2     8       4    4    5    3    6    5    0
         3    10       2    3    4    2    5    4    0
 12      1     3      10    2    8    5    5    0    5
         2     7      10    2    8    5    5    9    0
         3    10      10    1    8    4    5    9    0
 13      1     7       7    9    9    4    9    0    8
         2     9       7    8    9    4    8    0    4
         3    10       6    4    9    3    8    4    0
 14      1     7       9    7    2    8    6    0    4
         2     7       6    7    2    8    6   10    0
         3     8       4    6    2    8    6    8    0
 15      1     2       4    9    8    7    6    9    0
         2     2       4    9    9    7    5   10    0
         3     9       4    7    8    6    5    7    0
 16      1     2       5    6    4    8    8    0    7
         2     4       4    5    4    4    7    0    4
         3     4       5    5    4    6    5    6    0
 17      1     1       6    4    8    4    8    0    9
         2     6       3    3    8    3    4    7    0
         3     7       2    3    8    3    1    7    0
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   23   25   24   22   26   64   41
************************************************************************
