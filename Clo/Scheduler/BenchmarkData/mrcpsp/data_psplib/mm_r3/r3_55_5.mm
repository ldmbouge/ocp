************************************************************************
file with basedata            : cr355_.bas
initial value random generator: 357724497
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  122
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       13       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7  17
   3        3          3           6  13  14
   4        3          3          10  12  16
   5        3          3           9  10  11
   6        3          1           8
   7        3          3           9  11  12
   8        3          3          10  12  17
   9        3          1          14
  10        3          1          15
  11        3          2          14  15
  12        3          1          15
  13        3          2          16  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     1       6    6    5    7    7
         2     1       7    6    5    7    6
         3     4       5    6    4    5    4
  3      1     5       5   10    4    1    8
         2     5       8    8    4    1    8
         3     9       2    7    4    1    7
  4      1     3       7   10    4    6    7
         2     8       6   10    4    4    6
         3     9       3    9    4    3    3
  5      1     1       9    5    4    9   10
         2     3       6    4    2    4    6
         3     8       4    3    1    3    5
  6      1     1       9   10    8    6    8
         2     3       7    7    6    5    7
         3    10       2    6    5    5    5
  7      1     7       6    8    7    8    8
         2     7       7   10    7    8    7
         3     9       6    7    5    2    5
  8      1     2       9    8    6   10   10
         2     3       5    7    5    9    9
         3     4       2    7    1    8    9
  9      1     5       3    9    7    8    3
         2     5       4    9    7    6    3
         3     7       2    8    7    4    3
 10      1     1       6    2    5    6    8
         2     3       6    2    5    5    5
         3    10       5    2    4    2    3
 11      1     2       6    8    9    7    8
         2     5       4    8    9    6    5
         3    10       4    8    9    6    4
 12      1     6       6    9    3    8    2
         2     6       5   10    3    8    2
         3     7       4    8    2    6    1
 13      1     2       8    4    8    4    2
         2     4       7    2    5    3    2
         3     7       6    1    3    2    1
 14      1     2       8    5    6    5    8
         2     6       4    5    5    4    7
         3     6       6    3    5    5    7
 15      1     5       5   10    4    9    8
         2     7       4   10    3    7    8
         3     8       3    9    3    4    7
 16      1     2       7    8    4    7    7
         2     3       5    7    2    7    3
         3     5       4    6    1    6    1
 17      1     2       4   10    7    5    9
         2     6       3   10    7    3    9
         3     9       3    9    6    2    8
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   25   32   26   95  103
************************************************************************
