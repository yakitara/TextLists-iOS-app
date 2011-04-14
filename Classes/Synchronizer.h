// -*-ObjC-*-
#import <Foundation/Foundation.h>


@interface Synchronizer : NSObject {
    NSMutableArray *m_postQueue;
}
@property (nonatomic, retain) NSMutableArray *postQueue;
+ (void)sync;
@end
