/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "AppDelegate.h"
#import <ORProgram/ORProgram.h>

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

- (IBAction)run:(id)sender
{
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
-(void)visualize:(id<ORIntVarMatrix>) game teams: (id<ORIntVarMatrix>) teams on: (id<CPProgram>)cp
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
         [cp addConstraintDuringSearch: [CPFactory solver:cp
                                            watchVariable:x
                            onValueLost: nil
                            onValueBind:^void(ORInt val) {
                               NSString* txt = [NSString stringWithFormat:@"%d - %d",
                                                [cp intValue:[teams at: p : w : 0]],
                                                [cp intValue:[teams at: p : w : 1]]];
                               [self display: ^{
                                  [_topBoard toggleGrid:grid row: Periods.up - p + 1 col: w to:Required];
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
   [_board watchSearch:[cp explorer]
              onChoose: ^void() { [_board pause];}
                onFail: ^void() { [_board pause];}
    ];
    */
}

-(void) main
{
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor cputime];
      ORInt n = 14;
      
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> Periods = RANGE(model,1,n/2);
      id<ORIntRange> Teams = RANGE(model,1,n);
      id<ORIntRange> Weeks = RANGE(model,1,n-1);
      id<ORIntRange> EWeeks = RANGE(model,1,n);
      id<ORIntRange> HomeAway = RANGE(model,0,1);
      id<ORIntRange> Games = RANGE(model,0,n*n);
      id<ORIntArray> c = [ORFactory intArray: model range:Teams with: ^ORInt(ORInt i) { return 2; }];
      id<ORIntVarMatrix> team = [ORFactory intVarMatrix: model range: Periods : EWeeks : HomeAway domain:Teams];
      id<ORIntVarMatrix> game = [ORFactory intVarMatrix: model range: Periods : Weeks domain:Games];
      id<ORIntVarArray> allteams =  [ORFactory intVarArray: model range: Periods : EWeeks : HomeAway
                                                      with: ^id<ORIntVar>(ORInt p,ORInt w,ORInt h) {
                                                         return [team at: p : w : h];
                                                      }];
      id<ORIntVarArray> allgames =  [ORFactory intVarArray: model range: Periods : Weeks
                                                      with: ^id<ORIntVar>(ORInt p,ORInt w) {
                                                         return [game at: p : w];
                                                      }];
      id<ORTable> table = [ORFactory table: model arity: 3];
      for(ORInt i = 1; i <= n; i++)
         for(ORInt j = i+1; j <= n; j++)
            [table insert: i : j : (i-1)*n + j-1];
      
      for(ORInt w = 1; w < n; w++)
         for(ORInt p = 1; p <= n/2; p++)
            [model add: [ORFactory tableConstraint:model
                                             table:table
                                                on: [team at: p : w : 0] : [team at: p : w : 1] : [game at: p : w]]];
      [model add: [ORFactory alldifferent: allgames]];
      for(ORInt w = 1; w <= n; w++)
         [model add: [ORFactory alldifferent: [ORFactory intVarArray: model range: Periods : HomeAway
                                                                with: ^id<ORIntVar>(ORInt p,ORInt h) {
                                                                   return [team at: p : w : h ];
                                                                } ]]];
      for(ORInt p = 1; p <= n/2; p++)
         [model add: [ORFactory cardinality: [ORFactory intVarArray: model range: EWeeks : HomeAway
                                                               with: ^id<ORIntVar>(ORInt w,ORInt h) {
                                                                  return [team at: p : w : h ];
                                                               }]
                                        low: c
                                         up: c]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      
      
      [cp solve: ^ {
         [self visualize:game teams: team on:cp];
         [cp labelArray: allgames orderedBy: ^ORDouble(ORInt i) { return [cp domsize:[allgames at:i]];}];
         [cp labelArray: allteams orderedBy: ^ORDouble(ORInt i) { return [cp domsize:[allteams at:i]];}];
         ORLong endTime = [ORRuntimeMonitor cputime];
         printf("Solution \n");
         for(ORInt p = 1; p <= n/2; p++) {
            for(ORInt w = 1; w < n; w++)
               printf("%2d-%2d [%3d]  ",[cp intValue:[team at: p : w : 0]],
                      [cp intValue:[team at: p : w : 1]],
                      [cp intValue:[game at: p : w]]);
            printf("\n");
         }
         printf("Execution Time: %lld \n",endTime - startTime);
         [_topBoard pause];
      }];
      
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [ORFactory shutdown];
   }
}

@end
