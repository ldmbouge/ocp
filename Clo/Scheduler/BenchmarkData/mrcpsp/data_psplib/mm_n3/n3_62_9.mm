************************************************************************
file with basedata            : cn362_.bas
initial value random generator: 411908860
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  128
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       14       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7   9
   3        3          2           5   8
   4        3          2          12  13
   5        3          3           6  16  17
   6        3          1          13
   7        3          2          10  11
   8        3          3          11  12  14
   9        3          3          10  11  13
  10        3          2          12  16
  11        3          2          15  17
  12        3          2          15  17
  13        3          1          14
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     2       5    9    5    6    9
         2     3       3    8    5    4    8
         3     7       2    8    5    2    6
  3      1     5       9    4    5    9    9
         2     7       4    4    2    5    7
         3     7       5    4    4    3    7
  4      1     2       3    3    8    7    5
         2     7       2    3    7    7    5
         3     8       1    2    3    7    4
  5      1     1       3    9    4    8    4
         2     9       1    4    2    7    3
         3     9       1    5    2    6    3
  6      1     1       5    7    5   10    7
         2     3       5    6    3    7    6
         3     9       4    4    1    4    6
  7      1     3       7    8    5    9    7
         2     5       7    8    3    9    6
         3     9       7    7    3    9    4
  8      1     5       4   10    9    4    4
         2     7       2   10    6    3    2
         3     8       2    9    5    3    1
  9      1     3       6    8    7    9    8
         2     9       5    5    6    5    5
         3    10       3    4    6    3    4
 10      1     3       8    9    5   10    3
         2     4       8    8    3    9    2
         3     8       8    5    2    9    1
 11      1     2       1    9    6    9    9
         2     2       1    8    7    9    8
         3     4       1    2    6    9    5
 12      1     6       3    4    7   10    8
         2     6       3    5    6    9    9
         3     8       1    1    3    8    8
 13      1     2       8    8    8    3    8
         2     8       6    3    8    2    7
         3    10       5    1    7    2    6
 14      1     2       8    7    8    3    5
         2     7       7    5    4    1    3
         3     7       5    4    5    3    3
 15      1     2       4    2    6    9    7
         2     5       4    1    5    9    5
         3    10       3    1    1    9    4
 16      1     1      10    5    4    9    8
         2     2      10    4    3    6    6
         3     6      10    3    3    5    5
 17      1     3       9    5    2    8    2
         2     5       8    3    1    5    1
         3     8       5    1    1    4    1
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   16   19   95  123  104
************************************************************************
