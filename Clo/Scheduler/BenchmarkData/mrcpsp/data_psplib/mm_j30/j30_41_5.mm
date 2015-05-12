************************************************************************
file with basedata            : mf41_.bas
initial value random generator: 1878439080
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  32
horizon                       :  231
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     30      0       36        8       36
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          11  14  28
   3        3          3           5   7   8
   4        3          2          20  24
   5        3          3           6  15  25
   6        3          3          13  21  26
   7        3          3          15  19  25
   8        3          3           9  12  15
   9        3          2          10  22
  10        3          1          17
  11        3          2          23  27
  12        3          1          14
  13        3          3          16  22  29
  14        3          1          16
  15        3          2          16  27
  16        3          1          23
  17        3          2          18  26
  18        3          1          19
  19        3          2          21  28
  20        3          1          22
  21        3          2          24  27
  22        3          2          23  31
  23        3          1          30
  24        3          2          29  30
  25        3          2          26  30
  26        3          2          28  31
  27        3          1          31
  28        3          1          29
  29        3          1          32
  30        3          1          32
  31        3          1          32
  32        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       3    0    6    7
         2     6       0    8    4    4
         3     7       0    5    2    2
  3      1     1       3    0    9    9
         2     3       3    0    9    8
         3     5       0    2    9    8
  4      1     6       8    0    9    8
         2     9       7    0    9    6
         3     9       7    0    7    7
  5      1     2       0    3    7    6
         2     8       4    0    7    3
         3    10       3    0    5    1
  6      1     2      10    0    8    8
         2     2       0   10    6    9
         3     4      10    0    4    8
  7      1     2       0    5    9    5
         2     2       0    2    9    8
         3    10       2    0    7    5
  8      1     5       0    3    7    4
         2     5       8    0    6    3
         3    10       7    0    5    2
  9      1     4       0    9    7    9
         2     5       6    0    7    7
         3     8       5    0    6    6
 10      1     6      10    0    7   10
         2     7       0    8    7   10
         3    10       2    0    7    9
 11      1     1       0    5    9    7
         2     2       1    0    8    6
         3     6       0    5    4    5
 12      1     1       8    0    9    4
         2     4       6    0    7    4
         3     7       0    8    7    4
 13      1     2       0    2    4    6
         2     2       5    0    4    6
         3     5       4    0    3    5
 14      1     1       7    0    6    6
         2     4       7    0    5    4
         3     4       0    1    6    5
 15      1     3       0    7    3    9
         2     5       3    0    3    7
         3     8       1    0    2    2
 16      1     2       8    0    8    9
         2     5       0    3    7    9
         3     7       6    0    6    9
 17      1     6       0    5    8    1
         2     8       0    5    5    1
         3    10       0    2    4    1
 18      1     1       3    0    4   10
         2     1       0    9    4    7
         3     2       0    8    2    6
 19      1     2       0    5    9    8
         2     3       8    0    9    7
         3     8       0    1    9    3
 20      1     3       8    0    2    3
         2     9       0    1    1    2
         3     9       8    0    1    3
 21      1     4       0    5   10    3
         2     6       0    2    9    3
         3     8       6    0    9    3
 22      1     6       9    0    8    9
         2     8       6    0    5    8
         3    10       4    0    1    7
 23      1     1       0    7    9    5
         2     6       0    6    9    4
         3     6       0    7    9    3
 24      1     4       0    9    5    7
         2     5       7    0    3    6
         3     6       0    6    3    6
 25      1     3       7    0    9    9
         2     6       4    0    3    8
         3     6       0    5    5    8
 26      1     2       6    0   10    4
         2     4       0    5    9    3
         3    10       4    0    9    1
 27      1     3       4    0    9    9
         2    10       3    0    9    1
         3    10       4    0    7    1
 28      1     1       0    8    8    4
         2     7       8    0    5    4
         3     8       5    0    2    4
 29      1     1       6    0    7    3
         2     1       0    6    7    2
         3     9       0    6    1    2
 30      1     3       0    4    5    7
         2     7       3    0    4    5
         3     9       3    0    3    5
 31      1     4       3    0    5   10
         2    10       3    0    4    5
         3    10       0    4    3    8
 32      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   13  181  168
************************************************************************
