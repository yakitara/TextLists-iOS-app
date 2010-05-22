#import <Cocoa/Cocoa.h>

int main(int args, char *argv) {
    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSString *format = @"yyyy-MM-dd HH:mm:ss zzz";
    NSLog(@"format: %@", format);
    [dateFormatter setDateFormat:format];
    NSString *dateString = @"2010-05-20 01:02:30 +0900";
    NSLog(@"input date: %@", dateString);
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSLog(@"output date: %@", date);
    [autoreleasePool release];
    return 0;
}
