************************************************************************
file with basedata            : cr462_.bas
initial value random generator: 2703
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  122
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        6       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   9  10
   3        3          2          13  14
   4        3          2           5   8
   5        3          3           9  10  11
   6        3          3           7  11  14
   7        3          1           8
   8        3          1          13
   9        3          2          16  17
  10        3          2          12  13
  11        3          1          15
  12        3          3          14  15  16
  13        3          3          15  16  17
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     2       3   10    8    9    9    7
         2     5       2    8    8    7    8    6
         3    10       2    8    7    5    7    6
  3      1     1       9    6    8    5    4    9
         2     5       9    4    8    4    4    8
         3    10       9    4    8    3    1    3
  4      1     2       5    9   10    7    8    9
         2     8       5    9   10    5    8    9
         3     9       5    7    9    5    8    9
  5      1     4       5    8    5    6    8    5
         2     5       4    8    4    6    5    4
         3     7       3    6    4    5    3    4
  6      1     2       7    6    5    8    6    5
         2     3       6    6    4    7    4    4
         3    10       5    5    4    7    1    3
  7      1     4       8    9    2    4    5    4
         2     5       7    6    2    4    5    4
         3     6       7    5    2    4    4    4
  8      1     3       5   10    4    5    7    3
         2     3       5    9    4    5    8    3
         3     5       4    6    4    5    7    3
  9      1     1       5    6    4    4    8    9
         2     3       5    5    4    3    7    9
         3     6       1    4    3    1    6    8
 10      1     6       7    8    4    4    9    8
         2     8       5    7    4    4    6    6
         3     9       5    7    3    3    5    5
 11      1     1       6    6    8    5    8    4
         2     4       5    5    7    5    8    4
         3     5       1    4    7    4    7    4
 12      1     2       8    4    3    2    5    3
         2     4       6    4    2    2    5    3
         3     7       5    4    2    2    3    2
 13      1     1       4    7    6    6    5   10
         2     4       4    7    5    6    5    8
         3     8       4    6    5    5    3    5
 14      1     1       6    9    9    8    5    3
         2     1       6    9    9    7    5    4
         3     4       6    9    7    7    4    2
 15      1     3       6    3    5    5    5    7
         2     8       6    3    4    3    5    7
         3     8       4    2    3    4    5    7
 16      1     3       9    6    6    8    2    6
         2     4       8    6    5    7    2    5
         3     9       7    6    3    4    2    3
 17      1     3       8    8    4   10    6    8
         2     4       7    7    4    7    4    6
         3     9       6    7    3    6    3    6
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   18   19   18   15  101  101
************************************************************************
