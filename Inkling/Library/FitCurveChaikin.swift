//
//  FitCurveChaikin.swift
//  Inkling
//
//  Created by Marcel on 05/09/2022.
//

import Foundation
import UIKit

func fitCurveChaikin(points: [CGVector], initialGuess: [CGVector], error: CGFloat) -> [CGVector] {
  var guess = initialGuess
  
  // Compute equally spaced points on the curve
  let totalCurveLength = lineLength(points)
  let sampleCount = (totalCurveLength / 20.0).rounded()
  let originalSamples = sampleCurve(points, sampleCount)
  
  // Start iterating
  var done = false
  var moveSize = 10.0
  var iterationCount = 0
  
  print("")
  print("Try curve")
  print("sampleCount", sampleCount)
  
  while !done {
    // Compute current fitness
    let currentGuessPoints = sampleCurve(ChaikinCurve(points: guess), sampleCount)
    let currentFitness = computeFitness(originalSamples, currentGuessPoints)
    
    print("currentFitness", currentFitness)
    // If we're close enough then we're done here!
    if currentFitness < error || iterationCount == 100 {
      done = true
    } else {
      // Otherwise gradient descent in the direction of the curve
      let nextMove = computeNextMove(originalSamples: originalSamples, currentFitness: currentFitness,  guess: guess)
      
      // Update guess in the direction of the derivative
      // The first and last point in the guess stay stable, and are not included in the moves
      for i in 0..<nextMove.count {
        guess[i+1].dx += nextMove[i].dx * moveSize
        guess[i+1].dy += nextMove[i].dy * moveSize
      }
      if moveSize > 1.0 {
        moveSize = moveSize * 0.9
      }
      
    }
    
    iterationCount += 1
  }
  
  return guess
}

func sampleCurve(_ points: [CGVector], _ sampleCount: CGFloat) -> [CGVector] {
  let sampleCount = 20.0;
  let curveLengths = lineLengths(points)
  let totalCurveLength = curveLengths.last!
  let lengthOffset = totalCurveLength / sampleCount
  
  var equidistantSampledPoints: [CGVector] = []
  var i: CGFloat = 0
  while i < totalCurveLength {
    equidistantSampledPoints.append(getPointAtLength(lengths: curveLengths, points: points, length: i))
    i += lengthOffset
  }
  
  return equidistantSampledPoints
}

func computeNextMove(originalSamples: [CGVector], currentFitness: CGFloat, guess: [CGVector]) -> [CGVector] {
  // Compute the derivative of the fitness funciton at the current position
  // We can do this by sampling the current position, a pair of x / y offsets for each point
  
  var moves: [CGVector] = []
  for i in 1..<guess.count-1 {
    var newGuessX = guess
    newGuessX[i].dx += 1.0
    let newGuessXCurve = sampleCurve(ChaikinCurve(points: newGuessX), CGFloat(originalSamples.count))
    
    var newGuessY = guess
    newGuessY[i].dy += 1.0
    let newGuessYCurve = sampleCurve(ChaikinCurve(points: newGuessY), CGFloat(originalSamples.count))
      
    moves.append(CGVector(
      dx: currentFitness - computeFitness(originalSamples, newGuessXCurve) ,
      dy: currentFitness - computeFitness(originalSamples, newGuessYCurve)
    ))
  }
  
  // Compute the length of the vector
  var total_length: CGFloat = 0
  for m in moves {
    total_length += m.dx * m.dx
    total_length += m.dy * m.dy
  }
  total_length = total_length.squareRoot()
  
  // Normalize the vector
  for i in 0..<moves.count {
    moves[i].dx /= total_length
    moves[i].dy /= total_length
  }
  
  return moves
}



func computeFitness(_ originalPoints: [CGVector], _ comparePoints: [CGVector]) -> CGFloat {
  var total: CGFloat = 0
  
  for (a, b) in zip(originalPoints, comparePoints) {
    total += distance(a, b)
  }
  
  return total
}

