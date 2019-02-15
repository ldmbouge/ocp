************************************************************************
file with basedata            : md244_.bas
initial value random generator: 1765775311
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       26       12       26
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8  15
   3        3          2           6  10
   4        3          3           6   7   8
   5        3          3           7   9  13
   6        3          3           9  11  15
   7        3          2          10  14
   8        3          2           9  11
   9        3          2          14  16
  10        3          2          16  17
  11        3          2          12  16
  12        3          1          13
  13        3          1          14
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       0    5   10    6
         2     3       0    4    9    4
         3     6       0    4    9    3
  3      1     3       3    0    5    8
         2     5       3    0    4    4
         3    10       2    0    4    1
  4      1     2       8    0    6    9
         2     4       0    9    5    8
         3     7       0    9    2    5
  5      1     4       0    5    6    3
         2     8       0    5    6    1
         3     8       0    5    5    2
  6      1     2       0    9   10    6
         2     3      10    0   10    3
         3     9       9    0    9    2
  7      1     1       9    0    7    8
         2     8       0    7    5    7
         3    10       9    0    1    5
  8      1     5       0    7    7    4
         2     6       0    5    6    4
         3     6       8    0    6    4
  9      1     1       0    8    3    9
         2     8       0    8    2    7
         3    10       5    0    1    6
 10      1     1       0    5    7    5
         2     3       5    0    7    4
         3    10       4    0    7    2
 11      1     6       0    7    7    6
         2     9       0    6    6    6
         3    10       9    0    4    5
 12      1     2       0    9    7    3
         2     4       0    8    6    3
         3     6       7    0    5    2
 13      1     5       0   10    7    5
         2     6       0    7    7    4
         3    10       5    0    5    4
 14      1     3       9    0    5    5
         2     6       0    7    3    5
         3     6       7    0    5    5
 15      1     4       0    4   10    6
         2     4       8    0    9    6
         3     5       8    0    4    5
 16      1     2       0    4    6    9
         2     6       0    3    5    5
         3     9       2    0    5    3
 17      1     3       5    0    8    6
         2     3       0    8    9    5
         3     7       0    5    8    4
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   27   26  104   88
************************************************************************
