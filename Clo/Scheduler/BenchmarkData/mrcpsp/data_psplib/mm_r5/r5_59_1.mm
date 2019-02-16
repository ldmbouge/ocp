************************************************************************
file with basedata            : cr559_.bas
initial value random generator: 12412
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  117
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23        9       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           7  10
   3        3          3           5   8   9
   4        3          3           6  15  16
   5        3          3           6  12  13
   6        3          1          17
   7        3          3          11  12  13
   8        3          3          11  13  14
   9        3          1          11
  10        3          1          12
  11        3          3          15  16  17
  12        3          1          14
  13        3          2          15  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     1       0    0    8    0    6    6    9
         2     5       0    1    0    0    3    6    6
         3     5       3    0    8    4    0    6    7
  3      1     2       0    6    3    5    5    5    3
         2    10       7    5    0    0    4    4    2
         3    10       0    0    2    0    2    3    3
  4      1     4       9    9    0    4    7    5    7
         2     6       8    9    0    4    5    3    6
         3     7       7    8    6    0    4    3    6
  5      1     3       0    7   10    0    0    8    9
         2     7       8    6   10    0    0    8    6
         3     9       0    0   10    5    0    7    3
  6      1     3       0    9    0    5    0    3    8
         2     6       0    9    3    0    0    2    8
         3     7       0    9    0    0    5    1    7
  7      1     2       0    5    0    7    0    8    1
         2     4       9    5    6    0    0    6    1
         3     5       9    0    6    0    0    5    1
  8      1     2       0    7    7    2    9    8   10
         2     5       0    7    0    1    0    5    6
         3     6       5    0    0    0    7    4    3
  9      1     1       7    8    0    0    0    7    1
         2     4       7    5    0    0    1    3    1
         3     6       0    0    1    6    0    1    1
 10      1     3       0    0    1    0    0    2    2
         2     5       4    0    1    0    7    1    2
         3     6       2    2    0    0    7    1    2
 11      1     2       5    8   10    7    0    9    7
         2     7       5    8    9    0    9    8    4
         3     7       4    0    0    6    0    8    3
 12      1     8       8    2    0    0    0    7    5
         2     9       6    0    0    0    9    7    3
         3    10       0    2    5   10    0    6    1
 13      1     2       0    0    0    8    6    9    7
         2     3       0    0    9    5    0    9    6
         3     7       0    0    7    0    6    9    4
 14      1     7       6    0    0    0    0    5    5
         2     7       0    0    6    5    0    5    5
         3     8       0    0    6    2    9    1    5
 15      1     2       0    0    0    9    0    4    7
         2     6       5    0    0    0    4    4    6
         3     8       5    0    9    9    0    4    2
 16      1     3       0    5    4    5    4   10    9
         2     3       1    4    0    5    0    8    9
         3     9       0    2    0    3    0    5    9
 17      1     2       0    8    4    9    0    5    4
         2     4       0    8    3    8    0    5    3
         3     7       0    0    0    0    7    4    1
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   17   26   26   22   23  101   94
************************************************************************
