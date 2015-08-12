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

#import "ORKBodyShaderView.h"
#import "ORKHelpers.h"

@interface ORKBodyShaderView ()

@property (nonatomic, strong) ORKShaderView *frontShaderView, *backShaderView;
@property (nonatomic, strong) UIButton *drawButton, *eraseButton;

@end

@implementation ORKBodyShaderView {
    
    UIImage *_frontImage, *_backImage;
    int _frontShadedPixels, _frontTotalPixels, _backShadedPixels, _backTotalPixels;
}



#pragma mark - Init

- (nonnull instancetype)initWithDelegate:(nonnull id<ORKBodyShaderViewDelegate>)delegate {
    
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout {
    
    if (!_frontShaderView) {
        
        UIImageView *frontOverlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frontBodyOverlay" inBundle:ORKBundle() compatibleWithTraitCollection:nil]];
        frontOverlayImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        frontOverlayImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _frontShaderView = [[ORKShaderView alloc] initWithSize:CGSizeMake(264, 496) overlayView:frontOverlayImageView delegate:self];
        
        [self addSubview:_frontShaderView];
    }
    
    if (!_backShaderView) {
        
        UIImageView *backOverlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backBodyOverlay" inBundle:ORKBundle() compatibleWithTraitCollection:nil]];
        backOverlayImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        backOverlayImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _backShaderView = [[ORKShaderView alloc] initWithSize:CGSizeMake(264, 496) overlayView:backOverlayImageView delegate:self];
        
        [self addSubview:_backShaderView];
    }
    
    if (!_drawButton) {
        
        _drawButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _drawButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImage *drawImage = [UIImage imageNamed:@"drawButton" inBundle:ORKBundle() compatibleWithTraitCollection:nil];
        [_drawButton setImage:ORKImageByTintingImage(drawImage, self.tintColor, 1.0) forState:UIControlStateNormal];
        
        _drawButton.layer.cornerRadius = 57.0/2.0;
        _drawButton.layer.borderColor = self.tintColor.CGColor;
        _drawButton.layer.borderWidth = 1.0;
        
        [_drawButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_drawButton];
    }
    
    if (!_eraseButton) {
        
        _eraseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _eraseButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImage *drawImage = [UIImage imageNamed:@"eraseButton" inBundle:ORKBundle() compatibleWithTraitCollection:nil];
        [_eraseButton setImage:ORKImageByTintingImage(drawImage, self.tintColor, 1.0) forState:UIControlStateNormal];
        
        _eraseButton.layer.cornerRadius = 57.0/2.0;
        _eraseButton.layer.borderColor = self.tintColor.CGColor;
        _eraseButton.layer.borderWidth = 1.0;
        
        [_eraseButton addTarget:self action:@selector(eraseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_eraseButton];
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_frontShaderView, _backShaderView, _drawButton, _eraseButton);
    
    _frontShaderView.translatesAutoresizingMaskIntoConstraints = NO;
    _backShaderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_frontShaderView(==264)]-(10)-[_backShaderView(==264)]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_drawButton(==57)]-[_eraseButton(==57)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_frontShaderView(==496)]-(16)-[_drawButton(==57)]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_frontShaderView]-(16)-[_eraseButton(==57)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backShaderView(==496)]" options:0 metrics:nil views:views]];
}



#pragma mark - Delegate

- (void)notifyDelegateOfResultsChange {
    
    if ([self.delegate respondsToSelector:@selector(bodyShaderView:frontImageChangedTo:backImageChangedTo:frontShadedPixels:frontTotalPixels:backShadedPixels:backTotalPixels:)]) {
        
        [self.delegate bodyShaderView:self
                  frontImageChangedTo:_frontImage
                   backImageChangedTo:_backImage
                    frontShadedPixels:_frontShadedPixels
                     frontTotalPixels:_frontTotalPixels
                     backShadedPixels:_backShadedPixels
                      backTotalPixels:_backTotalPixels];
    }
}



#pragma mark - ORKShaderView Controls

- (void)drawButtonTapped:(id)sender {
    
    NSLog(@"draw tapped");
}

- (void)eraseButtonTapped:(id)sender {
    
    NSLog(@"erase tapped");
}



#pragma mark - ORKShaderViewDelegate

- (void)shaderView:(ORKShaderView * __nonnull)shaderView drawingImageChangedTo:(UIImage * __nullable)image withNumberOfShadedPixels:(int)numberOfShadedPixels onTotalNumberOnPixels:(int)totalNumberOfPixels {
    
    if ([shaderView isEqual:self.frontShaderView]) {
        
        _frontImage = image;
        _frontShadedPixels = numberOfShadedPixels;
        _frontTotalPixels = totalNumberOfPixels;
        
    } else {
        
        _backImage = image;
        _backShadedPixels = numberOfShadedPixels;
        _backTotalPixels = totalNumberOfPixels;
    }
    
    [self notifyDelegateOfResultsChange];
}

@end
