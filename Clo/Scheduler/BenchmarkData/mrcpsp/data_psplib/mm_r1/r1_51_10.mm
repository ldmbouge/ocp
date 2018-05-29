************************************************************************
file with basedata            : cr151_.bas
initial value random generator: 1588388805
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  117
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17       12       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           6  13
   3        3          3           6   7   8
   4        3          3           5   9  14
   5        3          1          15
   6        3          2          10  12
   7        3          2           9  14
   8        3          3           9  10  11
   9        3          1          13
  10        3          2          16  17
  11        3          2          12  15
  12        3          2          14  17
  13        3          3          15  16  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       5    5    9
         2     4       5    5    7
         3     4       0    4    8
  3      1     2       0    7    5
         2     4      10    4    4
         3     6       0    4    3
  4      1     1       6    9    6
         2     2       0    8    5
         3     8       5    6    5
  5      1     1       6    6   10
         2     8       4    5    5
         3     9       0    5    4
  6      1     1      10    4    4
         2     4       0    4    3
         3    10      10    3    3
  7      1     1       9    8    9
         2     4       0    7    7
         3     4       0    5    8
  8      1     3       8    9    3
         2     5       0    4    2
         3    10       6    3    2
  9      1     3       7    6    6
         2     9       4    3    3
         3     9       0    4    4
 10      1     3       9    9    9
         2     7       0    7    9
         3    10       0    5    8
 11      1     4       5    2    9
         2     5       0    2    6
         3     8       3    1    4
 12      1     2       8    8    4
         2     3       8    7    4
         3     8       0    6    4
 13      1     4       0    6    9
         2     6       0    3    5
         3     6       0    4    3
 14      1     1       7    5    2
         2     3       0    3    1
         3     7       6    2    1
 15      1     3       6    7    8
         2     9       0    7    2
         3     9       0    6    6
 16      1     2       0    6    7
         2     3       4    3    5
         3     4       0    2    4
 17      1     5       5    1    8
         2     5       0    6    6
         3     5       0    3    8
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   20   92   98
************************************************************************
