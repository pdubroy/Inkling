//
//  NodeClusterPoint.swift
//  Inkling
//
//  Created by Marcel on 24/08/2022.
//

import Foundation
import UIKit

class NodeClusters {
  var clusters: [NodeCluster] = []
  
  @discardableResult func addNode(_ node: Node) -> NodeCluster {
    // Find if there are any near-by clusters
    let cluster = NodeCluster(node)
    clusters.append(cluster)
    mergeCluster(cluster)
    return cluster
  }
  
  func mergeCluster(_ cluster: NodeCluster) {
    for other in clusters {
      if !(other === cluster) {
        if distance(other.position, cluster.position) < 5.0 {
          cluster.merge(other)
          clusters.removeAll { c in c === other}
        }
      }
    }
  }
  
  func findClosestCluster(_ position: CGVector) -> NodeCluster? {
    let index = findClosestPointInCollection(points: clusters.map({ n in n.position}), point: position, min_dist: 30.0)
    if index > -1 {
      let foundCluster = clusters[index]
      
      if distance(position, foundCluster.position) > 15.0 {
        if let subNode = foundCluster.findClosestSubnode(position) {
          foundCluster.removeNode(subNode)
          let cluster = NodeCluster(subNode)
          clusters.append(cluster)
          return cluster
        }
      }
      return foundCluster
    }
    return nil
  }
  
  func findClustersInPolygon(_ polygon: [CGVector]) -> [NodeCluster] {
    return clusters.filter { cluster in isPointInPolygon( cluster.position, polygon) }
  }
  
  func render(_ renderer: Renderer) {
    for c in clusters {
      c.render(renderer)
    }
  }
}

class NodeCluster {
  var nodes: [Node] = []
  var position: CGVector
  
  init(_ node: Node) {
    self.nodes.append(node)
    self.position = node.position
  }
  
  func addNode(_ node: Node) {
    self.nodes.append(node)
    self.position = average(self.nodes.map({ np in np.position}))
  }
  
  func removeNode(_ node: Node) {
    self.nodes.removeAll(where: { n in n === node })
    self.position = average(self.nodes.map({ np in np.position}))
  }
  
  func move(_ position: CGVector) {
    let delta = position - self.position
    self.position = position
    for n in nodes {
      n.move(n.position +  delta)
    }
  }
  
  func merge(_ other: NodeCluster) {
    self.nodes.append(contentsOf: other.nodes)
    self.position = average(self.nodes.map({ np in np.position}))
  }
  
  func findClosestSubnode(_ position: CGVector) -> Node? {
    let index = findClosestLineInCollection(
      lines: nodes.map({ n in (n.element.nodes[0].position, n.element.nodes[1].position) }),
      point: position,
      min_dist: 30.0
    )
    
    if index > -1 {
      return nodes[index]
    }
    
    return nil
    
//    let index = findClosestPointInCollection(points: nodes.map({ n in n.position}), point: position, min_dist: 30.0)
//    if index > -1 {
//      return nodes[index]
//    }
//    return nil
  }
  
  func render(_ renderer: Renderer) {
    renderer.addShapeData(circleShape(pos: position, radius: 4.0, resolution: 8, color: Color(255, 255, 255)))
    renderer.addShapeData(circleShape(pos: position, radius: 3.0, resolution: 8, color: Color(73, 172, 214)))
  }
}
