************************************************************************
file with basedata            : me48_.bas
initial value random generator: 1421865754
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  150
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       25        3       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8   9
   3        3          3           6   9  12
   4        3          2           7  13
   5        3          2          14  15
   6        3          3          10  14  16
   7        3          1          17
   8        3          1          14
   9        3          2          15  16
  10        3          2          11  18
  11        3          3          13  15  19
  12        3          2          19  20
  13        3          2          17  20
  14        3          1          18
  15        3          2          20  21
  16        3          3          17  18  19
  17        3          1          21
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
         2     3       6    7
         3     6       4    4
  3      1     1       8    5
         2     4       8    4
         3     6       5    3
  4      1     1       8    9
         2     4       7    7
         3     8       7    5
  5      1     5      10    8
         2     5       7    9
         3     9       2    2
  6      1     2       6    8
         2     7       6    7
         3     8       5    5
  7      1     2       8    8
         2     3       6    8
         3     4       6    3
  8      1     4       9    3
         2     6       5    2
         3     8       3    1
  9      1     4       5    4
         2     5       5    2
         3    10       4    1
 10      1     4       8   10
         2     6       6    5
         3     6       8    3
 11      1     4       8    4
         2     6       5    3
         3     8       4    2
 12      1     4       9    7
         2     5       6    5
         3     6       3    5
 13      1     3       4    8
         2     5       2    8
         3     8       2    7
 14      1     1      10    9
         2     7       8    9
         3     8       7    9
 15      1     2       6    7
         2     3       4    5
         3     3       3    6
 16      1     5       7    7
         2     6       7    4
         3     7       6    2
 17      1     5       3    5
         2     9       2    5
         3    10       1    4
 18      1     2       5   10
         2     9       4   10
         3    10       2    9
 19      1     1       6    9
         2     3       5    7
         3     6       5    6
 20      1     4       6    7
         2     7       5    5
         3     9       3    4
 21      1     6       5    5
         2     7       2    5
         3    10       1    5
 22      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   41   34
************************************************************************
