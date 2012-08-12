//
//  AppDelegate.m
//  SportDemo
//
//  Created by Pascal Van Hentenryck on 7/7/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "AppDelegate.h"
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

@implementation AppDelegate {
   ORInt _canPause;
   dispatch_queue_t _queue;
}
@synthesize mtxView = _mtxView;
@synthesize sportView = _sportView;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   // Insert code here to initialize your application
   _canPause = true;
   _queue =dispatch_get_main_queue();
   _topBoard = [[NSBoardController alloc] initBoardController: _sportView];
 
}

- (IBAction)run:(id)sender {
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
}

- (IBAction)stop:(id)sender {
   _canPause = false;
}

- (IBAction)pause:(id)sender {
   [_topBoard resume];
}

-(void) display: (ORClosure) cl
{
   dispatch_async(_queue,cl);
}
-(void)visualize:(id<ORIntVarMatrix>) game teams: (id<ORIntVarMatrix>) teams on: (id<CPSolver>)cp
{
   id<ORIntRange> Periods = [game range: 0];
   id<ORIntRange> Weeks = [game range: 1];
   [_mtxView setCellClass: [NSTextFieldCell class]];
   [_mtxView setAutosizesCells:true];

   [_mtxView renewRows: Periods.up  columns: Weeks.up];
   [_mtxView sizeToCells];
   
   id grid = [_topBoard makeGrid: Periods by: Weeks];
   NSFont* theFont = [NSFont menuFontOfSize:18.0];
   for(ORInt p = [Periods low]; p <= [Periods up]; p++)
      for(ORInt w = [Weeks low]; w <= [Weeks up]; w++) {
         [self display: ^ {
            [[_mtxView cellAtRow:p-1 column:w-1] setStringValue: @""];
            [[_mtxView cellAtRow:p-1 column:w-1] setDrawsBackground:true];
            [[_mtxView cellAtRow:p-1 column:w-1] setAlignment: NSCenterTextAlignment];
            [[_mtxView cellAtRow:p-1 column:w-1] setFont: theFont];
         }];
         id<ORIntVar> x = [game at:p:w];
         [cp add: [CPFactory watchVariable:x
                            onValueLost: nil
                            onValueBind:^void(ORInt val) {
                               [self display: ^{
                                  [_topBoard toggleGrid:grid row: Periods.up - p + 1 col: w to:Required];
                                  NSString* txt = [NSString stringWithFormat:@"%d - %d",[[teams at: p : w : 0] min],[[teams at: p : w : 1] min]];
                                  [[_mtxView cellAtRow:p-1 column:w-1] setStringValue:txt];
                                  [[_mtxView cellAtRow:p-1 column:w-1] setBackgroundColor: [NSColor yellowColor]];
                               }];
                               if (_canPause)
                                 [_topBoard pause];
                            }
                            onValueRecover: nil
                            onValueUnbind:^void(ORInt val) {
                               [self display: ^{
                                  [_topBoard toggleGrid:grid row: Periods.up - p + 1 col:w to:Possible];
                                  [[_mtxView cellAtRow:p-1 column:w-1] setStringValue: @""];
                                  [[_mtxView cellAtRow:p-1 column:w-1] setBackgroundColor: [NSColor redColor]];
                               }];
                          }
                ]];
   }
   /*
   [_board watchSearch:cp
              onChoose: ^void() { [_board pause];}
                onFail: ^void() { [_board pause];}
    ];
    */
}

-(void) main
{
   CPLong startTime = [CPRuntimeMonitor cputime];
   ORInt n = 14;
    
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> Periods = RANGE(cp,1,n/2);
   id<ORIntRange> Teams = RANGE(cp,1,n);
   id<ORIntRange> Weeks = RANGE(cp,1,n-1);
   id<ORIntRange> EWeeks = RANGE(cp,1,n);
   id<ORIntRange> HomeAway = RANGE(cp,0,1);
   id<ORIntRange> Games = RANGE(cp,0,n*n);
   id<ORIntArray> c = [CPFactory intArray:cp range:Teams with: ^CPInt(ORInt i) { return 2; }];
   id<ORIntVarMatrix> team = [CPFactory intVarMatrix:cp range: Periods : EWeeks : HomeAway domain:Teams];
   id<ORIntVarMatrix> game = [CPFactory intVarMatrix:cp range: Periods : Weeks domain:Games];
   id<ORIntVarArray> allteams =  [CPFactory intVarArray:cp range: Periods : EWeeks : HomeAway
                                                   with: ^id<ORIntVar>(ORInt p,ORInt w,ORInt h) { return [team at: p : w : h]; }];
   id<ORIntVarArray> allgames =  [CPFactory intVarArray:cp range: Periods : Weeks
                                                   with: ^id<ORIntVar>(ORInt p,ORInt w) { return [game at: p : w]; }];
   id<CPTable> table = [CPFactory table: cp arity: 3];
   for(ORInt i = 1; i <= n; i++)
      for(ORInt j = i+1; j <= n; j++)
         [table insert: i : j : (i-1)*n + j-1];
   
   [cp solve:
    ^() {
       for(ORInt w = 1; w < n; w++)
          for(ORInt p = 1; p <= n/2; p++)
             [cp add: [CPFactory table: table on: [team at: p : w : 0] : [team at: p : w : 1] : [game at: p : w]]];
       [cp add: [CPFactory alldifferent:allgames]];
       for(ORInt w = 1; w <= n; w++)
          [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: Periods : HomeAway
                                                              with: ^id<ORIntVar>(ORInt p,ORInt h) { return [team at: p : w : h ]; } ]]];
       for(ORInt p = 1; p <= n/2; p++)
          [cp add: [CPFactory cardinality: [CPFactory intVarArray: cp range: EWeeks : HomeAway
                                                             with: ^id<ORIntVar>(ORInt w,ORInt h) { return [team at: p : w : h ]; }]
                                      low: c
                                       up: c
                              consistency:DomainConsistency]];
       [self visualize:game teams: team on:cp];
    }
       using:
    ^() {
       /*
        for(ORInt p = 1; p <= n/2 ; p++) {
        id<ORIntVarArray> ap =  [CPFactory intVarArray:cp range: Weeks with: ^id<ORIntVar>(ORInt w) { return [game at: p : w]; }];
        id<ORIntVarArray> aw =  [CPFactory intVarArray:cp range: Periods with: ^id<ORIntVar>(ORInt w) { return [game at: w : p]; }];
        [CPLabel array: ap orderedBy: ^CPInt(ORInt i) { return [[ap at:i] domsize];}];
        [CPLabel array: aw orderedBy: ^CPInt(ORInt i) { return [[aw at:i] domsize];}];
        }
        */
       [CPLabel array: allgames orderedBy: ^CPInt(ORInt i) { return [[allgames at:i] domsize];}];
       [CPLabel array: allteams orderedBy: ^CPInt(ORInt i) { return [[allteams at:i] domsize];}];
       CPLong endTime = [CPRuntimeMonitor cputime];
       printf("Solution \n");
       for(ORInt p = 1; p <= n/2; p++) {
          for(ORInt w = 1; w < n; w++)
             printf("%2d-%2d [%3d]  ",[[team at: p : w : 0] min],[[team at: p : w : 1] min],[[game at: p : w] min]);
          printf("\n");
       }
       printf("Execution Time: %lld \n",endTime - startTime);
      [_topBoard pause];
    }
    ];

   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
}

@end
