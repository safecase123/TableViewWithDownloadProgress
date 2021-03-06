//
//  DownloadVC.m
//  TableViewWithDownloadProgress
//
//  Created by Paresh Navadiya on 11/06/15.
//  Copyright (c) 2015 India. All rights reserved.
//

#import "DownloadVC.h"
#import "DownloadItem.h"
#import "DownloadItemTableViewCell.h"

@interface DownloadVC () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation DownloadVC {
    NSMutableArray *_items;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mutArrQueueDownloadList = [NSMutableArray array];
    
    _items = [NSMutableArray array];
    
    self.title = @"Download List";
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    
    for (int i = 0; i < 50; i++)
    {
        DownloadItem *downloadItem = [[DownloadItem alloc] init];
        downloadItem.strFileName = [NSString stringWithFormat:@"sample_iTunes.mov.zip %d", i];
        downloadItem.strFileSize = @"-.-";
        downloadItem.strFileCreatedDate = @"2015-06-16";
        downloadItem.strFileDownloadURL = @"http://a1408.g.akamai.net/5/1408/1388/2005110403/1a1a1ad948be278cff2d96046ad90768d848b41947aa1986/sample_iTunes.mov.zip";
        
       
        NSURL *filePathURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"sample_iTunes.mov_%d.zip",i]];
        downloadItem.fileDownloadedPathURL = filePathURL;
        [_items addObject:downloadItem];
        
    }
    
    
    //for getting notification if download item was downloaded or failed and on basis of that new download can be loaded
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStatusNotification:) name:@"downloadStatusNotification" object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadStatusNotification" object:nil];
    
    NSLog(@"%@ is being deallocated",NSStringFromClass([self class]));
}

#pragma mark -
#pragma mark - Post Notification
-(void)downloadStatusNotification:(NSNotification *)notification
{
    NSDictionary *dictData = notification.object;
    if ([dictData count] > 0)
    {
        DownloadItem *downloadItem = [dictData objectForKey:@"DownloadItem"];
        if (downloadItem)
        {
            if (downloadItem.isDownloaded)
            {
                if ([mutArrQueueDownloadList count]>0)
                {
                    [mutArrQueueDownloadList removeObjectIdenticalTo:downloadItem];
                    
                    DownloadItem *newDownloadItem = [mutArrQueueDownloadList firstObject];
                    if (newDownloadItem)
                    {
                        isAnyDownloadStarted = YES;
                        [newDownloadItem downloadItem];
                    }
                    else
                        isAnyDownloadStarted = NO;
                }
                else
                    isAnyDownloadStarted = NO;
            }
            else
                isAnyDownloadStarted = NO;
            
        }
    }
}

#pragma mark - 
#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadItemTableViewCell *cell = (DownloadItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"itemTableCell"];
    
    DownloadItem *downloadItem = [_items objectAtIndex:indexPath.row];
    [cell setItem:downloadItem];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DownloadItem *downloadItem = [_items objectAtIndex:indexPath.row];
    if (![downloadItem isDownloading] && ![downloadItem isDownloaded])
    {
        if (!isAnyDownloadStarted)
        {
            [self performSelector:@selector(startDownloadingOnlyFirstTime:) withObject:downloadItem afterDelay:0.3];
        }
        else
        {
            [downloadItem waitDownloadItem];
            
            [mutArrQueueDownloadList addObject:downloadItem];
        }
    }
}

-(void)startDownloadingOnlyFirstTime:(DownloadItem*)downloadItem
{
    isAnyDownloadStarted = YES;
    [downloadItem downloadItem];
}

@end