//func FitCurveChaikin(points: [CGVector], error: CGFloat) -> [CGVector] {
//  var points = points
//
//  var guessSize = 3
//  var currentError = 100000.0
//  var guess: [CGVector] = []
//
//  // Parameterize error over length
//  // Compute curve length
//  print("start fitting")
//  while currentError > error {
//    guess = generateGuess(points: points, size: guessSize)
//    var iterationCount = 0
//    var lastDist = 10000.0
//    var iterate = true
//
//    while iterationCount < 500 {
//      iterationCount += 1
//
//      //let moveDist = CGFloat.Exponent( (lastDist / CGFloat(100 - iterationCount) ))
//      let (dist, newGuess) = iterateMove(intitialGuessPoints: guess, points: &points)
//      guess = newGuess
//      let avgDist = dist / lineLength(points)
//
//      if lastDist - avgDist < 0.00000000001 {
//        print("small improvement")
//        break
//      }
//      lastDist = avgDist
//    }
//
//    if lastDist > currentError {
//      print("worse step")
//      break
//    }
//
//    currentError = lastDist
//    print("done iterating", iterationCount, currentError)
//    guessSize += 1
//  }
//
//  print("done fitting", currentError)
//
//
////  let curve = ChaikinCurve(points: move)
////  let d = biggestDistanceBetweenCurves(points, curve)
//
//  return guess
//}
//
//func generateGuess(points: [CGVector], size: Int) -> [CGVector] {
//  let divisor = size - 1
//  let offset = (points.count - 1) / divisor
//  var guess: [CGVector] = [
//    points[0]
//  ]
//
//
//  for i in 1..<size-1 {
//    guess.append(points[offset * i])
//  }
//
//  guess.append(points[points.count-1])
//
//  return guess
//}
//
//func iterateMove(intitialGuessPoints: [CGVector], points: inout [CGVector]) -> (CGFloat, [CGVector]) {
//  var curve = ChaikinCurve(points: intitialGuessPoints)
//  let dist = biggestDistanceBetweenCurves(&curve, &points) / lineLength(points)
//
//  let moves = generateMoveSet(guess: intitialGuessPoints, distance: 1.0)
//
//  var smallerDist = 10000.0
//  var chosenMove = intitialGuessPoints
//
//  for move in moves {
//    var curve = ChaikinCurve(points: move)
//    let d = biggestDistanceBetweenCurves(&curve, &points)
//    if d < smallerDist {
//      chosenMove = move
//      smallerDist = d
//    }
//  }
//
//  //print(smallerDist, chosenMove)
//
//  return (smallerDist, chosenMove)
//}
//
//func generateMoveSet(guess: [CGVector], distance: CGFloat) -> [[CGVector]] {
//  //let slice = guess[1...guess.count-2]
//
//  // Generate a move for each point
//  var moveSet: [[CGVector]] = [guess]
//
//  for i in 1...guess.count-2 {
//    moveSet.append(moveWithOffset(guess, i, distance, 0.0))
//    moveSet.append(moveWithOffset(guess, i, -distance, 0.0))
//    moveSet.append(moveWithOffset(guess, i, 0.0, distance))
//    moveSet.append(moveWithOffset(guess, i, 0.0, -distance))
//  }
//
//  return moveSet
//}
//
//func moveWithOffset(_ guess: [CGVector], _ index: Int, _ x: CGFloat, _ y: CGFloat) -> [CGVector] {
//  var newMove = guess
//  newMove[index] += CGVector(dx: x, dy: y)
//  return newMove
//}
//
//
//// Compute Fréchet distance
//func biggestDistanceBetweenCurves(_ a: inout [CGVector], _ b: inout [CGVector]) -> CGFloat {
//  var totalDistance: CGFloat = 0
//
//  var bIndex = 0
//
//  for aPoint in a {
//    let bPoint = b[bIndex]
//    var prevDist = distance(aPoint, bPoint)
//    var nextDist = prevDist
//    repeat {
//      prevDist = nextDist
//
//      if bIndex < b.count - 1 {
//        bIndex += 1
//      }
//
//      let nextBPoint = b[bIndex]
//      nextDist = distance(aPoint, nextBPoint)
//    } while nextDist < prevDist
//
//    totalDistance += nextDist
//  }
//
//  // compute average distance
//  return totalDistance
//}
