************************************************************************
file with basedata            : cr545_.bas
initial value random generator: 6284
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  123
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        3       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   9  13
   3        3          2           6  17
   4        3          3           5   9  13
   5        3          3           8  11  16
   6        3          1           7
   7        3          2          10  16
   8        3          3          12  14  15
   9        3          3          12  14  16
  10        3          1          13
  11        3          3          12  14  15
  12        3          1          17
  13        3          1          15
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
  2      1     7       4    3    7    6    9    7   10
         2     7       5    3    8    7    9    7    9
         3    10       3    3    4    6    7    7    8
  3      1     1       9    2    5   10    6    5    9
         2     3       9    2    5    9    3    3    8
         3     8       9    2    4    8    2    3    7
  4      1     4       3    7   10    5    3    8    9
         2     6       3    5    7    4    2    7    9
         3     7       3    3    6    2    2    3    9
  5      1     1       7    6    8    3   10   10    4
         2     5       7    5    7    3   10    8    4
         3     7       6    3    7    3   10    4    3
  6      1     3       7   10    6    8    9    2    8
         2     4       5   10    6    6    7    1    7
         3     9       4   10    6    3    6    1    6
  7      1     2       6   10    9    8   10   10    8
         2     3       5   10    7    7    8    2    7
         3     3       4   10    4    6    5    6    4
  8      1     3       7    5    5    9    8    5    8
         2     3       8    7    5    7    7    5    8
         3     7       6    3    4    7    5    5    8
  9      1     3       9   10    9    9    8    4    4
         2     6       6   10    5    8    5    3    4
         3     7       4   10    5    8    5    2    3
 10      1     4       7    7    5    6    9    8    3
         2     4       7    6    5    6    8    5    4
         3     8       3    4    5    6    7    1    1
 11      1     1       9    4    7    7    5    8   10
         2     2       7    3    6    7    4    5    8
         3     8       6    1    6    4    1    2    7
 12      1     5       5    9    7    6    9   10    5
         2     5       6   10    7    6    8   10    6
         3     8       4    8    6    5    8    8    4
 13      1     1       6    9    7    8    8    5    6
         2     2       4    6    6    6    8    4    6
         3     6       2    4    5    5    8    3    5
 14      1     3       5    3    9    7    6    4    4
         2     4       5    3    8    6    6    3    4
         3     9       4    3    8    6    6    2    4
 15      1     5      10    4    9    8   10    5    6
         2     6       7    4    7    6    7    5    6
         3     9       6    4    4    5    6    4    5
 16      1     1       5    8    6    9    8    8    2
         2     2       5    8    5    8    7    8    1
         3     9       4    8    1    8    7    8    1
 17      1     2       8    8    3   10    8    6    1
         2     5       5    8    3    9    6    4    1
         3     8       3    8    3    8    5    2    1
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   15   15   13   14   15   81   88
************************************************************************
