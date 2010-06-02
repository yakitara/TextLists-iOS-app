// ;-*-ObjC-*-
#import <UIKit/UIKit.h>

// This is to share a single instance of fetched results controller from multiple instance of table view controllers
// which keep consistend results.
@interface DelegatingFetchedResultsController : NSFetchedResultsController <NSFetchedResultsControllerDelegate> {
    NSMutableArray *m_tableViews;
}
@property (nonatomic, retain, readonly) NSMutableArray *tableViews;

- (void)addTableView:(UITableView *)tableview;
- (void)removeTableView:(UITableView *)tableview;
@end
