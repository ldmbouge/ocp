************************************************************************
file with basedata            : cr363_.bas
initial value random generator: 1419821929
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  121
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       28        1       28
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   8
   3        3          2           6   7
   4        3          3           6   9  13
   5        3          3          10  12  15
   6        3          3          14  16  17
   7        3          3           8   9  14
   8        3          1          11
   9        3          3          12  15  17
  10        3          1          11
  11        3          2          13  17
  12        3          1          16
  13        3          1          16
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
  2      1     3       7    6   10    9    5
         2     6       7    5   10    7    4
         3     9       7    4    9    4    4
  3      1     4       3    3    7    8    7
         2     7       1    1    4    8    5
         3     7       2    2    3    8    7
  4      1     2       8    9    9    8    9
         2     3       7    6    7    5    9
         3     6       7    4    6    3    9
  5      1     3       9   10    4    4    9
         2     6       8   10    4    4    6
         3     7       5   10    2    2    4
  6      1     5      10    9    8    5    3
         2     8       9    6    4    3    2
         3     8      10    8    3    2    1
  7      1     4       5    5    5    9    4
         2     5       3    4    5    9    4
         3     5       4    4    4    8    4
  8      1     5       9    8    8    7    4
         2     8       7    7    8    7    4
         3    10       5    7    6    6    2
  9      1     2       8    4    6    3    8
         2     3       6    4    4    3    8
         3     9       4    2    4    3    8
 10      1     1       7   10   10    9    5
         2     3       6   10    6    9    5
         3     8       6    9    4    8    4
 11      1     6       7    9    6    4    8
         2     6       5   10    6    4    8
         3     9       4    8    6    4    8
 12      1     1       5    2    4    9    5
         2     9       2    1    3    5    4
         3     9       3    2    4    2    2
 13      1     1       8    7    8    7    7
         2     2       5    7    8    5    6
         3     3       3    7    6    3    4
 14      1     3       8    5    3    5    8
         2     4       4    4    3    4    5
         3     5       4    1    3    1    3
 15      1     4       4    2    8    8    9
         2     7       3    1    7    7    6
         3     7       2    2    7    7    6
 16      1     8       7    7    7    7    5
         2     8       7    5    8    7    5
         3    10       7    3    5    5    4
 17      1     3       6   10    8    2    8
         2     7       6    7    6    2    7
         3     9       5    1    2    1    7
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   23   21   22  104  104
************************************************************************
