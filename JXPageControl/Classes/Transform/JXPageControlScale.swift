//
//  JXPageControlScale.swift
//  JXPageControl_Example
//
//  Created by 谭家祥 on 2019/6/12.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

@IBDesignable open class JXPageControlScale: JXPageControlBase {
    
    open override func setBase() {
        super.setBase()
        activeSize = CGSize(width: 15,
                            height: 15)
        contentAlignment.spacingType = .equalSpacing
    }
    
    // MARK: - -------------------------- Custom property list --------------------------
    
    /// When isAnimation is false, the animation time is shorter;
    /// when isAnimation is true, the animation time is longer;
    /// IsAnimation only applies "set currentPage",
    /// while "set progress" does not work
    @IBInspectable public var isAnimation: Bool = true

    private var inactiveOriginFrame: [CGRect] = []
    
    // MARK: - -------------------------- Update tht data --------------------------
    
    override func updateProgress(_ progress: CGFloat) {
        guard progress >= 0 ,
            progress <= CGFloat(numberOfPages - 1)
            else { return }

        if contentAlignment.spacingType == .equalSpacing { /// 中心间距相等
        
        } else {
            handleEqualCenterSpacing(progress)
        }
        
        currentIndex = Int(progress)
    }
    
    // MARK: - private method
    func handleEqualCenterSpacing(_ progress: CGFloat) {
        /// 目标选中下标
        let leftIndex = Int(floor(progress))
        let rightIndex = leftIndex + 1 > numberOfPages - 1 ? leftIndex : leftIndex + 1

        if leftIndex == rightIndex { /// 滑动到最后一页
            for index in 0 ..< numberOfPages {
                if index != leftIndex {
                    let layer = inactiveLayer[index]
                    layer.frame = inactiveOriginFrame[index]
                    hollowLayout(layer: layer, isActive: false)
                } else {
                    let layer = inactiveLayer[index]
                    let frame = inactiveOriginFrame[index]
                    layer.frame = CGRect(x: frame.origin.x - (activeSize.width - inactiveSize.width) * 0.5,
                                         y: (maxIndicatorSize.height - activeSize.height) * 0.5,
                                         width: activeSize.width,
                                         height: activeSize.height)
                    hollowLayout(layer: layer, isActive: true)
                }
            }
        } else {
            let leftLayer = inactiveLayer[leftIndex]
            let rightLayer = inactiveLayer[rightIndex]

            let rightScare = progress - floor(progress)
            let leftScare = 1 - rightScare

            CATransaction.setDisableActions(true)
            CATransaction.begin()

            let tempInactiveColor = isInactiveHollow ? UIColor.clear : inactiveColor
            let tempActiveColor = (isInactiveHollow && isActiveHollow) ? UIColor.clear : activeColor

            leftLayer.backgroundColor = UIColor.transform(originColor: tempInactiveColor,
                                                          targetColor: tempActiveColor,
                                                          proportion: leftScare).cgColor
            rightLayer.backgroundColor = UIColor.transform(originColor: tempInactiveColor,
                                                           targetColor: tempActiveColor,
                                                           proportion: rightScare).cgColor

            let activeWidth = activeSize.width > kMinItemWidth ? activeSize.width : kMinItemWidth
            let activeHeight = activeSize.height > kMinItemHeight ? activeSize.height : kMinItemHeight
            let inactiveWidth = inactiveSize.width > kMinItemWidth ? inactiveSize.width : kMinItemWidth
            let inactiveHeight = inactiveSize.height > kMinItemHeight ? inactiveSize.height : kMinItemHeight

            let marginWidth = activeWidth - inactiveWidth
            let marginHeight = activeHeight - inactiveHeight

            let leftWidth = inactiveWidth + marginWidth * leftScare
            let rightWidth = inactiveWidth + marginWidth * rightScare
            let leftHeight = inactiveHeight + marginHeight * leftScare
            let rightHeight = inactiveHeight + marginHeight * rightScare

            let leftX = (maxIndicatorSize.width - leftWidth) * 0.5 + (maxIndicatorSize.width + columnSpacing) * CGFloat(leftIndex)
            let rightX = (maxIndicatorSize.width - rightWidth) * 0.5 + (maxIndicatorSize.width + columnSpacing) * CGFloat(rightIndex)

            leftLayer.frame = CGRect(x: leftX,
                                     y: (maxIndicatorSize.height - leftHeight) * 0.5,
                                     width: leftWidth,
                                     height: leftHeight)

            rightLayer.frame = CGRect(x: rightX,
                                      y: (maxIndicatorSize.height - rightHeight) * 0.5,
                                      width: rightWidth,
                                      height: rightHeight)


            if leftWidth > leftHeight {
                leftLayer.cornerRadius = leftHeight * 0.5
            } else {
                leftLayer.cornerRadius = leftWidth * 0.5
            }
            if rightWidth > rightHeight {
                rightLayer.cornerRadius = rightHeight * 0.5
            } else {
                rightLayer.cornerRadius = rightWidth * 0.5
            }

            for index in 0 ..< numberOfPages {
                if index != leftIndex,
                    index != rightIndex {
                    let layer = inactiveLayer[index]
                    layer.frame = inactiveOriginFrame[index]
                    hollowLayout(layer: layer, isActive: false)
                }
            }
            CATransaction.commit()
        }
    }
    
