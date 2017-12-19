//
//  MasterViewController.m
//  CYIconGenerator
//
//  Created by SaturdayNight on 2017/12/18.
//  Copyright © 2017年 SaturdayNight. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController () <NSTabViewDelegate,NSTableViewDataSource>

@property (nonatomic,copy) NSString *imagePath;
@property (nonatomic,strong) NSImageView *imageViewIcon;
@property (nonatomic,strong) NSButton *btnGetImage;
@property (nonatomic,strong) NSButton *btnFormat;
@property (nonatomic,strong) NSButton *btnDelete;
@property (nonatomic,strong) NSTableView *tbPixel;
@property (nonatomic,strong) NSMutableArray *arrayDataSource;
@property (nonatomic,strong) NSButton *btnAdd;
@property (nonatomic,strong) NSTextField *txInput;

@end

@implementation MasterViewController

-(void)viewWillAppear
{
    self.view.frame = NSMakeRect(0, 0, 800, 600);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageViewIcon];
    [self.view addSubview:self.btnGetImage];
    [self.view addSubview:self.btnFormat];
    
    NSScrollView * scrollView = [[NSScrollView alloc] init];
    scrollView.hasVerticalScroller  = YES;
    scrollView.frame = NSMakeRect(300, 170, 200, 100);
    scrollView.contentView.documentView = self.tbPixel;
    
    [self.view addSubview:scrollView];
    
    [self.view addSubview:self.btnDelete];
    [self.view addSubview:self.txInput];
    [self.view addSubview:self.btnAdd];
}

#pragma mark - EventAction
#pragma mark 选择图片按钮点击
- (void)btnGetImageClicked
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    __weak typeof(self)weakSelf = self;
    //是否可以创建文件夹
    panel.canCreateDirectories = YES;
    //是否可以选择文件夹
    panel.canChooseDirectories = YES;
    //是否可以选择文件
    panel.canChooseFiles = YES;
    
    //是否可以多选
    [panel setAllowsMultipleSelection:NO];
    
    //显示
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        
        //是否点击open 按钮
        if (result == NSModalResponseOK) {
            //NSURL *pathUrl = [panel URL];
            NSString *pathString = [panel.URLs.firstObject path];
            
            weakSelf.imagePath = pathString;
            weakSelf.imageViewIcon.image = [[NSImage alloc] initWithContentsOfFile:weakSelf.imagePath];
        }
        
    }];
}

#pragma mark 开始转化分辨率按钮点击
-(void)btnFormatClicked
{
    if (self.imagePath) {
        NSRange range = [self.imagePath rangeOfString:@"/"options:NSBackwardsSearch];
        NSString *path = [self.imagePath substringToIndex:(range.location)];
        
        
        for (int i = 0; i < self.arrayDataSource.count; i ++) {
            float sizeS = [[self.arrayDataSource objectAtIndex:i] floatValue];
            NSImage *imgFinal = [self compressImage:self.imageViewIcon.image withSize:CGSizeMake(sizeS, sizeS)];
            
            [self savePicture:imgFinal withPath:path andFileName:[NSString stringWithFormat:@"%0.1f_%0.1f.png",sizeS,sizeS]];
        }
    }
}

#pragma mark 删除分辨率方法
-(void)btnDeleteClicked
{
    if (self.tbPixel.selectedRow >= 0 && self.tbPixel.selectedRow < self.arrayDataSource.count) {
        [self.arrayDataSource removeObjectAtIndex:self.tbPixel.selectedRow];
        [self.tbPixel reloadData];
        
        NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"pixel.plist"];
        [self.arrayDataSource writeToFile:path atomically:YES];
    }
}

#pragma mark - 增加新分辨率
-(void)btnAddClicked
{
    if ([self.txInput.stringValue floatValue] > 0 && [self.txInput.stringValue floatValue] <= 4096) {
        [self.arrayDataSource addObject:[NSNumber numberWithUnsignedInteger:[self.txInput.stringValue floatValue]]];
        [self.tbPixel reloadData];
        
        NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"pixel.plist"];
        [self.arrayDataSource writeToFile:path atomically:YES];
    }
}

