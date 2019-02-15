************************************************************************
file with basedata            : cr461_.bas
initial value random generator: 9537
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  125
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       25        3       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   8   9
   3        3          3           5   7   8
   4        3          1           8
   5        3          3          12  13  17
   6        3          3          12  14  15
   7        3          3          10  11  12
   8        3          2          15  17
   9        3          2          11  14
  10        3          1          14
  11        3          2          13  16
  12        3          1          16
  13        3          1          15
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     2       7    3    9    9    7    2
         2     4       7    2    8    8    6    2
         3     5       7    1    7    7    6    1
  3      1     7       9    6    5    7    4    8
         2     8       6    6    4    5    3    6
         3    10       5    5    3    4    3    4
  4      1     5       8    3    9    5    8    7
         2     8       4    2    8    4    5    7
         3     8       6    1    8    4    7    7
  5      1     5       7    6    8    4    9    4
         2     6       6    4    8    4    6    3
         3     8       6    3    7    2    5    3
  6      1     4       2    6    4    9    5    8
         2     6       1    5    4    7    4    7
         3     9       1    4    4    6    4    5
  7      1     3       9    7   10    7   10    9
         2     4       8    7    9    4    8    7
         3     5       4    6    9    2    6    4
  8      1     1       5    9    7    7    4    5
         2     1       6    9    7    6    4    5
         3     7       3    7    7    1    4    3
  9      1     4       6    5    6    9    7    9
         2     5       5    4    6    6    6    6
         3     9       3    3    5    2    6    4
 10      1     1       8    9    8    9    9    7
         2     3       7    9    8    8    8    6
         3     6       5    9    7    8    6    5
 11      1     3       9    9   10    7    9   10
         2     6       8    4    9    6    7    9
         3     8       8    3    7    6    6    9
 12      1     1       7    7    3    9    3    5
         2     5       4    6    3    6    3    5
         3     9       2    6    1    4    1    5
 13      1     2       7    8    2    6    5   10
         2     7       7    6    2    4    4   10
         3     8       6    3    2    2    1    9
 14      1    10       7    3    4    6    3    1
         2    10       8    1    1    6    3    2
         3    10       6    2    5    7    2    2
 15      1     7       6    9    2    2    5    2
         2     7       4    8    2    3    4    3
         3     7       5    9    1    3    4    3
 16      1     1       3    7    2    4    8    3
         2     7       1    1    2    3    8    3
         3     7       1    3    2    3    7    2
 17      1     4       6    5    9   10    5    6
         2     4       5    6    7    6    6    7
         3     9       4    4    6    2    4    4
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   12   13   13   14  102   99
************************************************************************
