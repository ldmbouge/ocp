************************************************************************
file with basedata            : md163_.bas
initial value random generator: 60288164
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  108
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       29        8       29
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6  13  15
   3        3          2           5   6
   4        3          2           9  10
   5        3          3           7   8   9
   6        3          2          11  12
   7        3          3          10  11  13
   8        3          3          13  14  15
   9        3          1          12
  10        3          2          12  15
  11        3          1          14
  12        3          1          14
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       8    0    2    7
         2     4       0    6    2    5
         3     7       0    4    1    3
  3      1     1       7    0    5    6
         2     1       0    4    5    5
         3     5       7    0    3    5
  4      1     2       3    0    5    8
         2     2       0    7    5    6
         3     6       4    0    5    2
  5      1     8       8    0    5    6
         2     9       6    0    4    5
         3    10       0    6    4    5
  6      1     3      10    0    5    8
         2     6       0    8    5    5
         3    10       7    0    4    1
  7      1     5       0    9    8    9
         2     6       7    0    6    8
         3     7       0    8    6    8
  8      1     2       9    0    5    9
         2     4       7    0    4    8
         3     5       4    0    4    8
  9      1     5       8    0    6    3
         2     8       4    0    5    3
         3     9       4    0    3    3
 10      1     7       4    0    9    5
         2     8       4    0    7    4
         3     9       0    4    4    3
 11      1     2       5    0    5    4
         2     5       0    4    5    3
         3     7       0    3    4    2
 12      1     3       0    6    6    6
         2     4       0    5    4    6
         3     5       8    0    3    5
 13      1     1       8    0    9    7
         2     7       0    9    9    6
         3    10       6    0    9    3
 14      1     5       0    8    2    6
         2     5       4    0    2    6
         3     8       2    0    1    6
 15      1     1       0    5    1    3
         2     2       4    0    1    2
         3    10       0    5    1    2
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   14   57   64
************************************************************************
