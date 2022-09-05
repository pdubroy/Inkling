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
    let closeByClusters = clusters.filter { nc in distance(nc.position, position) < 30.0 }
    
    var closestCluster: NodeCluster? = nil
    var closestNode: Node? = nil
    
    var closestDistance = 30.0
    
    for nc in closeByClusters {
      let d = distance(nc.position, position)
      if d < closestDistance {
        closestDistance = d
        closestNode = nil
        closestCluster = nc
      }
      
      for offset in nc.getOffsetsForSubnodes() {

        
        let nd = distance(offset.0, position)
        if nd < closestDistance {
          closestDistance = nd
          closestNode = offset.1
          closestCluster = nc
        }
      }
    }
    
    if closestCluster !== nil {
      if closestNode !== nil {
        closestCluster!.removeNode(closestNode!)
        let cluster = NodeCluster(closestNode!)
        clusters.append(cluster)
        return cluster
      } else {
        return closestCluster!
      }
    }
    
    return nil
  }
  
  func findClustersInPolygon(_ polygon: [CGVector]) -> [NodeCluster] {
    return clusters.filter { cluster in isPointInPolygon( cluster.position, polygon) }
  }
  
  func removeNodesWithElement(_ element: CanvasElement){
    for cluster in clusters {
      cluster.removeNodesWithElement(element)
    }
  }
  
  func findEnclosingPolygon(_ position: CGVector) -> [CGVector]? {
    let graph = ConnectivityGraph()
    
    var clustersById: [Int: NodeCluster] = [:]
    
    for cluster in clusters {
      for node in cluster.nodes {
        clustersById[cluster.id] = cluster
        var other = node.element.nodes[0]
        if node === other {
          other = node.element.nodes[1]
        }
        if let otherCluster = findClusterwithNode(other) {
          graph.add_edge(cluster.id, otherCluster.id)
        }
      }
    }
    
    let loops = graph.get_base_cycles_disconnected()
    dump(graph)
    dump(loops)
    
    for loop in loops {
      let loopNodes = loop.map({nodeId in clustersById[nodeId]!})
      let positions = loopNodes.map({node in node.position})
      if isPointInPolygon(position, positions) {
        return positions
      }
    }
    
    return nil
  }
  
  func findClusterwithNode(_ node: Node) -> NodeCluster? {
    return clusters.first(where: {cluster in cluster.nodes.contains(where: {n in n === node})})
  }
  
  func render(_ renderer: Renderer) {
    for c in clusters {
      c.render(renderer)
    }
  }
  
  func removeNode(_ node: Node) {
    for cluster in clusters {
      cluster.removeNode(node)
    }
  }
  
  func renderSelection(_ renderer: Renderer) {
    for c in clusters {
      c.renderSelection(renderer)
    }
  }
}

var nodeClusterIds = 0

class NodeCluster {
  let id: Int
  var nodes: [Node] = []
  var position: CGVector
  
  init(_ node: Node) {
    self.nodes.append(node)
    self.position = node.position
    nodeClusterIds += 1
    id = nodeClusterIds
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
  
  func removeNodesWithElement(_ element: CanvasElement) {
    nodes.removeAll(where: {n in n.element === element })
    self.position = average(self.nodes.map({ np in np.position}))
  }
  
  func getOffsetsForSubnodes() -> [(CGVector, Node)] {
    var offsets: [(CGVector, Node)] = []
    
    for node in nodes {
      offsets.append((
        node.element.getOffsetPositionForNode(node),
        node
      ))
    }
    
    return offsets
  }
  

  
  func render(_ renderer: Renderer) {
    renderer.addShapeData(circleShape(pos: position, radius: 4.0, resolution: 8, color: Color(255, 255, 255)))
    renderer.addShapeData(circleShape(pos: position, radius: 3.0, resolution: 8, color: Color(73, 172, 214)))
    
//    for (pos, _) in getOffsetsForSubnodes() {
//      renderer.addShapeData(circleShape(pos: pos, radius: 2.0, resolution: 8, color: Color(73, 172, 214)))
//    }
  }
  
  func renderSelection(_ renderer: Renderer) {
    renderer.addShapeData(circleShape(pos: position, radius: 4.0, resolution: 8, color: Color(73, 172, 214)))
    renderer.addShapeData(circleShape(pos: position, radius: 3.0, resolution: 8, color: Color(255, 255, 255)))
  }
}
