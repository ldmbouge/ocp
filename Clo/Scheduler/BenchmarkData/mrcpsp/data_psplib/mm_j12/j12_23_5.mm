************************************************************************
file with basedata            : md87_.bas
initial value random generator: 885864582
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  97
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       16       10       16
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   9  13
   3        3          3           6   7   8
   4        3          2           5   8
   5        3          3           6   7   9
   6        3          1          12
   7        3          3          10  11  12
   8        3          3          10  11  12
   9        3          1          11
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
  2      1     6       6    9    0    5
         2     7       6    8    0    5
         3     7       6    7    3    0
  3      1     3      10    3    7    0
         2     4       8    2    5    0
         3    10       7    2    0    1
  4      1     4       6    9    0    3
         2     6       4    7    5    0
         3     6       3    7    0    3
  5      1     3       6    3    6    0
         2     8       5    2    1    0
         3     8       5    1    0    7
  6      1     4      10    9    4    0
         2     5       4    7    4    0
         3     8       3    4    3    0
  7      1     2       7    8    0    9
         2     4       6    8    0    9
         3     9       3    8    0    8
  8      1     6       6    8    0    6
         2     6       7    9    3    0
         3     9       4    8    2    0
  9      1     5       8    9    0    7
         2     6       5    6    0    6
         3    10       4    2    0    4
 10      1     2       3    2    0    7
         2     6       2    2    0    6
         3     9       2    2    7    0
 11      1     4       5    7    6    0
         2     9       2    5    4    0
         3     9       3    1    0    5
 12      1     5       9    7    5    0
         2     7       6    7    0    7
         3     8       6    5    2    0
 13      1     2       6    5    4    0
         2     4       5    4    0    3
         3     4       2    1    0    5
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   26   28   38   50
************************************************************************
