************************************************************************
file with basedata            : cm457_.bas
initial value random generator: 1849263946
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  138
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17       11       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        4          3           5   6   7
   3        4          3           8  12  17
   4        4          3           9  11  17
   5        4          2           8  10
   6        4          2          12  17
   7        4          2           9  11
   8        4          1          13
   9        4          3          10  12  13
  10        4          2          14  15
  11        4          1          13
  12        4          2          14  15
  13        4          2          14  15
  14        4          1          16
  15        4          1          18
  16        4          1          18
  17        4          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       0    2    7    9
         2     2       0    1    6    9
         3     2       2    0    6    9
         4    10       0    2    4    9
  3      1     2       0   10    3    9
         2     6       3    0    3    9
         3     8       0    6    2    8
         4    10       0    1    2    8
  4      1     3       6    0    9    6
         2     3       8    0    8    7
         3     6       5    0    5    4
         4    10       3    0    5    4
  5      1     5       9    0    9    7
         2     7       7    0    8    7
         3     8       0    5    7    5
         4    10       0    4    5    4
  6      1     2       0    7    5    4
         2     2       7    0    5    4
         3     6       0    7    5    3
         4     6       6    0    3    4
  7      1     3       0    2    9    3
         2     5      10    0    7    3
         3     8       0    1    5    2
         4    10      10    0    5    2
  8      1     1       0   10    5    7
         2     3       0    9    4    6
         3     5       0    9    4    5
         4     9       0    9    4    4
  9      1     2       6    0    9    6
         2     4       5    0    6    5
         3     5       0    2    5    3
         4     8       5    0    1    2
 10      1     1       5    0    4    6
         2     3       0    8    3    6
         3     6       0    5    3    5
         4     7       3    0    3    5
 11      1     3       6    0    5   10
         2     3       7    0    7    9
         3     5       5    0    3    8
         4     5       0    5    3    9
 12      1     3       5    0    5    7
         2     4       0    5    5    4
         3     7       4    0    4    4
         4     8       0    3    3    2
 13      1     4       9    0    9    5
         2     7       0   10    9    5
         3     8       9    0    8    5
         4    10       8    0    7    4
 14      1     3       8    0    4    4
         2     8       5    0    4    3
         3     9       3    0    3    3
         4    10       2    0    3    2
 15      1     4       8    0    4    3
         2     7       5    0    3    3
         3     7       0    1    3    3
         4    10       5    0    2    2
 16      1     3       0    3    7    6
         2     4       6    0    6    5
         3     4       8    0    6    3
         4     5       4    0    6    3
 17      1     2       3    0    3    6
         2     9       0    3    3    4
         3    10       3    0    2    3
         4    10       2    0    3    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   12   13   99   99
************************************************************************
