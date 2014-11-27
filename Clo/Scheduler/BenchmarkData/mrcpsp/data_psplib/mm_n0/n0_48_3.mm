************************************************************************
file with basedata            : me48_.bas
initial value random generator: 163814706
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  152
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       30       14       30
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5  18
   3        3          2           5   7
   4        3          3           7  13  18
   5        3          3           6  13  19
   6        3          3           8   9  14
   7        3          3           8  10  12
   8        3          2          11  20
   9        3          2          10  12
  10        3          1          11
  11        3          1          16
  12        3          3          15  17  21
  13        3          3          14  16  17
  14        3          2          15  21
  15        3          1          20
  16        3          1          21
  17        3          1          20
  18        3          1          19
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     1       6    5
         2     1       5    7
         3    10       4    5
  3      1     2       4   10
         2     3       3    7
         3     9       2    5
  4      1     1       9    8
         2     2       5    5
         3     5       3    5
  5      1     2       4    6
         2     5       3    4
         3    10       2    3
  6      1     4       9    6
         2     8       6    4
         3     9       5    4
  7      1     1       2    8
         2     4       2    5
         3     6       1    1
  8      1     4       6    6
         2     8       5    6
         3    10       3    5
  9      1     1       8    2
         2     3       7    2
         3     4       6    1
 10      1     3       4    7
         2     5       2    5
         3    10       1    1
 11      1     6       6    9
         2     7       5    7
         3     8       1    6
 12      1     1       6    7
         2     2       5    6
         3     2       4    7
 13      1     3      10    9
         2     7       7    8
         3    10       6    5
 14      1     1       7    4
         2     1       5    5
         3     7       4    3
 15      1     4       5   10
         2     6       5    9
         3     7       3    9
 16      1     5       7    6
         2     5      10    5
         3     6       3    4
 17      1     1      10    8
         2     5       7    6
         3    10       6    6
 18      1     1      10    4
         2     6       8    4
         3     7       7    3
 19      1     1       7    7
         2     3       6    6
         3     5       4    4
 20      1     2       5    7
         2     4       4    5
         3     7       4    3
 21      1     7       9    8
         2     8       8    7
         3    10       8    5
 22      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
   26   31
************************************************************************
