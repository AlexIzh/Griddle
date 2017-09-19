//
//  KDRearrangeableCollectionViewFlowLayout.swift
//  KDRearrangeableCollectionViewFlowLayout
//
//  Created by Michael Michailidis on 16/03/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

@objc protocol DraggableCollectionViewFlowLayoutDelegate: UICollectionViewDelegate {
   func moveDataItem(_ fromIndexPath: IndexPath, toIndexPath: IndexPath) -> Void
   func didFinishMoving(_ fromIndexPath: IndexPath, toIndexPath: IndexPath) -> Void
}

class DraggableCollectionViewFlowLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {

   var animating: Bool = false

   var collectionViewFrameInCanvas: CGRect = CGRect.zero

   var hitTestRectagles = [String: CGRect]()

   var startIndexPath: IndexPath?

   var canvas: UIView? {
      didSet {
         if canvas != nil {
            calculateBorders()
         }
      }
   }

   struct Bundle {
      var offset: CGPoint = CGPoint.zero
      var sourceCell: UICollectionViewCell
      var representationImageView: UIView
      var currentIndexPath: IndexPath
   }

   var bundle: Bundle?

   override init() {
      super.init()
      setup()
   }

   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
   }

   override func awakeFromNib() {
      super.awakeFromNib()
      setup()
   }

   func setup() {

      if let _ = self.collectionView {

         //            let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
         //
         //            longPressGestureRecogniser.minimumPressDuration = 0.2
         //            longPressGestureRecogniser.delegate = self
         //
         //            collectionView.addGestureRecognizer(longPressGestureRecogniser)

         if canvas == nil {

            canvas = collectionView!.superview
         }
      }
   }

   override func prepare() {
      super.prepare()
      calculateBorders()
   }

   fileprivate func calculateBorders() {

      if let collectionView = self.collectionView {

         collectionViewFrameInCanvas = collectionView.frame

         if canvas != collectionView.superview {
            collectionViewFrameInCanvas = canvas!.convert(collectionViewFrameInCanvas, from: collectionView)
         }

         var leftRect: CGRect = collectionViewFrameInCanvas
         leftRect.size.width = 20.0
         hitTestRectagles["left"] = leftRect

         var topRect: CGRect = collectionViewFrameInCanvas
         topRect.size.height = 20.0
         hitTestRectagles["top"] = topRect

         var rightRect: CGRect = collectionViewFrameInCanvas
         rightRect.origin.x = rightRect.size.width - 20.0
         rightRect.size.width = 20.0
         hitTestRectagles["right"] = rightRect

         var bottomRect: CGRect = collectionViewFrameInCanvas
         bottomRect.origin.y = bottomRect.origin.y + rightRect.size.height - 20.0
         bottomRect.size.height = 20.0
         hitTestRectagles["bottom"] = bottomRect
      }
   }

   // MARK: - UIGestureRecognizerDelegate

   func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

      if let ca = self.canvas {

         if let cv = self.collectionView {

            let pointPressedInCanvas = gestureRecognizer.location(in: ca)

            for cell in cv.visibleCells {

               let cellInCanvasFrame = ca.convert(cell.frame, from: cv)

               if cellInCanvasFrame.contains(pointPressedInCanvas) {

                  let representationImage = cell.snapshotView(afterScreenUpdates: true)
                  representationImage!.frame = cellInCanvasFrame

                  let offset = CGPoint(x: pointPressedInCanvas.x - cellInCanvasFrame.origin.x, y: pointPressedInCanvas.y - cellInCanvasFrame.origin.y)

                  let indexPath: IndexPath = cv.indexPath(for: cell as UICollectionViewCell)!

                  bundle = Bundle(offset: offset, sourceCell: cell, representationImageView: representationImage!, currentIndexPath: indexPath)

                  break
               }
            }
         }
      }
      return (bundle != nil)
   }

   func checkForDraggingAtTheEdgeAndAnimatePaging(_ gestureRecognizer: UILongPressGestureRecognizer) {

      if animating == true {
         return
      }

      if let bundle = self.bundle {

         _ = gestureRecognizer.location(in: canvas)

         var nextPageRect: CGRect = collectionView!.bounds

         if scrollDirection == UICollectionViewScrollDirection.horizontal {

            if bundle.representationImageView.frame.intersects(hitTestRectagles["left"]!) {

               nextPageRect.origin.x -= nextPageRect.size.width

               if nextPageRect.origin.x < 0.0 {

                  nextPageRect.origin.x = 0.0
               }

            } else if bundle.representationImageView.frame.intersects(hitTestRectagles["right"]!) {

               nextPageRect.origin.x += nextPageRect.size.width

               if nextPageRect.origin.x + nextPageRect.size.width > collectionView!.contentSize.width {

                  nextPageRect.origin.x = collectionView!.contentSize.width - nextPageRect.size.width
               }
            }

         } else if scrollDirection == UICollectionViewScrollDirection.vertical {

            _ = hitTestRectagles["top"]

            if bundle.representationImageView.frame.intersects(hitTestRectagles["top"]!) {

               nextPageRect.origin.y -= nextPageRect.size.height

               if nextPageRect.origin.y < 0.0 {

                  nextPageRect.origin.y = 0.0
               }

            } else if bundle.representationImageView.frame.intersects(hitTestRectagles["bottom"]!) {

               nextPageRect.origin.y += nextPageRect.size.height

               if nextPageRect.origin.y + nextPageRect.size.height > collectionView!.contentSize.height {

                  nextPageRect.origin.y = collectionView!.contentSize.height - nextPageRect.size.height
               }
            }
         }

         if !nextPageRect.equalTo(collectionView!.bounds) {

            let delayTime = DispatchTime.now() + Double(Int64(0.8 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {

               self.animating = false

               self.handleGesture(gestureRecognizer)

            })

            animating = true

            collectionView!.scrollRectToVisible(nextPageRect, animated: true)
         }
      }
   }

   func handleGesture(_ gesture: UILongPressGestureRecognizer) {

      if let bundle = self.bundle {

         let dragPointOnCanvas = gesture.location(in: canvas)

         if gesture.state == UIGestureRecognizerState.began {

            bundle.sourceCell.isHidden = true
            canvas?.addSubview(bundle.representationImageView)

            //                UIView.animateWithDuration(0.5, animations: { () -> Void in
            //                    bundle.representationImageView.alpha = 0.8
            //                });
            let dragPointOnCollectionView = gesture.location(in: collectionView)
            startIndexPath = collectionView?.indexPathForItem(at: dragPointOnCollectionView)
         }

         if gesture.state == UIGestureRecognizerState.changed {

            // Update the representation image
            var imageViewFrame = bundle.representationImageView.frame
            var point = CGPoint.zero
            point.x = dragPointOnCanvas.x - bundle.offset.x
            point.y = dragPointOnCanvas.y - bundle.offset.y
            imageViewFrame.origin = point
            bundle.representationImageView.frame = imageViewFrame

            let dragPointOnCollectionView = gesture.location(in: collectionView)

            if let indexPath: IndexPath = self.collectionView?.indexPathForItem(at: dragPointOnCollectionView) {

               checkForDraggingAtTheEdgeAndAnimatePaging(gesture)

               if (indexPath == bundle.currentIndexPath) == false {

                  // If we have a collection view controller that implements the delegate we call the method first
                  if let delegate = self.collectionView!.delegate as? DraggableCollectionViewFlowLayoutDelegate {
                     delegate.moveDataItem(bundle.currentIndexPath, toIndexPath: indexPath)
                  }

                  collectionView!.moveItem(at: bundle.currentIndexPath, to: indexPath)

                  self.bundle!.currentIndexPath = indexPath
               }
            }
         }

         if gesture.state == UIGestureRecognizerState.ended {

            bundle.sourceCell.isHidden = false
            bundle.representationImageView.removeFromSuperview()

            if let _ = self.collectionView?.delegate as? DraggableCollectionViewFlowLayoutDelegate { // if we have a proper data source then we can reload and have the data displayed correctly
               collectionView!.reloadData()
            }
            if let delegate = self.collectionView!.delegate as? DraggableCollectionViewFlowLayoutDelegate {
               if let start = self.startIndexPath {
                  delegate.didFinishMoving(start, toIndexPath: self.bundle!.currentIndexPath)
               }
            }
            self.bundle = nil
         }
      }
   }
}
