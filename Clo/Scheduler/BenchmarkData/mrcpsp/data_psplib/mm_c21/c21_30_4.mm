************************************************************************
file with basedata            : c2130_.bas
initial value random generator: 704090844
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  121
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20        0       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   9  12
   3        3          3           5   8  10
   4        3          3           5   6   9
   5        3          3          12  13  14
   6        3          3           7  11  12
   7        3          3           8  10  14
   8        3          2          13  16
   9        3          2          10  11
  10        3          1          15
  11        3          2          13  14
  12        3          3          15  16  17
  13        3          2          15  17
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       8    4    7    0
         2     8       6    2    0    6
         3    10       5    1    0    1
  3      1     5       5    8    8    0
         2     8       4    4    0    1
         3     9       4    2    5    0
  4      1     2       5    3    2    0
         2     3       5    3    0    4
         3     5       4    2    2    0
  5      1     2       9    8    8    0
         2     5       5    7    0    2
         3     7       2    7    6    0
  6      1     2       8    7    0    5
         2     8       4    6    0    4
         3     9       3    3    8    0
  7      1     1       9    7    0    5
         2     3       7    6    0    3
         3     5       6    3    8    0
  8      1     1       5    6    4    0
         2     6       5    5    0   10
         3     9       3    5    0    4
  9      1     3       6    6    0    9
         2     4       6    4    0    9
         3     5       6    1    0    9
 10      1     1       7    7    3    0
         2     3       6    5    0    8
         3     5       6    3    0    8
 11      1     2       9    7    6    0
         2     7       6    3    5    0
         3     7       6    6    0    7
 12      1     7      10    7    0    9
         2     9       8    5    2    0
         3    10       4    2    0    9
 13      1     3       8    3    0    8
         2     7       7    1    0    5
         3     7       7    2    5    0
 14      1     3       9    8    0    7
         2     5       8    4    9    0
         3     9       7    1    2    0
 15      1     4       5    6    0    6
         2     5       4    5    0    5
         3     8       4    5    0    4
 16      1     1      10    8    0   10
         2     4       8    8    0   10
         3     9       7    7    2    0
 17      1     6       9    4    7    0
         2     7       3    4    0    6
         3     7       1    4    6    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   14   79  103
************************************************************************
