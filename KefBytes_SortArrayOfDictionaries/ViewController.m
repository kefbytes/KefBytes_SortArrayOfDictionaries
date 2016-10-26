//
//  ViewController.m
//  KefBytes_SortArrayOfDictionaries
//
//  Created by Franks, Kent Eric on 10/18/16.
//  Copyright © 2016 KefBytes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *transactionsArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchJSONResourceWithName:(@"TransactionsArray") completionHandler:^(NSDictionary *json, NSError *error) {
        self.transactionsArray = json[@"PendingTransaction"];
        NSLog(@"transactionsArray = %@", self.transactionsArray);
    }];
}

- (void)fetchJSONResourceWithName:(NSString *)name completionHandler:(void(^)(NSDictionary *json, NSError *error))handler
{
    NSParameterAssert(handler != nil);
    
    NSURL *resourceURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"json"];
    if (!resourceURL) {
        // Should create an NSError and pass it to the completion handler
        NSAssert(NO, @"Could not find resource: %@", name);
    }
    
    NSError *error;
    
    // Fetch the json data. If there's an error, call the handler and return.
    NSData *jsonData = [NSData dataWithContentsOfURL:resourceURL options:NSDataReadingMappedIfSafe error:&error];
    if (!jsonData) {
        handler(nil, error);
        return;
    }
    
    // Parse the json data. If there's an error parsing the json data, call the handler and return.
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!json) {
        handler(nil, error);
        return;
    }
    
    // If the json data specified that we should delay the results, do so before calling the handler
    NSNumber *delayResults = json[@"delayResults"];
    if (delayResults && [delayResults isKindOfClass:[NSNumber class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([delayResults floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            handler(json, nil);
        });
    }
    else {
        handler(json, nil);
    }
}

- (IBAction)sortArray:(id)sender {
    NSSortDescriptor *sequenceDescriptor = [[NSSortDescriptor alloc]initWithKey:@"Sequence"  ascending:NO selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = @[sequenceDescriptor];
    NSArray *sortedArray = [self.transactionsArray sortedArrayUsingDescriptors:sortDescriptors];
    NSLog(@"sortedArray = %@", sortedArray);
}


@end
