private final ArrayList<Shape> _shapes = new ArrayList<Shape>(); //<>// //<>//
private ArrayList<AlphaShape> _alphaShapes = new ArrayList<AlphaShape>();
private float _radius = 350;
private final float _initialAngleOffset = 0;
private final float _iterationsMax = 25;

private color _currentStrokeColour;
private int _pointCount = 4;
private Point _center;
private float _iterations;
private PImage _glow;
private float _startHue;
private float _endHue;
private float _startSat;
private float _endSat;
private float _normalisedProgress;

public void setup() {
  //size(600, 600, P2D);
  fullScreen(P2D);
  pixelDensity(2);
  noStroke();
  colorMode(HSB);
  strokeWeight(2);
  _center = new Point(width / 2f, height / 2f);
  _radius = random(200, 350);
  _pointCount = (int)random(3, 8);
  CreateGlow();
  Initialise();
}

private void CreateGlow() {
  _glow = createImage(width, height, ARGB);
  color glowColour = color(0, 0, 50);
  color backgroundColour = color(0, 0, 15); 
  for (int x = 0; x < width; ++x) {
    for (int y = 0; y < height; ++y) {
      float xDiff = x - _center.X;
      float yDiff = y - _center.Y;
      float distance = xDiff * xDiff + yDiff * yDiff;
      distance = sqrt(distance);
      float lerpVal = distance / 800f;
      if (lerpVal > 1) lerpVal = 1;
      color bgColour = lerpColor(glowColour, backgroundColour, lerpVal);
      _glow.set(x, y, bgColour);
    }
  }
}

void mouseClicked() {
  _radius = random(200, 350);
  _pointCount = (int)random(3, 6);
  Initialise();
}

private class Point {
  public final float X;
  public final float Y;

  public Point(float x, float y) {
    X = x;
    Y = y;
  }
}

private Point midPoint(Point a, Point b) {
  float x = (a.X + b.X) / 2f;
  float y = (a.Y + b.Y) / 2f;
  return new Point(x, y);
}

private void setColours() {
  _startHue = random(0, 255);
  float hueOffset = random(30, 70);
  if (random(0, 2) > 1) hueOffset = -hueOffset;
  _endHue = _startHue + hueOffset;
  if (_endHue < 0) _endHue += 255;
  else if (_endHue > 255) _endHue -= 255;
  _startSat = random(100, 140);
  _endSat = _startSat - random(20, 60);
}

private void Initialise() {
  loop();
  _waitCount = 0;
  setColours();
  _iterations = 1;
  _shapes.clear();
  for (int i = 0; i < _pointCount; ++i) {
    float angle = (2 * PI) / _pointCount * i + _initialAngleOffset;
    Point point = calculatePoint(angle, _radius, _center);
    Shape shape = new Shape(point, angle);
    _shapes.add(shape);
  }
}

private void clearBackground() {
  background(color(0, 0, 20, 1));
  image(_glow, 0, 0);
}

private Point calculatePoint(float angle, float radius, Point origin) {
  float x = sin(angle) * radius + origin.X;
  float y = cos(angle) * radius + origin.Y;
  return new Point(x, y);
}

private float _waitCount = 0;
private final float _waitCountMax = 5;

private boolean canDraw() {
  if (_waitCount != 0) {
    --_waitCount;
    return false;
  }
  _waitCount = _waitCountMax;
  return true;
}

private boolean reachedMaxIterations() {
  return _iterations >= _iterationsMax;
}

private class Shape {
  private final Point _origin;
  private final Point _barycenter;
  private final float _angleOffset;

  public Shape(Point origin, float angleOffset) {
    _origin = origin;
    _barycenter = midPoint(origin, _center);
    _angleOffset = angleOffset;
  }

  public void drawShape() {
    Point center = lerp(_barycenter, _origin, _normalisedProgress);
    float radius = radius(_origin, center);
    float angleIncrement = (2 * PI) / _pointCount;
    float angle = _angleOffset;
    PShape line =createShape();
    line.beginShape();
    line.fill(0, 0, 0, 0);
    line.strokeWeight(1);
    line.stroke(_currentStrokeColour);
    for (int i = 0; i < _pointCount; ++i) {
      Point point = calculatePoint(angle, radius, center);
      angle += angleIncrement;
      Point nextPoint = calculatePoint(angle, radius, center);
      line.vertex(point.X, point.Y);
      line.vertex(nextPoint.X, nextPoint.Y);
    }
    line.endShape();
    _currentShape.addChild(line);
  }

  private float radius(Point a, Point b) {
    float dX = a.X - b.X;
    float dY = a.Y - b.Y;
    return sqrt(dX * dX + dY * dY);
  }

  private Point lerp(Point a, Point b, float lerpVal) {
    float xLerp = (a.X - b.X) * lerpVal + a.X;
    float yLerp = (a.Y - b.Y) * lerpVal + a.Y;
    return new Point(xLerp, yLerp);
  }
}

private void updateStrokeColour() {

  float normalisedIterations = _normalisedProgress * 30;
  float alphaMod = 0.8f - (_iterationsMax / 1000);
  float alpha = pow(alphaMod, normalisedIterations) * 255;
  float hue = lerp(_startHue, _endHue, _normalisedProgress);
  float sat = lerp(_startSat, _endSat, _normalisedProgress);
  _currentStrokeColour = color(hue, sat, 255, alpha);
}

private PShape _currentShape;
private class AlphaShape {
  private final PShape _shapeImage;
  private float _alpha = 0f;
  private final color _colour;
  private boolean _reachedFullAlpha = false;

  public AlphaShape(PShape shapeImage) {
    _colour = _currentStrokeColour;
    _shapeImage = shapeImage;
    _alpha = alpha(_currentStrokeColour);
  }

  public boolean tryDraw() {
    if (_alpha <= 0 && _reachedFullAlpha) return false;
    if (!_reachedFullAlpha) {
      _alpha += 10f;
      if (_alpha >= 255) {
        _alpha = 255;
        _reachedFullAlpha = true;
      }
    } else {
      _alpha -= 2f;
    }
    color c = color(hue(_colour), saturation(_colour), brightness(_colour), _alpha);
    _shapeImage.setStroke(c);
    shape(_shapeImage, 0, 0);
    return true;
  }
}

private void updateAlphaShapes() {
  for (int i = _alphaShapes.size() - 1; i >= 0; --i) {
    if (_alphaShapes.get(i).tryDraw()) continue;
    _alphaShapes.remove(i);
  }
}

public void draw() {
  clearBackground();
  updateAlphaShapes();
  if (!canDraw()) return;
  if (reachedMaxIterations()) {
    if (_alphaShapes.size() == 5) Initialise();
    return;
  }
  _currentShape = createShape(GROUP);
  _normalisedProgress = _iterations / _iterationsMax;
  updateStrokeColour();
  for (Shape shape : _shapes) {
    shape.drawShape();
  }
  _alphaShapes.add(new AlphaShape(_currentShape));
  ++_iterations;
}
