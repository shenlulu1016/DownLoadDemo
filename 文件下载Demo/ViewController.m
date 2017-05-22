//
//  ViewController.m
//  文件下载Demo
//
//  Created by 申露露 on 16/7/21.
//  Copyright © 2016年 申露露. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIButton *breakpointButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) MBProgressHUD * progressView;//进度条
@property (nonatomic, strong) NSString * filePath;//文件的沙盒路径
@property (nonatomic, assign) BOOL isResume;//任务是否启动中
@property (nonatomic, assign) NSInteger fileSize;//本地已经下载文件的大小
@property (nonatomic, assign) NSInteger altogrtherSize;//文件总共的大小

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.contentMode = UIViewContentModeScaleToFill;//图片大小自适应
    self.filePath = 0;
    self.altogrtherSize = 0;
    self.isResume = NO;//状态初始化
}
#pragma mark 一次性下载所有的数据，会引起卡顿
- (IBAction)AllDownLoad:(id)sender {
    //使用NSData  直接下载文件
    NSURL * url = [NSURL URLWithString:@"http://localhost/shenlulu/桌面/icon-png/1024.png"];
    NSData * data = [NSData dataWithContentsOfURL:url];
    NSLog(@"%@", data);
    self.imageView.image = [UIImage imageWithData:data];
}
#pragma mark 文件直接下载
- (IBAction)DricetDowmLoad:(id)sender {
    //设置代理
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:@""];
    NSURLSessionDownloadTask * downloadTask = [session downloadTaskWithURL:url];
    //启动下载任务
    [downloadTask resume];
    self.progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressView.mode = MBProgressHUDModeDeterminateHorizontalBar;
    self.progressView.label.text = @"文件下载中....";
    
}
#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //进度条显示
    if (totalBytesExpectedToWrite > self.altogrtherSize) {
        self.altogrtherSize = totalBytesWritten;
    }
    self.progressView.progress = (float)1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    //根据请求头中的文件名在沙盒中直接创建路径
    NSURLResponse * response = downloadTask.response;
    NSString * filePath = [self cacheDir:response.suggestedFilename];
    self.filePath = filePath;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    //把临时的下载文件（在内存中）放入沙盒中
    [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
    
}
//完成任务
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (self.progressView.progress == 1.0) {
        self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
        //关掉用户交互
        [self.breakpointButton setTitle:@"下载完成" forState:UIControlStateNormal];
        self.breakpointButton.userInteractionEnabled = NO;
        [self.progressView hideAnimated:YES];
    }
}
//计算已经下载的文件的大小
//根据传入的文件的路径，计算文件的大小
- (NSInteger)fileSizeWith:(NSString *)paths{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    //文件的相关参数
    NSDictionary * dict = [fileManager attributesOfItemAtPath:paths error:nil];
    return [dict[NSFileSize] integerValue];
    
}
- (NSString *)cacheDir:(NSString *)paths{
    NSString * cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return [cache stringByAppendingPathComponent:[paths lastPathComponent]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