#pragma mark - 图片处理相关方法
#pragma mark 保存图片到路径
-(BOOL)savePicture:(NSImage *)picture withPath:(NSString *)path andFileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error;
        BOOL ifSuccess = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!ifSuccess) {
            NSLog(@"Compresse Fialed");
        }
    }
    
    NSData *imageData = [picture TIFFRepresentation];
    
    return [imageData writeToFile:[path stringByAppendingPathComponent:fileName] atomically:YES];
}

#pragma mark 压缩图片到对应尺寸
-(NSImage *)compressImage:(NSImage *)sourceImg withSize:(CGSize)size
{
    // convert NSImage to bitmap
    NSData  * tiffData = [sourceImg TIFFRepresentation];
    NSBitmapImageRep * bitmap;
    bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
    
    // create CIImage from bitmap
    CIImage * ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
    
    float width = CGImageGetWidth(ciImage.CGImage);
    float height = CGImageGetHeight(ciImage.CGImage);
    CGImageRef ref = CGImageCreateWithImageInRect(ciImage.CGImage, CGRectMake(0, 0, width, height));
    
    NSRect imageRect = NSMakeRect(0.0, 0.0, size.width, size.height);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil;
    
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, ref);
    [newImage unlockFocus];
    
    return newImage;
}
#pragma mark - Delegate
#pragma mark NSTableViewDelegate
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.arrayDataSource.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *str = [NSString stringWithFormat:@"分辨率：%0.1f x %0.1f",[self.arrayDataSource[row] floatValue],[self.arrayDataSource[row] floatValue]];
    
    return str;
}

#pragma mark - LazyLoad
-(NSButton *)btnFormat
{
    if (!_btnFormat) {
        _btnFormat = [NSButton buttonWithTitle:@"开始转化" target:self action:@selector(btnFormatClicked)];
        _btnFormat.frame = CGRectMake(300, 280, 200, 40);
    }
    
    return _btnFormat;
}

-(NSButton *)btnGetImage
{
    if (!_btnGetImage) {
        _btnGetImage = [NSButton buttonWithTitle:@"点击选取源图片" target:self action:@selector(btnGetImageClicked)];
        _btnGetImage.frame = CGRectMake(300, 330, 200, 40);
    }
    
    return _btnGetImage;
}

-(NSImageView *)imageViewIcon
{
    if (!_imageViewIcon) {
       _imageViewIcon = [[NSImageView alloc] initWithFrame:CGRectMake(300, 380, 200, 200)];
         NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"bgbg.png"];
        NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
        _imageViewIcon.image = img;
    }
    
    return _imageViewIcon;
}

-(NSTableView *)tbPixel
{
    if (!_tbPixel) {
        _tbPixel = [[NSTableView alloc] init];
        _tbPixel.delegate = self;
        _tbPixel.dataSource = self;
        
        NSTableColumn * column = [[NSTableColumn alloc]initWithIdentifier:@"test"];
        column.minWidth = 200;
        column.title = @"支持输出的分辨率";
        
        [_tbPixel addTableColumn:column];
    }
    
    return _tbPixel;
}

-(NSMutableArray *)arrayDataSource
{
    if (!_arrayDataSource) {
        NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"pixel.plist"];
        _arrayDataSource = [NSMutableArray arrayWithContentsOfFile:path];
    }
    
    return _arrayDataSource;
}

-(NSButton *)btnDelete
{
    if (!_btnDelete) {
        _btnDelete = [NSButton buttonWithTitle:@"删除选中项" target:self action:@selector(btnDeleteClicked)];
        _btnDelete.frame = CGRectMake(300, 130, 200, 40);
    }
    
    return _btnDelete;
}

-(NSTextField *)txInput
{
    if (!_txInput) {
        _txInput = [[NSTextField alloc] initWithFrame:NSMakeRect(300, 85, 80, 30)];
        _txInput.alignment = NSTextAlignmentNatural;
    }
    
    return _txInput;
}

-(NSButton *)btnAdd
{
    if (!_btnAdd) {
        _btnAdd = [NSButton buttonWithTitle:@"增加分辨率" target:self action:@selector(btnAddClicked)];
        _btnAdd.frame = CGRectMake(400, 80, 100, 40);
    }
    
    return _btnAdd;
}

@end
