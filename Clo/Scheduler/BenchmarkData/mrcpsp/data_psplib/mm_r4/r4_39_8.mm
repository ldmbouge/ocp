************************************************************************
file with basedata            : cr439_.bas
initial value random generator: 653109222
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
    1     16      0       21        1       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  12  13
   3        3          3           5   7   8
   4        3          1          16
   5        3          2           6  14
   6        3          3           9  11  15
   7        3          2          10  14
   8        3          3          11  13  15
   9        3          3          10  12  13
  10        3          1          17
  11        3          2          12  16
  12        3          1          17
  13        3          2          16  17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     1      10    6    6    7    5    4
         2     1       9    7    6    7    5    3
         3     2       8    5    3    5    5    3
  3      1     3       4    5    6    6    9    6
         2     7       4    4    6    5    9    4
         3     8       4    4    6    2    9    2
  4      1     1      10    9    8    3    9    7
         2     2      10    7    4    3    7    6
         3     5       9    7    4    3    5    4
  5      1     8       6    3    6   10    7    4
         2     9       6    3    6    8    5    4
         3    10       5    2    5    7    5    4
  6      1     2       8    5    9    4    4    6
         2     6       7    4    9    4    3    5
         3    10       7    3    7    1    2    3
  7      1     4      10    7    7    6    4    8
         2     7       6    6    5    6    4    7
         3     8       4    5    2    5    4    5
  8      1     6       8    8    9    4    3    8
         2     7       8    8    7    3    2    5
         3     8       7    7    5    2    2    3
  9      1     1       4    5    7    9    5    3
         2     9       3    4    5    8    5    3
         3    10       3    3    3    7    1    2
 10      1     1       4    7    6    4    3    5
         2     1       4    5    7    5    4    6
         3     4       3    2    4    3    3    3
 11      1     3       3    7    7    4    5    6
         2     5       2    7    7    4    3    5
         3     5       1    5    7    4    5    3
 12      1     3       8    9   10    8    5   10
         2     5       4    8    8    7    5    9
         3     7       2    8    7    5    5    9
 13      1     4       8    3    3    5    4    5
         2     4       8    3    5    5    3    5
         3     6       8    3    1    4    3    3
 14      1     2       3    3   10    3    7    2
         2     6       2    3   10    2    3    2
         3    10       1    3   10    1    1    1
 15      1     3       2    5    7    7    9    7
         2     4       2    5    7    6    8    5
         3     9       1    4    6    2    8    3
 16      1     2       7   10   10    5    8    7
         2     5       5   10    9    4    5    3
         3    10       3   10    7    2    3    2
 17      1     2       8    5    7    7    8    7
         2     4       5    5    6    7    6    4
         3    10       3    4    5    1    3    1
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   20   19   22   18   71   62
************************************************************************
