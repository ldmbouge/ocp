//
//  ORSemBBController.h
//  Clo
//
//  Created by Rémy Garcia on 25/02/2019.
//

#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/cont.h>
#import <ORFoundation/ORController.h>
#import <ORFoundation/ORTracer.h>

@interface ORSemBBController : ORDefaultController <NSCopying,ORSearchController,ORStealing>
+(id<ORSearchController>)proto;
-(id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(ORInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
-(ORHeist*)steal;
@end

