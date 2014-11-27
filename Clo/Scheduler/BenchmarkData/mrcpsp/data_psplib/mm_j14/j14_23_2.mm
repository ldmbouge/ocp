************************************************************************
file with basedata            : md151_.bas
initial value random generator: 1430219378
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  96
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       13       12       13
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   9  12
   3        3          2           5  13
   4        3          3           5   7   8
   5        3          1          15
   6        3          2          10  11
   7        3          3          10  12  14
   8        3          3          11  13  14
   9        3          3          10  11  14
  10        3          1          13
  11        3          1          15
  12        3          1          15
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       4    4    0    9
         2     2       2    2    0    5
         3     3       2    2    9    0
  3      1     5       9   10    0    2
         2     5       8   10    4    0
         3     6       5   10    0    2
  4      1     1      10    3    9    0
         2     1       9    4    0    9
         3     7       6    3    9    0
  5      1     4       4    9    5    0
         2     5       4    8    0    7
         3     8       4    5    0    4
  6      1     6       4    7   10    0
         2     8       3    5    6    0
         3     9       2    3    0    4
  7      1     5       7    4    4    0
         2     6       5    4    0    7
         3     9       4    3    0    7
  8      1     3       7    3    0    7
         2     3       5    2    4    0
         3     4       3    1    3    0
  9      1     1      10    7    5    0
         2     8       8    5    5    0
         3     8       6    3    0    3
 10      1     3       8    8    6    0
         2     4       6    7    0   10
         3     5       4    7    0   10
 11      1     4       7    8    2    0
         2     8       4    6    0    7
         3     8       5    5    2    0
 12      1     1       3    6    0    7
         2     2       1    6    0    6
         3     2       2    5    0    3
 13      1     2       6    4   10    0
         2     7       6    3    0   10
         3     8       6    1    0   10
 14      1     7       9   10    6    0
         2     9       8    8    0    1
         3    10       6    6    5    0
 15      1     1      10    8    3    0
         2     8       9    6    3    0
         3     9       8    5    2    0
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   30   29   58   63
************************************************************************