    override func updateCurrentPage(_ pageIndex: Int) {
        guard pageIndex >= 0 ,
            pageIndex <= numberOfPages - 1,
            pageIndex != currentIndex
            else { return }

        let duration: CFTimeInterval = isAnimation ? 0.6 : 0.3
        
        if contentAlignment.spacingType == .equalCenterSapcing {
            for index in 0 ..< numberOfPages {
                if index == currentIndex {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(duration)
                    let layer = inactiveLayer[index]
                    layer.frame = inactiveOriginFrame[index]
                    hollowLayout(layer: layer, isActive: false)
                    CATransaction.commit()
                } else if index == pageIndex {
                    let layer = inactiveLayer[index]
                    let frame = inactiveOriginFrame[index]
                    
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(duration)
                    layer.frame = CGRect(x: frame.origin.x - (self.activeSize.width - self.inactiveSize.width) * 0.5,
                                         y: (self.maxIndicatorSize.height - self.activeSize.height) * 0.5,
                                         width: self.activeSize.width,
                                         height: self.activeSize.height)
                    hollowLayout(layer: layer, isActive: true)
                    CATransaction.commit()
                }
            }
        } else { /// 等间距
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            
            let lastLayer = inactiveLayer[currentIndex]
            let newLayer = inactiveLayer[pageIndex]
            
            var oldFrame = inactiveOriginFrame[currentIndex]
            if pageIndex < currentIndex {
                oldFrame.origin.x += (activeSize.width - inactiveSize.width)
            }
            oldFrame.size.width = inactiveSize.width
            inactiveOriginFrame[currentIndex] = oldFrame
            lastLayer.frame = oldFrame;
            hollowLayout(layer: lastLayer, isActive: false)
            
            var newFrame = inactiveOriginFrame[pageIndex]
            if pageIndex > currentIndex {
                newFrame.origin.x -= (activeSize.width - inactiveSize.width)
            }
            newFrame.size.width = activeSize.width
            newLayer.frame = newFrame
            inactiveOriginFrame[pageIndex] = newFrame
            newLayer.frame = newFrame
            hollowLayout(layer: newLayer, isActive: true)
            
            if pageIndex - currentIndex > 1 { /// 左边的时候到右边 越过点击
                for index in (currentIndex + 1)..<pageIndex {
                    let layer = inactiveLayer[index]
                    var frame = inactiveOriginFrame[index]
                    frame.origin.x -= (activeSize.width - inactiveSize.width)
                    frame.size.width = inactiveSize.width
                    layer.frame = frame;
                    inactiveOriginFrame[index] = frame
                    hollowLayout(layer: layer, isActive: false)
                }
            } else if pageIndex - currentIndex < -1 { /// 右边选中到左边的时候 越过点击
                for index in (pageIndex + 1)..<currentIndex  {
                    let layer = inactiveLayer[index]
                    var frame = inactiveOriginFrame[index]
                    frame.origin.x += (activeSize.width - inactiveSize.width)
                    frame.size.width = inactiveSize.width
                    layer.frame = frame;
                    inactiveOriginFrame[index] = frame
                    hollowLayout(layer: layer, isActive: false)
                }
            }
            CATransaction.commit()
        }
        currentIndex = pageIndex
    }
    
