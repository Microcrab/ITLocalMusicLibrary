//
//  ITSingleSong.m
//  ServerAndMusicDemo
//
//  Created by pengchengwu on 16/7/13.
//  Copyright © 2016年 pengchengwu. All rights reserved.
//

#import "ITSingleSong.h"
#import <MediaPlayer/MPMediaItem.h>

@implementation ITSingleSong

+ (instancetype)songWithMPMediaItem:(MPMediaItem *)mediaItem localAbsolutePath:(NSString *)localAbsolutePath {
    ITSingleSong *aSong = [[ITSingleSong alloc]init];
    aSong.persistentID = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
    aSong.name = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    aSong.fileFormat = ITLocalSongsFileFormat;
    aSong.duration = [mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    aSong.lyrics = [mediaItem valueForProperty:MPMediaItemPropertyLyrics];
    aSong.artworkImage = [[mediaItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(100, 100)];
    aSong.localAbsolutePath = localAbsolutePath;
    aSong.playing = NO;
    return aSong;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.persistentID = [aDecoder decodeObjectForKey:@"persistentID"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.fileFormat = [aDecoder decodeObjectForKey:@"fileFormat"];
        self.duration = [aDecoder decodeObjectForKey:@"duration"];
        self.lyrics = [aDecoder decodeObjectForKey:@"lyrics"];
        self.artworkImage = [aDecoder decodeObjectForKey:@"artworkImage"];
        self.localAbsolutePath = [aDecoder decodeObjectForKey:@"localAbsolutePath"];
        self.playing = [aDecoder decodeBoolForKey:@"playing"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.persistentID forKey:@"persistentID"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.fileFormat forKey:@"fileFormat"];
    [aCoder encodeObject:self.duration forKey:@"duration"];
    [aCoder encodeObject:self.lyrics forKey:@"lyrics"];
    [aCoder encodeObject:self.artworkImage forKey:@"artworkImage"];
    [aCoder encodeObject:self.localAbsolutePath forKey:@"localAbsolutePath"];
    [aCoder encodeBool:self.playing forKey:@"playing"];
}

@end
