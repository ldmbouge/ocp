************************************************************************
file with basedata            : c2112_.bas
initial value random generator: 1607586242
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  122
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20        5       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   9  10
   3        3          3           5   7   8
   4        3          3           5   7   8
   5        3          3           6   9  10
   6        3          2          12  15
   7        3          3          12  13  14
   8        3          3           9  10  14
   9        3          1          11
  10        3          3          13  15  16
  11        3          3          12  13  15
  12        3          2          16  17
  13        3          1          17
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       0    4    0   10
         2     1      10    0    0   10
         3     3       0    3    0    9
  3      1     3       0   10    6    0
         2     7       0   10    0    9
         3    10       0    9    4    0
  4      1     2       3    0    8    0
         2     2       0    5    0   10
         3     3       3    0    0    8
  5      1     5       0    6    9    0
         2     8       0    6    0    7
         3     8       3    0    6    0
  6      1     4       0    5    8    0
         2     7       0    4    7    0
         3    10       9    0    0    6
  7      1     2       0    5    0    4
         2     7       0    2    0    4
         3     8       2    0    0    3
  8      1     3       0    2    9    0
         2     3       6    0    0    6
         3     8       3    0    0    5
  9      1     1       0    8   10    0
         2     6       0    6    6    0
         3     9       9    0    0    3
 10      1     2       0   10    0    6
         2     8       0   10    9    0
         3     8       0   10    0    4
 11      1     2       0    7    0    7
         2     5       9    0    0    6
         3     7       4    0    0    6
 12      1     1       0    5    5    0
         2     6       0    4    5    0
         3     7       5    0    4    0
 13      1     3       5    0    4    0
         2     4       4    0    0    9
         3     8       4    0    0    3
 14      1     4       0    7    0    5
         2     5       0    6    2    0
         3     6       0    2    0    3
 15      1     1       0    9    0    7
         2     4       0    9    7    0
         3     8       8    0    0    5
 16      1     1       0    9    6    0
         2     7       4    0    0    8
         3    10       0    9    3    0
 17      1     6       8    0    4    0
         2     7       4    0    0    8
         3     9       2    0    3    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   20   30   46   62
************************************************************************