    override func inactiveHollowLayout() {
        hollowLayout()
    }
    
    override func activeHollowLayout() {
        hollowLayout()
    }
    
    // MARK: - -------------------------- Layout --------------------------
    override func layoutInactiveIndicators() {
        inactiveOriginFrame = []
        
        if self.contentAlignment.spacingType == .equalCenterSapcing {
            let x = (maxIndicatorSize.width - inactiveSize.width) * 0.5
            let y = (maxIndicatorSize.height - inactiveSize.height) * 0.5
            let inactiveWidth = inactiveSize.width > kMinItemWidth ? inactiveSize.width : kMinItemWidth
            let inactiveHeight = inactiveSize.height > kMinItemHeight ? inactiveSize.height : kMinItemHeight
            var layerFrame = CGRect(x: x,
                                    y: y,
                                    width: inactiveWidth ,
                                    height: inactiveHeight)
            inactiveLayer.forEach() { layer in
                layer.frame = layerFrame
                inactiveOriginFrame.append(layerFrame)
                layerFrame.origin.x += maxIndicatorSize.width + columnSpacing
            }
        } else {
            var isActive = false
            let x = 0.0
            let y = (maxIndicatorSize.height - inactiveSize.height) * 0.5
            var layerFrame: CGRect = CGRect(x: x,
                                            y: y,
                                            width: 0,
                                            height: 0)
            for (index, layer) in inactiveLayer.enumerated() {
                if index == currentIndex {
                    let inactiveWidth = activeSize.width > kMinItemWidth ? activeSize.width : kMinItemWidth;
                    let inactiveHeight = activeSize.height > kMinItemHeight ? activeSize.height : kMinItemHeight;
                    layerFrame.size.width = inactiveWidth
                    layerFrame.size.height = inactiveHeight
                    isActive = true
                } else {
                    let inactiveWidth = inactiveSize.width > kMinItemWidth ? inactiveSize.width : kMinItemWidth;
                    let inactiveHeight = inactiveSize.height > kMinItemHeight ? inactiveSize.height : kMinItemHeight
                    layerFrame.size.width = inactiveWidth
                    layerFrame.size.height = inactiveHeight
                    isActive = false
                }
                layer.frame = layerFrame
                inactiveOriginFrame.append(layerFrame)
                layerFrame.origin.x += layerFrame.width + columnSpacing
                hollowLayout(layer: layer, isActive: isActive)
            }
        }
        
        hollowLayout()
    }
}

extension JXPageControlScale {
    
    private func hollowLayout() {
        if isInactiveHollow {
            for (index, layer) in inactiveLayer.enumerated() {
                if index == currentIndex, !isActiveHollow {
                    layer.backgroundColor = activeColor.cgColor
                } else {
                    layer.backgroundColor = UIColor.clear.cgColor
                    layer.borderColor = activeColor.cgColor
                }
                layer.borderColor = activeColor.cgColor
                layer.borderWidth = 1
            }
        }
        else {
            for (index, layer) in inactiveLayer.enumerated() {
                if index == currentIndex {
                    layer.backgroundColor = activeColor.cgColor
                } else {
                    layer.backgroundColor = inactiveColor.cgColor
                }
                layer.borderWidth = 0
            }
        }
    }
    
    private func hollowLayout(layer: CALayer, isActive: Bool) {
        /// Set backgroundcolor
        if isInactiveHollow {
            if isActive,
                !isActiveHollow {
                layer.backgroundColor = activeColor.cgColor
            } else {
                layer.backgroundColor = UIColor.clear.cgColor
                layer.borderColor = activeColor.cgColor
            }
        } else {
            if isActive {
                layer.backgroundColor = activeColor.cgColor
            } else {
                layer.backgroundColor = inactiveColor.cgColor
            }
        }
        
        /// Set cornerRadius
        if layer.frame.width > layer.frame.height {
            layer.cornerRadius = layer.frame.height * 0.5
        } else {
            layer.cornerRadius = layer.frame.width * 0.5
        }
    }
    
}
