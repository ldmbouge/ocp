************************************************************************
file with basedata            : cr562_.bas
initial value random generator: 629937048
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        1       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8  12
   3        3          3           7  16  17
   4        3          3           7   9  11
   5        3          3           6  14  16
   6        3          2          13  17
   7        3          2           8  12
   8        3          1          10
   9        3          3          10  12  14
  10        3          1          13
  11        3          2          13  16
  12        3          1          15
  13        3          1          15
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     7       8   10    5    8    7   10    9
         2     7       8    7    7    8    6   10    9
         3     8       2    3    2    8    4    7    8
  3      1     2       5    4    8   10    7    7    8
         2     2       5    5    8    7    7    6    8
         3     3       3    2    8    3    5    6    3
  4      1     2       4    8    5   10    3    7    9
         2     7       3    5    4    8    2    6    9
         3     8       2    4    4    7    2    6    8
  5      1     1       8    5    7    4    9   10   10
         2     4       6    5    4    4    8    6    7
         3     8       4    4    3    4    8    5    7
  6      1     2       4    7    6    5    8    3    7
         2     7       4    7    6    4    7    3    6
         3     9       4    4    5    4    4    2    6
  7      1     2       5    7    7   10    4    8    8
         2     8       5    6    6    6    3    6    7
         3     9       5    5    4    3    3    4    7
  8      1     1       4    4    7    5    9    6    9
         2     2       3    4    6    5    8    3    7
         3     7       1    3    5    3    8    1    6
  9      1     5       9   10    2    7    7    7    4
         2     6       7   10    2    5    7    7    3
         3    10       6    9    2    4    7    7    3
 10      1     4       7    8    4    6    5   10    9
         2     8       6    8    4    6    5   10    8
         3     9       6    5    3    6    2   10    6
 11      1     6       3    8    6    7   10   10    9
         2     7       2    7    6    6   10   10    8
         3     8       2    6    5    5    9   10    8
 12      1     5       9    5    9    5    6    8   10
         2     6       8    5    6    5    6    3    9
         3    10       8    4    5    5    6    3    6
 13      1     5       2    9    7    4    5    8    7
         2     8       1    5    6    4    4    8    4
         3     9       1    1    3    4    3    8    3
 14      1     1       5    4    5    5   10    7    7
         2     3       4    3    3    4    7    6    6
         3     4       2    3    3    3    6    3    6
 15      1     5       6    9    6   10    8    8    6
         2     8       5    7    6    9    8    7    4
         3    10       5    4    4    8    7    3    1
 16      1     2       4    4    9    5   10    5    2
         2     5       3    3    9    5   10    5    2
         3     8       1    2    8    2    9    4    1
 17      1     8       7    9   10    7    6    5    9
         2     9       5    9   10    7    3    5    5
         3    10       5    9   10    5    3    3    4
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   19   22   22   20   24  119  123
************************************************************************
