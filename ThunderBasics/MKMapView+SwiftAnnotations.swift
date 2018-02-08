//
//  MKMapView+SwiftAnnotations.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 08/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation
import MapKit

public typealias MapIdentifier = String

private var AnnotationObjectHandle: UInt8 = 0
private var OverlayObjectHandle: UInt8 = 1

extension MKAnnotation {
	
	var annotationId: MapIdentifier? {
		get {
			return objc_getAssociatedObject(self, &AnnotationObjectHandle) as? MapIdentifier
		}
		set {
			objc_setAssociatedObject(self, &AnnotationObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

extension MKOverlay {
	
	var overlayId: MapIdentifier? {
		get {
			return objc_getAssociatedObject(self, &OverlayObjectHandle) as? MapIdentifier
		}
		set {
			objc_setAssociatedObject(self, &OverlayObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

/// A protocol for annotations to allow annotations to be removed by identifier rather than by the object, so we're not relying on objects being equal to remove/add pins from the map.
public protocol Annotation {
	
	/// The unique identifier of the overlay to remove it from the map
	///
	/// This is required now because we cannot guarantee that `annotation` will be the same annotation that was added to the map
	/// and therefore we require annotations to be removed by their identifier rather than by their annotation
	///
	/// - warning: This should not change for the same representation of an annotation (i.e. if the instance is a value type, and it changes but it still represents the same actual annotation, it should have the same identifier)
	var uniqueIdentifier: MapIdentifier? { get }
	
	/// The actual annotation this represents
	var annotation: MKAnnotation { get }
}

/// A protocol for overlays to allow overlays to be removed by identifier rather than by the object, so we're not relying on objects being equal to remove/add overlays from the map
public protocol Overlay {
	
	/// The unique identifier of the overlay to remove it from the map
	///
	/// This is required now because we cannot guarantee that `overlay` will be the same overlay that was added to the map
	/// and therefore we require annotations to be removed by their identifier rather than by their annotation
	///
	/// - warning: This should not change for the same representation of an overlay (i.e. if the instance is a value type, and it changes but it still represents the same actual overlay, it should have the same identifier)
	var uniqueIdentifier: MapIdentifier? { get }
	
	/// The actual overlay this represents
	var overlay: MKOverlay { get }
}

extension MKMapView {
	
	/// Adds an array of annotations to the map view.
	///
	/// - Parameter annotations: An array of annotation objects. Each object in the array must conform to the Annotation protocol. The map view retains the individual annotation objects.
	public func addAnnotations(_ annotations: [Annotation]) {
		
		let mapAnnotations: [MKAnnotation] = annotations.map({
			let mkAnnotation = $0.annotation
			mkAnnotation.annotationId = $0.uniqueIdentifier
			return mkAnnotation
		})
		
		addAnnotations(mapAnnotations)
	}
	
	/// Adds the specified annotation to the map view.
	///
	/// - Parameter annotation: The annotation to add to the map
	public func addAnnotation(_ annotation: Annotation) {
		
		let mkAnnotation = annotation.annotation
		mkAnnotation.annotationId = annotation.uniqueIdentifier
		addAnnotation(mkAnnotation)
	}
	
	/// Removes the specified annotation object from the map view.
	///
	/// - Parameter annotation: The annotation to remove. This object must conform to the Annotation protocol.
	public func removeAnnotation(_ annotation: Annotation) {
		
		guard let mkAnnotation = self.annotations.first(where: {
			annotation.uniqueIdentifier != nil && $0.annotationId == annotation.uniqueIdentifier
		}) else { return }
		removeAnnotation(mkAnnotation)
	}
	
	/// Removes an array of annotations from the map view.
	///
	/// - Parameter annotations: The array of annotations to remove from the map
	public func removeAnnotations(_ annotations: [Annotation]) {
		
		let annotationsToRemove = self.annotations.filter({
			guard let annotationId = $0.annotationId else { return false }
			return annotations.contains(where: { $0.uniqueIdentifier == annotationId })
		})
		removeAnnotations(annotationsToRemove)
	}
	
	/// Adds an array of overlays to the map view.
	///
	/// - Parameters:
	///   - overlays: The array of overlays to add to the map
	///   - level: The level to add the overlays at, defaults to aboveRoads
	public func addOverlays(_ overlays: [Overlay], level: MKOverlayLevel = .aboveRoads) {
		
		let mapOverlays: [MKOverlay] = overlays.map({
			let mkOverlay = $0.overlay
			mkOverlay.overlayId = $0.uniqueIdentifier
			return mkOverlay
		})
		
		addOverlays(mapOverlays, level: level)
	}
	
	/// Adds the overlay to the map at the specified level.
	///
	/// - Parameters:
	///   - overlay: The overlay to add to the map
	///   - level: The level to add the overlays at, defaults to aboveRoads
	public func add(_ overlay: Overlay, level: MKOverlayLevel = .aboveRoads) {
		
		let mkOverlay = overlay.overlay
		mkOverlay.overlayId = overlay.uniqueIdentifier
		add(mkOverlay, level: level)
	}
	
	/// Removes an array of overlays from the map view.
	///
	/// - Parameter annotations: The array of overlays to remove from the map
	public func removeOverlays(_ overlays: [Overlay]) {
		
		let overlaysToRemove = self.overlays.filter({
			guard let overlayId = $0.annotationId else { return false }
			return overlays.contains(where: { $0.uniqueIdentifier == overlayId })
		})
		removeAnnotations(overlaysToRemove)
	}
	
	/// Removes an overlay from the map view
	///
	/// - Parameter overlay: The overlay to remove from the map
	public func remove(_ overlay: Overlay) {
		
		guard let mkOverlay = self.overlays.first(where: {
			overlay.uniqueIdentifier != nil && $0.overlayId == overlay.uniqueIdentifier
		}) else { return }
		remove(mkOverlay)
	}
}
