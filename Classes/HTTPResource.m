#import "HTTPResource.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"

@interface HTTPResource ()
+ (id)handleRequest:(ASIHTTPRequest *)request;
@end

@implementation HTTPResource
+ (id)getJSONValueFromURL:(NSURL *)url {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request startSynchronous];
    NSError *error = [request error];
    if (error) {
        [error prettyPrint];
        abort(); // TODO: store error info and skip
    }
    NSString *jsonString = [request responseString];
    NSLog(@"getJSONValueFromURL:%@ -> %@", url, jsonString);
    return [jsonString JSONValue];
}

+ (id)postJSONValue:(id)value toURL:(NSURL *)url {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[value JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    request.requestMethod = @"POST";
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
#if 1
    return [self handleRequest:request];
#else
    [request startSynchronous];
    NSError *error = [request error];
    if (error) {
        [error prettyPrint];
        abort(); // TODO: store error info and skip
    }
    //TODO: if (request.responseStatusCode == 200) raise exception?
    NSString *jsonString = [request responseString];
    return [jsonString JSONValue];
#endif
}

+ (id)putJSONValue:(id)value onURL:(NSURL *)url {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[value JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    request.requestMethod = @"PUT";
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    return [self handleRequest:request];
}

+ (id)handleRequest:(ASIHTTPRequest *)request {
    [request startSynchronous];
    NSError *error = [request error];
    if (error) {
        [error prettyPrint];
        abort(); // TODO: store error info and skip
    }
    //TODO: if (request.responseStatusCode == 200) raise exception?
    NSString *jsonString = [request responseString];
    return [jsonString JSONValue];
}
@end
