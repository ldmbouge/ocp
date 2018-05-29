************************************************************************
file with basedata            : me48_.bas
initial value random generator: 695357850
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  158
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       20        5       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6  10  14
   3        3          3           7   9  10
   4        3          1           5
   5        3          2          14  19
   6        3          1          17
   7        3          3           8  12  15
   8        3          3          13  18  20
   9        3          3          11  12  13
  10        3          2          13  15
  11        3          2          14  15
  12        3          2          16  18
  13        3          1          16
  14        3          1          18
  15        3          3          19  20  21
  16        3          2          17  21
  17        3          1          19
  18        3          1          21
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     3       5   10
         2     6       5    9
         3    10       4    9
  3      1     5       6    7
         2     5       5    8
         3     8       5    4
  4      1     3       4    9
         2     6       2    6
         3     8       2    4
  5      1     6       5    5
         2     7       4    5
         3     8       1    4
  6      1     6       5    7
         2     8       5    5
         3     9       5    4
  7      1     2       6    6
         2     4       4    6
         3     7       1    6
  8      1     2       6    4
         2     3       4    3
         3     5       3    3
  9      1     3       6    2
         2     4       4    2
         3     8       1    1
 10      1     4       2    5
         2     6       1    4
         3     6       2    2
 11      1     3       5    5
         2     4       3    5
         3     7       2    4
 12      1     2       7    2
         2     8       7    1
         3     9       6    1
 13      1     5       5    6
         2    10       4    3
         3    10       2    5
 14      1     5       8    6
         2     5       9    4
         3     9       5    2
 15      1     3       8    9
         2     4       5    7
         3     6       4    7
 16      1     1       4    6
         2     7       3    6
         3     8       1    6
 17      1     2       7    7
         2     4       6    7
         3     8       4    5
 18      1     2       8    8
         2     8       8    6
         3    10       8    4
 19      1     3       7    8
         2     3       9    7
         3     6       5    4
 20      1     1       7    7
         2     1       8    6
         3     7       5    6
 21      1     1       9    7
         2     6       5    6
         3     9       3    6
 22      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   30   28
************************************************************************
