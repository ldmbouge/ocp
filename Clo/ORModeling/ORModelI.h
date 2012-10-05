/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>

@interface ORModelI : NSObject<ORModel>
-(ORModelI*)              initORModelI;
-(void)                   dealloc;
-(NSString*)              description;
-(void)                   setId: (ORUInt) name;
-(void)                   applyOnVar:(void(^)(id<ORObject>))doVar
                           onObjects:(void(^)(id<ORObject>))doObjs
                       onConstraints:(void(^)(id<ORObject>))doCons
                         onObjective:(void(^)(id<ORObject>))doObjective;
-(id<ORObjectiveFunction>)objective;
-(void) visit: (id<ORVisitor>) visitor;
@end