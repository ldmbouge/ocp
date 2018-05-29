************************************************************************
file with basedata            : md295_.bas
initial value random generator: 92581111
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  142
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       26        3       26
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           9  10  18
   3        3          3           5   7  12
   4        3          3           7  14  19
   5        3          3           6   8  10
   6        3          1          11
   7        3          1          15
   8        3          3          16  18  19
   9        3          2          12  15
  10        3          2          13  14
  11        3          3          13  17  18
  12        3          2          13  16
  13        3          1          19
  14        3          1          15
  15        3          1          16
  16        3          1          17
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     8       6    7    6    4
         2     8       4    8    9    5
         3    10       2    4    3    2
  3      1     5      10    7    6    9
         2     8       9    5    6    6
         3    10       9    3    3    5
  4      1     4       8    6    7    7
         2     7       6    6    6    4
         3     7       5    6    7    6
  5      1     4      10    4    8    7
         2     7       9    3    5    6
         3     8       9    2    3    6
  6      1     4       8    8    3    7
         2     7       6    5    3    5
         3     9       6    2    3    1
  7      1     1       3    7    7    9
         2     3       3    6    7    7
         3     7       2    5    6    6
  8      1     4       9    8    8    9
         2     5       6    8    8    7
         3     8       4    8    7    7
  9      1     2       5    4    6    8
         2     4       5    3    5    7
         3     5       4    2    4    6
 10      1     1       9    5    5    3
         2     2       8    5    4    2
         3     5       7    5    2    2
 11      1     2       7    5    7    4
         2     5       5    2    7    3
         3     8       4    1    6    2
 12      1     8       2    6    7   10
         2     8       3    7    6    9
         3     9       2    6    3    9
 13      1     3       9    9    7    7
         2     6       8    7    5    5
         3     7       8    6    4    4
 14      1     4       9    5    5    3
         2     7       6    5    5    3
         3     9       2    4    3    2
 15      1     2       5    9    9    8
         2     4       4    8    8    8
         3     8       3    7    8    6
 16      1     2      10    8    5    8
         2     4      10    8    2    6
         3     9      10    6    2    5
 17      1     3       6    6    8    6
         2     3       5    7    9    6
         3     4       5    3    7    4
 18      1     1       5   10    4   10
         2     9       4   10    4    4
         3    10       4   10    4    1
 19      1     5       9    8    9    3
         2     6       9    7    8    2
         3     9       8    6    4    1
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   26   24   89   86
************************************************************************
