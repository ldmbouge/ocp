NAME          WOLSEY1
OBJSENSE
 MAX
ROWS
 N  COST
 L  LIM1
 G  LIM2
 L  LIM3
COLUMNS
 X1        COST                 2   LIM1                 5
 X1        LIM2                 8   LIM3                 1
 X2        COST                 1   LIM1                 -2
 X2        LIM2                 3   LIM3                 1
 X3        COST                 -1   LIM1                 8
 X3        LIM2                 -1   LIM3                 1
RHS
 RHS1      LIM1                15   LIM2                9
 RHS1      LIM3                6
BOUNDS
 UP BND1      X1                 3
 UP BND1      X2                 1
 LO BND1      X3                 1
ENDATA
