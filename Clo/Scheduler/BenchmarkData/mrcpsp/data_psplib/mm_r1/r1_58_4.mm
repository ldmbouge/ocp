************************************************************************
file with basedata            : cr158_.bas
initial value random generator: 555158783
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  127
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       15        1       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5  11  17
   3        3          3           6   7  10
   4        3          3           9  16  17
   5        3          3           6   9  10
   6        3          1          14
   7        3          3           8  13  17
   8        3          3           9  11  14
   9        3          1          15
  10        3          1          12
  11        3          2          15  16
  12        3          1          13
  13        3          2          14  15
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       0    7    7
         2     6       0    6    6
         3    10       9    5    3
  3      1     3       0    2    9
         2     9       0    1    8
         3    10       0    1    6
  4      1     3       3    9    3
         2     7       0    9    2
         3     7       0    8    3
  5      1     2       5    7    7
         2     3       0    6    7
         3     5       0    5    6
  6      1     1       0    9    6
         2     2       0    8    4
         3     9       4    7    4
  7      1     1       5    7   10
         2     3       4    7    9
         3     7       0    4    7
  8      1     2       0    5    8
         2     6      10    3    4
         3     7       0    2    2
  9      1     5       6    7    8
         2     6       4    7    5
         3     9       2    2    5
 10      1     1       1    8    7
         2     2       0    4    4
         3     9       0    4    3
 11      1     1       0    6   10
         2     4       6    4   10
         3     6       1    3    9
 12      1     3       9    5    9
         2     9       0    4    7
         3     9       0    3    8
 13      1     3      10    6    5
         2     3      10    5    6
         3    10       8    5    5
 14      1     3       6    9    8
         2     6       6    7    7
         3     8       0    7    3
 15      1     3       9    6    6
         2     4       0    4    3
         3     8       0    4    2
 16      1     2      10    8    8
         2     3       8    6    5
         3     4       0    6    1
 17      1     5       0    7    9
         2     6       4    5    9
         3     9       4    4    8
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   19  108  121
************************************************************************
