************************************************************************
file with basedata            : md207_.bas
initial value random generator: 550374288
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  140
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       29        3       29
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           9  12  16
   3        3          2           5   8
   4        3          3          12  13  16
   5        3          2           6   7
   6        3          2          11  14
   7        3          2           9  12
   8        3          3          11  14  16
   9        3          3          10  11  14
  10        3          1          13
  11        3          2          15  17
  12        3          2          15  17
  13        3          1          15
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
  2      1     2       3    3    0    6
         2     2       4    3    4    0
         3     8       2    3    0    9
  3      1     8       9    5    0    6
         2     8       8    5    0    7
         3    10       5    5    2    0
  4      1     5       1    8    8    0
         2     8       1    7    0    6
         3     8       1    6    0   10
  5      1     6       3    4    6    0
         2     9       3    2    0    7
         3    10       2    1    0    4
  6      1     4      10    8    8    0
         2     8       9    7    7    0
         3     9       9    7    5    0
  7      1     2       7    8    0    2
         2     3       7    6    0    1
         3     9       6    3    0    1
  8      1     5       4    8    0    8
         2     6       4    6    0    7
         3    10       4    4    0    6
  9      1     4       8    6    7    0
         2     6       8    5    0    6
         3     7       5    4    7    0
 10      1     2       9    9    5    0
         2     8       5    8    0   10
         3     8       2    6    4    0
 11      1     1       8    6    6    0
         2     3       6    5    0    8
         3     7       4    5    5    0
 12      1     7       1   10    0    6
         2     8       1    9    7    0
         3    10       1    9    0    6
 13      1     1       7    8    0    8
         2     5       7    7    2    0
         3     7       6    2    0    6
 14      1     3       9    7    0    5
         2     6       6    4   10    0
         3     9       5    4    4    0
 15      1     6       2    7    4    0
         2     7       1    6    0    7
         3    10       1    6    3    0
 16      1     3       8    8    0    4
         2     9       8    5    7    0
         3    10       7    3    7    0
 17      1     3       7    4    8    0
         2     5       5    4    7    0
         3     8       5    1    6    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   23   26   48   52
************************************************************************
