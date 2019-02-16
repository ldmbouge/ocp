************************************************************************
file with basedata            : cn342_.bas
initial value random generator: 922097770
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23        9       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   7
   3        3          3           5  11  12
   4        3          2           9  14
   5        3          1          16
   6        3          3           8  10  12
   7        3          2           9  17
   8        3          3           9  11  13
   9        3          2          15  16
  10        3          2          15  17
  11        3          1          14
  12        3          1          13
  13        3          2          14  16
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     6       8    0    5    5    9
         2    10       4    0    3    4    6
         3    10       0    4    2    2    8
  3      1     1       0   10    7    1    6
         2     4       5    0    4    1    5
         3     6       0    7    1    1    5
  4      1     1       0    2    4    6    6
         2     4       0    2    3    5    5
         3     4       9    0    2    4    5
  5      1     1      10    0    3    3    7
         2     2       0    7    3    3    7
         3     6       0    7    2    2    6
  6      1     8       0    6    8    6    9
         2     8       0    9    8    6    8
         3    10       0    4    6    6    8
  7      1     3       3    0    4    5   10
         2     5       0    7    4    3    9
         3     9       0    6    4    2    8
  8      1     2       0    8    6    5    8
         2     3       0    5    5    5    7
         3     7       0    3    3    5    3
  9      1     4       0    3    6   10    9
         2     7       2    0    5    7    8
         3    10       0    2    4    6    5
 10      1     6       0    4    3    6    8
         2     6      10    0    3    4    8
         3     9       3    0    3    2    5
 11      1     5       5    0    8    6    6
         2     6       0   10    8    3    4
         3     9       0    3    5    2    4
 12      1     3       5    0    6    8    7
         2     4       4    0    6    6    6
         3    10       2    0    3    6    2
 13      1     1       0    6    9    6    5
         2     2      10    0    7    5    5
         3     5       0    6    5    4    3
 14      1     1       0    5    8    7    6
         2     2       0    5    7    7    6
         3    10       3    0    6    3    3
 15      1     1       0   10    3    5   10
         2     2      10    0    3    5    6
         3     4       9    0    3    2    3
 16      1     3       6    0    6    8    7
         2     7       5    0    2    2    7
         3     7       3    0    4    2    6
 17      1     1       3    0    6    9    2
         2     4       0    8    3    5    2
         3     8       0    7    3    5    1
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   15   14   73   75   94
************************************************************************
