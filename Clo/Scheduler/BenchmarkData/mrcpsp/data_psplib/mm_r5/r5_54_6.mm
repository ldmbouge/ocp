************************************************************************
file with basedata            : cr554_.bas
initial value random generator: 1862655272
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  120
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       29       15       29
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8  10
   3        3          3           8  11  16
   4        3          3           8  10  11
   5        3          3           6   7  16
   6        3          1          17
   7        3          3           9  12  15
   8        3          2          13  15
   9        3          2          11  13
  10        3          3          15  16  17
  11        3          1          14
  12        3          1          13
  13        3          1          14
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     4       8    9    4    8    9    7    9
         2     6       6    9    4    6    8    6    8
         3     9       6    8    4    2    8    6    7
  3      1     8       4    9   10    6    8    6    9
         2     8       3    7   10    8    8    7    8
         3    10       3    6   10    5    7    2    7
  4      1     2       6    9    4    3    6    8    4
         2     6       4    8    3    2    5    8    4
         3     7       2    4    3    2    4    7    3
  5      1     2      10    3    7    4    7    5    9
         2     4      10    2    6    4    5    4    8
         3     4       9    2    5    4    7    4    5
  6      1     2       6    8    4    5    6    8    6
         2     6       5    4    3    5    1    7    4
         3     6       3    6    3    5    1    7    4
  7      1     2       7    8    4    2    6    6    7
         2     5       7    8    4    2    5    6    6
         3     6       5    7    2    1    2    5    6
  8      1     4       9    6    7    8    4    9    8
         2     7       9    5    4    6    4    9    7
         3    10       8    4    1    4    3    8    7
  9      1     5       8    5    9    3    2    3    9
         2     8       5    3    8    3    2    1    4
         3     8       4    1    8    3    2    2    6
 10      1     1       9    7    7    8    8    3    7
         2     7       6    6    3    6    6    2    6
         3     7       7    3    3    7    6    2    5
 11      1     1       8    8    7    8    6    7    6
         2     1       8    8    7    6    8    7    6
         3     8       6    7    6    5    6    7    6
 12      1     3       6    8    6    7    6    6   10
         2     4       3    5    4    7    3    5   10
         3     5       2    5    4    6    3    3    9
 13      1     4       8    7    5    3    7    8    3
         2     5       7    6    5    3    7    7    2
         3     7       4    4    5    2    5    7    2
 14      1     4       5    5    7    5    4    8    3
         2     6       5    5    5    2    4    7    3
         3     7       4    4    5    1    3    5    3
 15      1     1       3    7    5    3    1    8    6
         2     8       3    5    5    2    1    8    5
         3     8       3    4    4    2    1    7    6
 16      1     6       6    6    3    6    6   10   10
         2     6       9    7    4    7    5   10   10
         3     8       5    4    3    3    3   10    9
 17      1     8       6   10    3    8    6    5    9
         2     9       6    9    3    7    5    5    7
         3    10       6    6    3    4    4    5    6
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   21   18   18   16   16  103  108
************************************************************************
