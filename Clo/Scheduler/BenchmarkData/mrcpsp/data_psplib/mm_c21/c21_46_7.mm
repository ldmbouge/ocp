************************************************************************
file with basedata            : c2146_.bas
initial value random generator: 1397095781
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
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
   2        3          3           6   7  10
   3        3          3           5   6  10
   4        3          3           9  10  11
   5        3          3           8  11  14
   6        3          2          13  14
   7        3          2           8  11
   8        3          1           9
   9        3          2          12  13
  10        3          2          12  14
  11        3          2          12  13
  12        3          3          15  16  17
  13        3          3          15  16  17
  14        3          3          15  16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5      10    3    8    8
         2     7       8    3    7    5
         3     9       7    2    7    5
  3      1     3       6    9   10    2
         2     8       4    8    7    1
         3    10       3    8    6    1
  4      1     4       7    3    4    9
         2     5       5    2    4    9
         3    10       4    2    3    8
  5      1     1       9    7   10    2
         2     6       9    6    9    1
         3    10       8    3    8    1
  6      1     1       7    2    9    8
         2     3       7    2    9    6
         3     8       6    2    8    6
  7      1     2       7    9    7    4
         2     4       6    3    4    1
         3     4       5    1    5    3
  8      1     2       9    5    4   10
         2     6       5    4    4    9
         3     9       3    3    1    7
  9      1     1       6    7    9    6
         2     6       5    4    6    5
         3     7       4    3    4    4
 10      1     5       5    8    6    7
         2     6       4    8    4    6
         3     9       3    8    3    2
 11      1     1       8    6    4    5
         2     5       7    6    4    5
         3     7       7    5    3    5
 12      1     1       9    5    2   10
         2     7       7    4    2    9
         3     8       5    2    1    9
 13      1     2       2    6    7    7
         2     4       2    5    6    5
         3     8       1    5    6    4
 14      1     2       9    8    6    4
         2     3       6    7    5    4
         3     8       4    7    5    2
 15      1     5       8    4    7    6
         2     6       7    3    6    6
         3     7       7    3    1    6
 16      1     1      10    5    5    2
         2     1       9    7    5    2
         3     6       8    4    5    2
 17      1     1       5    6    7    6
         2     7       4    6    6    5
         3     9       4    5    6    2
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   14   88   81
************************************************************************
