#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORScheduler.h>
#import <ORSchedulingProgram/ORSchedulingProgram.h>

int main(const int argc, const char** argv)
{
	@autoreleasepool
	{
		id<ORModel> model = [ORFactory createModel];
		
		const int T = 300;
		id<ORIntRange> time = RANGE(model, 0, T);
		
		const int N = 10;
		id<ORIntRange> tasksRange = RANGE(model, 0, N-1);
		
		id<ORTaskVarArray> tasks = [ORFactory taskVarArray:model range:tasksRange with:^id<ORTaskVar>(ORInt i) {
			id<ORIntRange> r = RANGE(model, 10, 20);
			return [ORFactory task:model horizon:time durationRange:r];
//			return [ORFactory task:model horizon:time duration:10];
		}];
		
//		id<ORIntVarArray> start = [ORFactory intVarArray:model range:tasksRange with:^id<ORIntVar>(ORInt i) {
//			return [tasks[i] getStartVar];
//		}];
		
		// Adding resource constraints
		id<ORIntVar> RCap = [ORFactory intVar: model value:1];
		id<ORTaskCumulative> cumulative = [ORFactory cumulativeConstraint:RCap];
		for (ORInt i = tasksRange.low; i <= tasksRange.up; i++)
		{
			id<ORIntVar> x = [ORFactory intVar: model value:1];
			[cumulative add:tasks[i] with:x];
		}
		[model add: cumulative];
		
		id<CPProgram,CPScheduler> cp = [ORFactory createCPProgram: model];
		[cp solve:
			^() {
				// Search strategy
				for (ORInt i = tasksRange.low; i <= tasksRange.up; i++)
				{
					printf("labelling start[%d]\n",i);
					[cp labelActivity:tasks[i]];
				}
//				[cp setTimes:tasks];
//				[cp label: makespan];
				// Output of solution
//				printf("start = [");
				for (ORInt i = tasksRange.low; i <= tasksRange.up; i++)
				{
//					printf("%d %d-%d\n", [cp est:tasks[i]], [cp min:start[i]], [cp max:start[i]]);
					printf("%d-%d\n", [cp est:tasks[i]], [cp lst:tasks[i]]);
				}
//				printf("];\n");
//				printf("dur = [");
//				for (ORInt i = 0; i < n_act; i++) {
//					if (i > 0) printf(", ");
//					printf("%d", dur[i]);
//				}
//				printf("];\n");
//				printf("objective = %d;\n", [cp intValue: makespan]);
//				printf("----------\n");
			}
		 ];
		printf("Done\n");
	}
}