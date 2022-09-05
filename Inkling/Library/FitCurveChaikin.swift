//
//  FitCurveChaikin.swift
//  Inkling
//
//  Created by Marcel on 05/09/2022.
//

import Foundation
import UIKit

func FitCurveChaikin(points: [CGVector], error: CGFloat) -> [CGVector] {
  // Basic guess
  

  var guessSize = 3
  var currentError = 100000.0
  var guess: [CGVector] = []
  
  // Parameterize error over length
  // Compute curve length
  
  while currentError > error {
    print("start iteration")
    guess = generateGuess(points: points, size: guessSize)
    var iterationCount = 0
    var lastDist = 100000.0
    var iterate = true
    
    while iterate == true {
      iterationCount += 1
      let (dist, newGuess) = iterateMove(intitialGuessPoints: guess, points: points)
      guess = newGuess
      
      if lastDist - dist < 0.01 {
        iterate = false
      }
      
      if iterationCount == 100 {
        iterate = false
      }
      lastDist = dist
    }
    
    currentError = lastDist
    print("done iterating", iterationCount, lastDist)
    guessSize += 1
  }
  
  
//  let curve = ChaikinCurve(points: move)
//  let d = biggestDistanceBetweenCurves(points, curve)
  
  return guess
}

func generateGuess(points: [CGVector], size: Int) -> [CGVector] {
  let divisor = size - 1
  let offset = (points.count - 1) / divisor
  var guess: [CGVector] = [
    points[0]
  ]
  
  
  for i in 1..<size-1 {
    guess.append(points[offset * i])
  }
  
  guess.append(points[points.count-1])
  
  return guess
}

func iterateMove(intitialGuessPoints: [CGVector], points: [CGVector]) -> (CGFloat, [CGVector]) {
  //let length = lineLength(points)
  
  let dist = guessWithOffset(guess: intitialGuessPoints, points: points, offset: CGVector(dx:  0.0, dy: 0.0))
  let move = dist * 0.1
  
  let moves = generateMoveSet(guess: intitialGuessPoints, distance: 1.0)
  
  var smallerDist = dist
  var chosenMove = intitialGuessPoints
  
  for move in moves {
    let curve = ChaikinCurve(points: move)
    let d = biggestDistanceBetweenCurves(curve, points)
    if d < smallerDist {
      chosenMove = move
      smallerDist = d
    }
  }
  
  //print(smallerDist, chosenMove)
  
  return (smallerDist, chosenMove)
}

func generateMoveSet(guess: [CGVector], distance: CGFloat) -> [[CGVector]] {
  let slice = guess[1...guess.count-2]
  
  // Generate 10 random moves
  var moveSet: [[CGVector]] = []
  for _ in 0...10 {
    let s: [CGVector] = slice.map({v in
      let angle = CGFloat.random(in: 0...CGFloat.pi * 2.0)
      let offset = CGVector(dx:  distance, dy:  0.0).rotated(angle: angle)
      return v + offset
    })
    moveSet.append([guess[0]] + s + [guess[guess.count - 1]])
  }
  
  return moveSet
  
}

func guessWithOffset(guess: [CGVector], points: [CGVector], offset: CGVector) -> CGFloat {
  let guess = [
    guess[0],
    guess[1] + offset,
    guess[2],
  ]
  // Generate curve
  let curve = ChaikinCurve(points: guess)
  let distance = biggestDistanceBetweenCurves(points, curve)
  
  return distance
}


// Compute Fréchet distance
func biggestDistanceBetweenCurves(_ a: [CGVector], _ b: [CGVector]) -> CGFloat {
  var maxDistance: CGFloat = 0
  
  for p in a {
    let index = findClosestPointInCollection(points: b, point: p, min_dist: 100000.0)
    let cp = b[index]
    //let cp = ClosestPointOnPolyline(line: b, point: p, min_dist: 1000.0)!
    
    let d = distance(p, cp)
    maxDistance += d
//    if d > maxDistance {
//      maxDistance = d
//    }
    
    
  }
  
  // compute average distance
  return maxDistance / CGFloat(a.count)
}
