/*
 Copyright (c) 2015, Rugen Heidbuchel All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKSurveyAnswerCellForBodyShader.h"
#import "ORKQuestionStepViewController.h"
#import "ORKStepViewController_Internal.h"


@interface ORKSurveyAnswerCellForBodyShader () {
}

@property (nonatomic, strong) ORKBodyShaderView *bodyShaderView;

@end


@implementation ORKSurveyAnswerCellForBodyShader


#pragma mark - View Settings

- (void)prepareView {
    
    if (!_bodyShaderView) {
        
        _bodyShaderView = [[ORKBodyShaderView alloc] initWithDelegate:self];
        _bodyShaderView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_bodyShaderView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_bodyShaderView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_bodyShaderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:_bodyShaderView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:_bodyShaderView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    }
    
    [super prepareView];
}

- (NSArray *)suggestedCellHeightConstraintsForView:(UIView *)view {
    return @[];
}



#pragma mark - Answer Handling

- (void)ork_setAnswer:(id)answer {
    
    _answer = [answer copy];
    [self.delegate answerCell:self answerDidChangeTo:answer dueUserAction:YES];
}

- (NSURL*)outputDirectory {
    return [[(ORKQuestionStepViewController*)self.delegate outputDirectory] URLByAppendingPathComponent:self.step.identifier];
}

- (NSURL*)frontImageURL {
    return [[self outputDirectory] URLByAppendingPathComponent:@"frontImage.png"];
}

- (NSURL*)backImageURL {
    return [[self outputDirectory] URLByAppendingPathComponent:@"backImage.png"];
}

- (void)createOutputDirectoryIfNecessary {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self outputDirectory].path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:[self outputDirectory] withIntermediateDirectories:NO attributes:nil error:nil];
    }
}



#pragma mark - ORKBodyShaderViewDelegate

- (void)bodyShaderView:(ORKBodyShaderView *)bodyShaderView
   frontImageChangedTo:(UIImage *)frontImage
    backImageChangedTo:(UIImage *)backImage
     frontShadedPixels:(int)frontShaded
      frontTotalPixels:(int)frontTotal
      backShadedPixels:(int)backShaded
       backTotalPixels:(int)backTotal {
    
    NSMutableDictionary *answer = [[NSMutableDictionary alloc] init];
    
    [self createOutputDirectoryIfNecessary];
    
    if (frontImage) {
        
        [UIImagePNGRepresentation(frontImage) writeToURL:[self frontImageURL] atomically:YES];
        
        [answer setObject:[self frontImageURL] forKey:@"frontImageURL"];
        [answer setObject:[NSNumber numberWithInt:frontShaded] forKey:@"frontShaded"];
        [answer setObject:[NSNumber numberWithInt:frontTotal] forKey:@"frontTotal"];
    }
    
    if (backImage) {
        
        [UIImagePNGRepresentation(backImage) writeToURL:[self backImageURL] atomically:YES];
        
        [answer setObject:[self backImageURL] forKey:@"backImageURL"];
        [answer setObject:[NSNumber numberWithInt:backShaded] forKey:@"backShaded"];
        [answer setObject:[NSNumber numberWithInt:backTotal] forKey:@"backTotal"];
    }
    
    [self ork_setAnswer:answer];
}

@end