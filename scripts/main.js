function onStrokeEnd(points) {
  console.log('-' + points[0]);
  console.log(points.length);
  console.log('got a stroke!');
}

function onCanvasElementAdded(element) {
  console.log('element added');
  for (const k in element) {
    console.log(`${k}: ${element[k]}`);
  }
}

function onCanvasElementRemoved(element) {
  console.log('element removed');
}
