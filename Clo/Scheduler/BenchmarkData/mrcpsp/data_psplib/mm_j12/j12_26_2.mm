************************************************************************
file with basedata            : md90_.bas
initial value random generator: 97641695
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  102
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       17        4       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   9  13
   3        3          3           5   6   7
   4        3          3           5   6   7
   5        3          2           8  12
   6        3          3           9  11  13
   7        3          2          11  12
   8        3          2          10  11
   9        3          1          12
  10        3          1          13
  11        3          1          14
  12        3          1          14
  13        3          1          14
  14        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       3    0    4    0
         2     7       3    0    3    0
         3     7       0    6    3    0
  3      1     5       8    0    2    0
         2     9       0    8    0    7
         3    10       5    0    0    7
  4      1     5       8    0    4    0
         2     8       0    8    2    0
         3    10       4    0    0    6
  5      1     2       8    0   10    0
         2     4       7    0   10    0
         3     8       6    0   10    0
  6      1     5       0    2    2    0
         2     5       3    0    3    0
         3    10       3    0    0   10
  7      1     2       0    5    9    0
         2     4       3    0    5    0
         3     9       2    0    4    0
  8      1     2       0    4    7    0
         2     6       0    3    6    0
         3     6       7    0    0    6
  9      1     1       8    0    5    0
         2     2       6    0    0    3
         3    10       4    0    5    0
 10      1     1       4    0    0    5
         2     4       4    0    9    0
         3     6       3    0    0    3
 11      1     7       0   10    3    0
         2     9       4    0    0    6
         3    10       0   10    0    4
 12      1     4       0    8    0    6
         2     4       6    0    4    0
         3     7       0    7    0    5
 13      1     3       4    0    0    8
         2     8       0    9    0    6
         3     9       4    0    3    0
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   14   63   57
************************************************************************
