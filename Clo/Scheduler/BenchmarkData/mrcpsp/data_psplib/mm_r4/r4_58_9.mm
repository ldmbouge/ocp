************************************************************************
file with basedata            : cr458_.bas
initial value random generator: 508021869
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  128
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17        0       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7   8
   3        3          3          10  13  14
   4        3          3          11  12  15
   5        3          2           6   9
   6        3          3          11  12  15
   7        3          3           9  10  14
   8        3          2           9  11
   9        3          1          16
  10        3          1          17
  11        3          1          13
  12        3          2          16  17
  13        3          1          16
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     3       0    0    0    9    4    6
         2     7       7    7    0    0    4    4
         3    10       3    4    0    0    3    3
  3      1     2       0    0    0    5    9    3
         2     3       0    3    0    2    9    2
         3     3       0    4    6    0    9    2
  4      1     3      10    7    9   10   10    4
         2     5       0    0    0   10    7    3
         3    10       2    7    3    0    5    2
  5      1     1       0    0    0    3    4    2
         2     5       0    0    6    3    3    2
         3    10       7   10    4    3    2    1
  6      1     1       5    5    0    0    6    8
         2     3       0    3    0    0    6    8
         3     5       3    0    0    0    5    8
  7      1     4       4    5    7   10    7    7
         2     5       0    0    0    9    7    4
         3     8       0    0    0    9    5    2
  8      1     4       0    0    4    0    6    8
         2     7       0    0    4    8    3    5
         3    10       9    4    4    8    1    3
  9      1     1       7    0    0    0    8    9
         2     7       3    0    5    0    7    8
         3     9       0    8    0    5    7    8
 10      1     4       0    0    8    0    2    5
         2     4       0    9    6    0    2    5
         3     8       6    5    5    0    1    4
 11      1     1       9    9    6    0    4    8
         2     2       0    0    6    0    3    7
         3     4       3    0    6    0    2    7
 12      1     1       0    0    0    7    7    8
         2    10       7   10    0    0    7    4
         3    10       0    0    0    4    7    7
 13      1     2       4    2    8    5    7    9
         2     2       0    5    0    0    8    8
         3     9       0    0    8    0    1    6
 14      1     2       3    6    0    0    8    8
         2     3       2    5    4    3    6    7
         3     5       2    0    0    3    4    7
 15      1     8       4   10    0    9    9    9
         2     9       1    0    8    9    8    9
         3    10       0    7    7    0    6    9
 16      1     1       7    6    8    0    9    9
         2     8       5    0    0    0    7    6
         3     8       5    0    0    0    6    7
 17      1     1      10    5    8    7    5    6
         2     7       6    0    0    0    3    6
         3     9       0    0    0    5    3    6
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   16   19   18   18  106  109
************************************************************************
