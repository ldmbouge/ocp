************************************************************************
file with basedata            : cr557_.bas
initial value random generator: 591178521
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       13       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           8  14
   3        3          3          11  13  15
   4        3          3           5   9  13
   5        3          3           6   7  10
   6        3          1          17
   7        3          2           8  14
   8        3          3          11  12  15
   9        3          3          11  12  17
  10        3          2          12  15
  11        3          1          16
  12        3          1          16
  13        3          1          14
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     3       9    0    0    0    6    9   10
         2     6       9    0    4    8    4    9    9
         3     9       0    1    0    8    0    7    9
  3      1     2       8    4    0    7    0    5   10
         2     4       3    3    2    0    1    5    7
         3     7       0    3    0    4    0    5    5
  4      1     3       0    0    7    7    0    3    4
         2     4       0    0    0    0    5    3    3
         3     9       1    0    6    0    0    2    1
  5      1     2       6    9    0    0    0    6    6
         2     4       6    9    0    7    0    6    4
         3    10       6    0    8    0    4    6    3
  6      1     5       0    2    9    0    0   10    2
         2     9       0    0    9    4    3    6    1
         3     9       6    0    8    3    0    7    2
  7      1     6       8    0    8    4    0    6    8
         2     6       7    0    0    7    8    6    7
         3    10       4    0    0    0    7    5    6
  8      1     1       0    8    6    4    3    6    5
         2     7       7    0    4    2    0    5    5
         3     9       0    5    0    2    0    2    5
  9      1     4       9    6    5    0    8    9    8
         2     4       0    0    0    4    9    9    7
         3     9       0    7    0    0    8    4    5
 10      1     1       0    0    0    0    7    2    8
         2     1       6    0    4    9    0    3    7
         3     1       8    3    0    9    0    2    9
 11      1     4       7    9    6    6    6    7    8
         2     5       3    6    0    0    0    3    6
         3     8       0    0    6    0    0    2    2
 12      1     4       7    0    5    0    0    3    9
         2     8       6    0    0    6    6    3    8
         3     9       0    0    0    1    6    2    8
 13      1     1       8    0    0   10    0    8    4
         2     3       0    6    4    0    5    8    2
         3     3       8    0    3    1    0    8    4
 14      1     5       8    0    0    7    4    5    8
         2     9       8    0    7    0    0    5    6
         3    10       0    2    6    0    0    4    6
 15      1     2       0    8    3   10    3    6    8
         2     6       2    0    0    9    1    5    7
         3     8       2    4    0    0    0    1    4
 16      1     1       0   10    0    0    5   10    2
         2     4       8    0    0    0    5    8    2
         3     6       8    3    8    7    0    4    2
 17      1     3       9    0    0    0    0    6    8
         2     6       0    7    0    6    0    5    7
         3     7       0    0    0    3    0    4    7
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   12    8   11   10   12  102  109
************************************************************************
