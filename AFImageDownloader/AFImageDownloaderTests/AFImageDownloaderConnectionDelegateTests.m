//
//  AFImageDownlaoderConnectionDelegateTests.m
//  AFImageDownloader
//
//  Created by Ash Furrow on 2013-01-14.
//  Copyright 2013 Ash Furrow. All rights reserved.
//

#import "Kiwi.h"

#import "AFImageDownloader.h"

@interface AFImageDownloader (UnitTestAdditions)

-(void)setCompletion:(AFJPEGWasDecompressedCallback)completion;
-(void)setMutableData:(NSMutableData *)mutableData;
-(void)setConnection:(NSURLConnection *)connection;

@end

SPEC_BEGIN(AFImageDownloaderConnectionDelegateTests)

describe(@"Image downloader", ^{
    NSString *urlString = @"http://example.com/image.jpeg";
    __block AFImageDownloader<NSURLConnectionDataDelegate> *imageDownloader;
    
    context(@"has been newly created", ^{
        beforeEach(^{
            imageDownloader = (AFImageDownloader<NSURLConnectionDataDelegate> *)[[AFImageDownloader alloc] initWithURLString:urlString autoStart:NO completion:nil];
        });
        
        it (@"should append data", ^{
            
            id testData = [NSObject new];
            
            NSMutableData *mockMutableData = [NSMutableData mock];
            [[mockMutableData should] receive:@selector(appendData:) withArguments:testData, nil];
            [imageDownloader setMutableData:mockMutableData];
            
            NSURLConnection *mockConnection = [NSURLConnection mock];
            [imageDownloader setConnection:mockConnection];
            
            
            [imageDownloader connection:mockConnection didReceiveData:testData];
        });
        
        it (@"should not append data from another connection.", ^{
            
            id testData = [NSObject new];
            
            NSMutableData *mockMutableData = [NSMutableData mock];
            [imageDownloader setMutableData:mockMutableData];
            
            NSURLConnection *mockConnection = [NSURLConnection mock];
            [imageDownloader setConnection:mockConnection];
            
            NSURLConnection *otherConnection = [NSURLConnection mock];
            
            [imageDownloader connection:otherConnection didReceiveData:testData];
        });
        
        it (@"should cancel itself upon receiving a non-200 HTTP responses", ^{
            
            NSURLConnection *mockConnection = [NSURLConnection mock];
            [[mockConnection should] receive:@selector(cancel)];
            [imageDownloader setConnection:mockConnection];
            
            NSHTTPURLResponse *mockResponse = [NSHTTPURLResponse mock];
            [mockResponse stub:@selector(statusCode) andReturn:theValue(400)];
            
            [[imageDownloader should] receive:@selector(cancel)];
            [imageDownloader connection:mockConnection didReceiveResponse:mockResponse];
        });
        
        it (@"should call the completion block when the URL connection completes.", ^{
                        
            NSURLConnection *mockConnection = [NSURLConnection mock];
            [imageDownloader setConnection:mockConnection];
            
            NSMutableData *mockData = [NSMutableData dataWithLength:1];;
            [imageDownloader setMutableData:mockData];
            
            [imageDownloader setCompletion:^(UIImage *decompressedImage) {
                [decompressedImage shouldBeNil];
            }];
            
            [imageDownloader connectionDidFinishLoading:mockConnection];
        });
    });
});

SPEC_END


