************************************************************************
file with basedata            : md289_.bas
initial value random generator: 1124
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  152
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       19        5       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           8
   3        3          1           6
   4        3          3           5   7  13
   5        3          3           9  11  14
   6        3          3          12  13  14
   7        3          3           9  10  11
   8        3          3          13  14  17
   9        3          1          16
  10        3          2          15  17
  11        3          3          12  17  18
  12        3          1          16
  13        3          1          15
  14        3          2          18  19
  15        3          2          16  18
  16        3          1          19
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       0    5    3    7
         2     6       0    1    3    3
         3     6      10    0    3    1
  3      1     1       3    0    6    7
         2     9       1    0    5    5
         3     9       1    0    4    6
  4      1     4       8    0    2    6
         2     4       0    2    2    5
         3     7       8    0    2    5
  5      1     2       7    0    8    9
         2     3       3    0    5    8
         3    10       1    0    4    7
  6      1     1       6    0    4   10
         2     3       0    3    4    6
         3     9       6    0    3    4
  7      1     1       0    5    7    5
         2     2       5    0    6    5
         3     6       0    5    2    5
  8      1     4       6    0    9    9
         2     8       0    5    8    7
         3    10       0    4    5    6
  9      1     1       9    0    5    9
         2     3       0    8    4    9
         3    10       8    0    4    8
 10      1     4       9    0    9    5
         2     7       8    0    3    5
         3     7       0    5    1    4
 11      1     4       5    0    7    8
         2     7       4    0    6    7
         3     8       2    0    6    6
 12      1     5       7    0    7    8
         2     6       6    0    7    6
         3     6       4    0    6    7
 13      1     3       0    3    7    5
         2    10      10    0    6    1
         3    10       0    2    4    3
 14      1     2       2    0    7    7
         2     9       0    7    7    5
         3    10       0    6    7    4
 15      1     1       4    0    6    5
         2     1       0    2    6    8
         3     9       4    0    6    4
 16      1     3       0    7   10    7
         2     6       0    3    9    6
         3    10       0    3    9    5
 17      1     3       0    4    7    5
         2     9       0    4    7    4
         3    10       9    0    6    3
 18      1     2       0    9    5    2
         2     5       0    8    3    1
         3     8       0    8    2    1
 19      1     1       8    0    8    3
         2     3       0    7    5    3
         3     7       0    4    2    2
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   10   11   86   88
************************************************************************
