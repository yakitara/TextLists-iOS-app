#import "UITableViewControllerCategories.h"


@implementation UITableViewController ( Reorder )
- (NSArray *)reorderedArrayAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    NSInteger count = [self.tableView numberOfRowsInSection:0];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        [array addObject:[NSNumber numberWithInt:i]];
    }
    [array removeObjectAtIndex:toIndexPath.row];
    [array insertObject:[NSNumber numberWithInt:toIndexPath.row] atIndex:fromIndexPath.row];
    return array;
}
@end
