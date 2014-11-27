************************************************************************
file with basedata            : cm213_.bas
initial value random generator: 1496922668
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  109
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       26       13       26
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          3           5  11  16
   3        2          2           6   7
   4        2          3           5  14  16
   5        2          2          10  17
   6        2          3           8   9  12
   7        2          2           9  10
   8        2          2          11  14
   9        2          3          11  13  16
  10        2          1          12
  11        2          2          15  17
  12        2          1          15
  13        2          1          14
  14        2          2          15  17
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       6    8    0    7
         2     2       6    6    0    8
  3      1     1       7    4    0    7
         2     5       5    2    0    6
  4      1     4       4    6    6    0
         2    10       2    2    4    0
  5      1     5       8    7    8    0
         2     7       8    6    7    0
  6      1     6       5    9    5    0
         2     8       4    7    4    0
  7      1     1       8    4    0    7
         2     7       4    1    6    0
  8      1     6       5    5    0    6
         2     7       2    4    0    5
  9      1     2       9    5    0    9
         2     5       8    2    0    9
 10      1     2      10    6    0   10
         2     6       9    5    0    8
 11      1     6       6    5    0    7
         2     6       2    5    3    0
 12      1     3       8    6    0    7
         2     8       8    5    8    0
 13      1     8       3   10    0    7
         2     9       2    9    0    2
 14      1     2       7    9    7    0
         2     5       5    6    3    0
 15      1     4       3   10    8    0
         2     5       2    6    5    0
 16      1     7       7   10    3    0
         2    10       6    8    0    6
 17      1     7       4    9    3    0
         2     9       3    3    0    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   15   40   58
************************************************************************
