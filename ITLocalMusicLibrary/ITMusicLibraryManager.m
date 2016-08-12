//
//  ITMusicLibraryManager.m
//  ServerAndMusicDemo
//
//  Created by pengchengwu on 16/7/12.
//  Copyright © 2016年 pengchengwu. All rights reserved.
//

#import "ITMusicLibraryManager.h"

@interface ITMusicLibraryManager ()

@property (nonatomic, assign) NSUInteger currentConvertFileNum;
@property (nonatomic, assign) NSUInteger convertFileCount;
@property (nonatomic, assign) CGFloat convertProgress;
//@property (nonatomic, assign, getter=isConverting) BOOL converting;

@end

@implementation ITMusicLibraryManager

+ (instancetype)sharedInstance {
    static dispatch_once_t __singletonToken;
    static ITMusicLibraryManager *__singleton__;
    dispatch_once( &__singletonToken, ^{
        __singleton__ = [[self alloc] init];
        [__singleton__ configSongsFolder];
        [__singleton__ updateMediaItemsLibrary];
        [__singleton__ updateLocalSongsLibrary];
    } );
    return __singleton__;
}

- (void)configSongsFolder {
    NSLog(@"%@",ITLocalSongsFolderPath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:ITLocalSongsFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ITLocalSongsFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:ITLocalSongsLibraryPath]) {
        [[NSFileManager defaultManager] createFileAtPath:ITLocalSongsLibraryPath contents:nil attributes:nil];
        [NSKeyedArchiver archiveRootObject:self.localSongsArr toFile:ITLocalSongsLibraryPath];
    }
}

- (void)updateMediaItemsLibrary {
    [self.ipodMediaItemsArr removeAllObjects];
    NSArray *itemsFromGenericQuery = [[MPMediaQuery songsQuery] items];
    if (itemsFromGenericQuery && itemsFromGenericQuery.count != 0) {
        for (MPMediaItem *aItem in itemsFromGenericQuery) {
            if ([aItem valueForKey:MPMediaItemPropertyAssetURL]) {
                [self.ipodMediaItemsArr addObject:aItem];
            }
        }
    }
}

- (void)updateLocalSongsLibrary {
    [self.localSongsArr removeAllObjects];
    NSArray<ITSingleSong *> *localSongsArr = [NSKeyedUnarchiver unarchiveObjectWithFile:ITLocalSongsLibraryPath];
    [self.localSongsArr setArray:localSongsArr];
    [NSKeyedArchiver archiveRootObject:self.localSongsArr toFile:ITLocalSongsLibraryPath];
}

- (void)convertSelectedIpodItems:(NSArray<MPMediaItem *> *)selectedItemsArr {
    if (selectedItemsArr && selectedItemsArr.count != 0) {
        self.currentConvertFileNum = 1;
        self.convertFileCount = selectedItemsArr.count;
        for (MPMediaItem *aMediaItem in selectedItemsArr) {
            [self convertToM4A:aMediaItem];
        }
    }
}

- (void)convertAllIpodItems {
    [self convertSelectedIpodItems:self.ipodMediaItemsArr];
}

- (void)convertToM4A:(MPMediaItem *)aMediaItem {
    NSURL *sourcePathURL = [aMediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:sourcePathURL options:nil];
    NSArray *canExportFormArr = [AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset];
    if (![canExportFormArr containsObject:@"AVAssetExportPresetAppleM4A"]) {
        NSLog (@"AVAssetExportSessionStatusFailed:UnsupportedType");
        [self convertProgressChange];
        return;
    }
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset:songAsset
                                      presetName:AVAssetExportPresetAppleM4A];
    exporter.outputFileType = @"com.apple.m4a-audio";
    NSString *exportAbsolutePath = [NSString stringWithFormat:@"/%@%@",[aMediaItem valueForProperty:MPMediaItemPropertyTitle],ITLocalSongsFileFormat];
    NSString *exportPath = [ITLocalSongsFolderPath stringByAppendingPathComponent:exportAbsolutePath];
    if([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [self convertProgressChange];
        return;
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    exporter.outputURL = exportURL;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch (exporter.status) {
            case AVAssetExportSessionStatusCompleted: {
                NSLog (@"AVAssetExportSessionStatusCompleted");
                [self addSingleLocalSong:[ITSingleSong songWithMPMediaItem:aMediaItem localAbsolutePath:exportAbsolutePath]];
                break;
            }
            case AVAssetExportSessionStatusUnknown:
            case AVAssetExportSessionStatusFailed:
            case AVAssetExportSessionStatusExporting:
            case AVAssetExportSessionStatusCancelled:
            case AVAssetExportSessionStatusWaiting: {
                if([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
                }
                break;
            }
            default: {
                if([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
                }
                NSLog (@"didn't get export status");
                break;
            }
        }
        [self convertProgressChange];
    }];
}

- (void)convertProgressChange {
    self.convertProgress = (CGFloat)self.currentConvertFileNum++/self.convertFileCount;
    [[NSNotificationCenter defaultCenter]postNotificationName:ITMusicNoticeConvertProgressChange object:[NSNumber numberWithFloat:self.convertProgress*100] userInfo:nil];
}

- (void)addSingleLocalSong:(ITSingleSong *)aSong {
    [self.localSongsArr addObject:aSong];
    [NSKeyedArchiver archiveRootObject:self.localSongsArr toFile:ITLocalSongsLibraryPath];
}

- (void)removeSingleLocalSong:(ITSingleSong *)aSong {
    if([[NSFileManager defaultManager] fileExistsAtPath:[ITLocalSongsFolderPath stringByAppendingString:aSong.localAbsolutePath]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[ITLocalSongsFolderPath stringByAppendingString:aSong.localAbsolutePath] error:nil];
    }
    [self.localSongsArr removeObject:aSong];
    [NSKeyedArchiver archiveRootObject:self.localSongsArr toFile:ITLocalSongsLibraryPath];
}

- (void)removeSelectedLocalSongs:(NSMutableArray<ITSingleSong *> *)selectedSongsArr {
    if (selectedSongsArr && selectedSongsArr.count != 0) {
        for (ITSingleSong *aSong in selectedSongsArr) {
            [self removeSingleLocalSong:aSong];
        }
    }
}

- (void)removeAllLocalSongs {
    [self removeSelectedLocalSongs:self.localSongsArr];
}

#pragma mark - GET
- (NSMutableArray *)ipodMediaItemsArr {
    if (_ipodMediaItemsArr == nil) {
        _ipodMediaItemsArr = [[NSMutableArray alloc]init];
    }
    return  _ipodMediaItemsArr;
}

- (NSMutableArray<ITSingleSong *> *)localSongsArr {
    if (_localSongsArr == nil) {
        _localSongsArr = [[NSMutableArray alloc]init];
    }
    return _localSongsArr;
}

@end
