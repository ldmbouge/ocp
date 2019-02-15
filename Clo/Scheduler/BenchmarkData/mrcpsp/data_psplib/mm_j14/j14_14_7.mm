************************************************************************
file with basedata            : md142_.bas
initial value random generator: 147230036
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  116
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       20       11       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   8
   3        3          3           5   7  12
   4        3          3           5   8  12
   5        3          1          11
   6        3          2           7   9
   7        3          2          11  13
   8        3          2          11  13
   9        3          1          10
  10        3          3          12  14  15
  11        3          2          14  15
  12        3          1          13
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3      10    6    0    6
         2     8      10    6    8    0
         3     8      10    5    0    3
  3      1     1       8    4    0    7
         2     2       6    4    0    7
         3     9       5    3    0    6
  4      1     3       5    8    3    0
         2     6       5    5    0    1
         3    10       4    2    2    0
  5      1     1       6    5   10    0
         2     1      10    6    0    4
         3     2       3    5    9    0
  6      1     7       8    5    0   10
         2     8       5    3    6    0
         3     9       5    3    0    8
  7      1     3       8    5    9    0
         2     4       6    3    8    0
         3     5       3    3    0    6
  8      1     1       2    4    7    0
         2     8       2    3    0   10
         3     9       1    3    0    9
  9      1     1       7    2    8    0
         2     2       6    1    0    6
         3    10       3    1    1    0
 10      1     1       5    6    6    0
         2     1       6    5    6    0
         3     7       5    3    4    0
 11      1     2       8    3    0    8
         2     3       8    2    0    6
         3     8       8    2    0    5
 12      1     3       9    9    0    8
         2     4       9    6    0    7
         3    10       9    5    0    6
 13      1     5       5    2    9    0
         2    10       3    2    6    0
         3    10       3    2    0    9
 14      1     2       9   10    0    9
         2     4       8    9    7    0
         3     9       6    7    0    5
 15      1     2       3    8    5    0
         2     4       3    8    0    2
         3    10       2    8    0    2
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   14   41   52
************************************************************************
