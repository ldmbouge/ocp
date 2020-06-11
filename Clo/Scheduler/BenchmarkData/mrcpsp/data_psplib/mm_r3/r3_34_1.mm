************************************************************************
file with basedata            : cr334_.bas
initial value random generator: 27623
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  134
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23        1       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          11  15
   3        3          1           6
   4        3          3           5   6   8
   5        3          3           7  10  13
   6        3          3           9  12  17
   7        3          3           9  11  14
   8        3          3           9  10  14
   9        3          1          16
  10        3          2          11  16
  11        3          1          17
  12        3          1          14
  13        3          3          15  16  17
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
  2      1     1       0    8    0    2    1
         2     3       0    0    9    1    1
         3     3       2    0    0    2    1
  3      1     8       7    5    0    2    2
         2     9       7    0    0    2    2
         3    10       0    5    0    2    1
  4      1     2       7    6    0    4    8
         2     7       7    0    8    3    7
         3    10       6    0    3    3    5
  5      1     3       7    8    0    1    9
         2     4       0    5    0    1    6
         3     8       4    0    8    1    4
  6      1     4       0    0   10    6    1
         2     5      10   10    8    4    1
         3     7       8    8    4    2    1
  7      1     2       7    0    0    6    9
         2     3       0    8   10    5    8
         3    10       0    7    9    2    8
  8      1     2       0    0    8    5    7
         2     2       2    7    0    5    8
         3     8       0    7   10    4    5
  9      1     4       0    6    0    7    3
         2     4       0    0    5    7    4
         3     9       0    6    0    7    2
 10      1     8       3    0    4    6    8
         2    10       1    0    0    4    8
         3    10       0    6    0    3    8
 11      1     9       0    0    7    3    8
         2     9       7    0    0    3    6
         3    10       0    0    9    2    2
 12      1     1       6   10    0    7    7
         2     3       0    9    0    6    5
         3    10       6    9    0    3    3
 13      1     1       0    3    0    7    9
         2     4       8    0    0    5    6
         3     8       6    3    0    2    5
 14      1     1       0    8    0    9   10
         2     5       0    0    2    7    9
         3    10       5    0    0    3    9
 15      1     3       0    3    4    9    9
         2     5       0    2    4    4    8
         3    10       0    1    4    3    6
 16      1     1       9    0    6    3    7
         2     2       7    0    0    3    5
         3     7       6    0    0    3    2
 17      1     1       6    6    0    7    9
         2     2       0    6    3    3    7
         3     4       3    6    0    3    6
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   16   16   16   54   78
************************************************************************
