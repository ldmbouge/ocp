************************************************************************
file with basedata            : md333_.bas
initial value random generator: 26721
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  146
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       17       10       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          10  11
   3        3          2          14  18
   4        3          3           5  10  19
   5        3          3           6   7   8
   6        3          3           9  12  15
   7        3          2          11  13
   8        3          2           9  17
   9        3          2          20  21
  10        3          3          13  14  16
  11        3          2          15  16
  12        3          3          13  17  18
  13        3          1          20
  14        3          1          15
  15        3          2          17  20
  16        3          1          18
  17        3          1          21
  18        3          1          21
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       3    4    4    0
         2    10       3    4    3    0
         3    10       3    4    0    2
  3      1     3       9    8    9    0
         2     4       8    8    0    4
         3     9       6    3    0    2
  4      1     2       8    6    0    6
         2     8       8    4    6    0
         3     8       8    4    0    5
  5      1     1       6    7    7    0
         2     3       3    7    7    0
         3     7       2    7    6    0
  6      1     1       4    9    0   10
         2     2       2    7    0    9
         3     5       1    4    4    0
  7      1     4       2    8    9    0
         2     6       1    8    8    0
         3    10       1    5    0    8
  8      1     1       8    6    0    8
         2     3       6    6    0    8
         3     7       3    4    0    6
  9      1     1       4    3    6    0
         2     8       2    3    0    4
         3     8       1    3    0    8
 10      1     2       4    7    0    8
         2     3       3    6    5    0
         3     8       3    6    0    5
 11      1     3       8    5    5    0
         2     3       7    5    0    8
         3     5       7    4    5    0
 12      1     1       5    7    7    0
         2     3       4    6    0    4
         3     4       3    6    7    0
 13      1     5       4    4    6    0
         2     6       4    4    4    0
         3     8       4    3    0    6
 14      1     3       1   10    2    0
         2     3       4    8    1    0
         3     3       2   10    1    0
 15      1     3       6   10   10    0
         2     4       4   10    9    0
         3     4       3   10    0    6
 16      1     1       5   10    0   10
         2     6       3    7    3    0
         3     9       2    4    0    6
 17      1     3       7    6    0    3
         2     5       7    4    0    2
         3     7       6    1    4    0
 18      1     2       8    3    5    0
         2     7       8    2    0    7
         3    10       8    2    3    0
 19      1     3       8    6    6    0
         2     5       7    4    0    5
         3    10       5    4    5    0
 20      1     2      10    8    9    0
         2     7       7    6    0    9
         3     9       5    3    8    0
 21      1     1       7    4    8    0
         2     3       6    3    0    7
         3     5       6    3    7    0
 22      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   16   61   63
************************************************************************
