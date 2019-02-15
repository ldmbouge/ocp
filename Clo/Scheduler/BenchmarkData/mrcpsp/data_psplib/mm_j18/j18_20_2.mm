************************************************************************
file with basedata            : md276_.bas
initial value random generator: 600824892
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  142
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       31        1       31
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5  10  19
   3        3          3           6   9  16
   4        3          3          11  13  14
   5        3          3          12  14  16
   6        3          1           7
   7        3          2           8  10
   8        3          3          12  14  19
   9        3          2          13  17
  10        3          1          15
  11        3          1          16
  12        3          2          13  15
  13        3          1          18
  14        3          1          15
  15        3          2          17  18
  16        3          2          17  18
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       8    0    0    7
         2     3       0    7    0    6
         3     7       5    0    0    2
  3      1     4       0    9    0    4
         2     6       0    4    0    4
         3     7       0    1    0    1
  4      1     3       0    5    9    0
         2     5       0    2    9    0
         3     9       7    0    8    0
  5      1     2       0    8    0    6
         2     6       0    6    6    0
         3     8       0    5    2    0
  6      1     5       0    6    0    8
         2     7       8    0    7    0
         3     9       8    0    0    5
  7      1     2       0    7    0   10
         2     7       0    5    0    6
         3     9       0    2    0    6
  8      1     4       7    0    0   10
         2     6       0   10    0    5
         3     9       5    0    0    4
  9      1     3       0    2    6    0
         2     5       0    1    5    0
         3     6       0    1    0    4
 10      1     4       0    9    0    9
         2     6       5    0    7    0
         3     8       0    9    0    8
 11      1     2       1    0    8    0
         2     4       0    8    7    0
         3     8       0    8    0    5
 12      1     4       0    9    0    6
         2     7       4    0    0    3
         3    10       0    7    7    0
 13      1     2       5    0    5    0
         2     5       5    0    4    0
         3     7       0    7    2    0
 14      1     2       0    9    7    0
         2     5       0    7    0    3
         3     8       6    0    0    2
 15      1     6       8    0    6    0
         2     6       0    3    9    0
         3     8       7    0    4    0
 16      1     4       0    1    3    0
         2     5       8    0    1    0
         3     5       8    0    0    5
 17      1     2       0    7    0    8
         2     2       1    0    0    9
         3     8       0    6    4    0
 18      1     6       7    0    6    0
         2     8       0    9    5    0
         3     9       0    7    0    6
 19      1     2       8    0    0    8
         2     2       7    0    6    0
         3     7       0    1    0    8
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   23   25   71   78
************************************************************************
