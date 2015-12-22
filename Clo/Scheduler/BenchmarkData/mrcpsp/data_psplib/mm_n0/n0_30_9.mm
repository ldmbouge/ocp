************************************************************************
file with basedata            : me30_.bas
initial value random generator: 528932548
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        5       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          10  11  12
   3        3          1           5
   4        3          3           6   8  11
   5        3          3           6   7   8
   6        3          3           9  10  12
   7        3          1          11
   8        3          2          12  15
   9        3          2          13  14
  10        3          2          15  16
  11        3          2          16  17
  12        3          1          13
  13        3          2          16  17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     1       6    7
         2     5       4    4
         3     8       3    2
  3      1     2      10    9
         2     6       7    7
         3     9       7    5
  4      1     3       6    6
         2     9       4    3
         3    10       3    2
  5      1     1       4    9
         2     3       4    8
         3     7       4    6
  6      1     5       8    7
         2    10       4    5
         3    10       1    6
  7      1     8       9    5
         2     8      10    4
         3    10       7    2
  8      1     2       7    4
         2     3       7    3
         3     7       7    1
  9      1     6       8    5
         2     7       7    1
         3     7       5    4
 10      1     3       5    8
         2     5       4    8
         3    10       2    7
 11      1     3       9   10
         2     4       6   10
         3     9       6    9
 12      1     6       6    5
         2     8       6    3
         3     8       5    4
 13      1     1       5    8
         2     6       4    7
         3     8       3    7
 14      1     1       9   10
         2     8       4   10
         3     9       3   10
 15      1     1       4    4
         2     2       3    3
         3     3       3    1
 16      1     3       5    6
         2     5       4    4
         3     7       4    3
 17      1     3       8    4
         2     3       7    6
         3     7       7    2
 18      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   18   17
************************************************************************
