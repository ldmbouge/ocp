************************************************************************
file with basedata            : cr329_.bas
initial value random generator: 7939
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20       12       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          13  17
   3        3          2           8  10
   4        3          2           5  13
   5        3          3           6   7   9
   6        3          3          10  11  14
   7        3          3          10  11  14
   8        3          3          11  12  14
   9        3          1          17
  10        3          2          15  16
  11        3          2          16  17
  12        3          1          13
  13        3          2          15  16
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     6       2    6    4    0    6
         2     6       2    7    4    8    0
         3    10       2    5    2    8    0
  3      1     1       9   10    9    9    0
         2     5       9   10    6    5    0
         3     7       6    9    4    4    0
  4      1     2       8    6    8    0    8
         2     3       8    6    8    4    0
         3     3       8    4    7    0    4
  5      1     3       3    8    6    3    0
         2     5       3    4    5    0    3
         3     7       3    1    1    2    0
  6      1     3       8    6    7    8    0
         2     8       7    2    6    8    0
         3     8       6    4    3    8    0
  7      1     5       8    6    5    0    5
         2     7       7    5    5    3    0
         3     8       6    3    4    3    0
  8      1     1       7   10    7    7    0
         2     7       6   10    6    0    4
         3     9       6   10    5    6    0
  9      1     2       8    9    5    0    5
         2     6       8    5    5   10    0
         3     9       7    3    5    0    4
 10      1     3       9    7    9    7    0
         2     5       9    5    3    7    0
         3     5       9    4    5    7    0
 11      1     1       8    7    7    0    9
         2     5       5    7    6    3    0
         3     9       4    7    3    0    8
 12      1     1       3    9    7    7    0
         2     7       2    9    3    7    0
         3     7       1    8    5    0    2
 13      1     5       4    6    3   10    0
         2     7       3    6    3    8    0
         3     8       2    2    2    7    0
 14      1     5       6    8   10    0    5
         2     5       6    8   10    6    0
         3    10       6    7    6    0    3
 15      1     1       7    8    8    2    0
         2     5       7    7    6    1    0
         3     9       6    6    5    1    0
 16      1     7       5    8    5    3    0
         2     9       5    6    5    0    9
         3    10       5    3    5    0    3
 17      1     4       6    3    8    6    0
         2     4       5    4    7    0    8
         3     5       5    3    6    0    7
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   14   15   13   96   64
************************************************************************
