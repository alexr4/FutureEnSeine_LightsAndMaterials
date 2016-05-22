class FPSTracking
{
  float w, h;
  int nbFrameToTracks;
  float xPositionIncrement;
  ArrayList<PVector> fpsPositionList;
  Timer samplingTimer;
  int samplingTime;
  boolean isConfig;
  PGraphics trackerImage;

  FPSTracking(int nbFrameToTracks_, float samplingTime_, float w_, float h_)
  {
    if (nbFrameToTracks_ > w_)
    {
      println("Please reduce the number of frames to track or increase the width of the display");
    } else
    {
      w = w_;
      h = h_;
      nbFrameToTracks = nbFrameToTracks_;
      xPositionIncrement = w / nbFrameToTracks;
      fpsPositionList = new ArrayList<PVector>();
      samplingTime = floor(1000/samplingTime_);
      samplingTimer = new Timer(0, samplingTime);
      samplingTimer.start();

      trackerImage = createGraphics(round(w), round(h));

      isConfig = true;
    }
  }

  void run(float frameRateValue)
  {
    if (isConfig)
    {
      if (samplingTimer.isFinished())
      {
        addFrameToHistory(frameRateValue);
        moveFrameOnHistory();
        samplingTimer.start();
      }
      else
      {
        samplingTimer.update();
      }
      drawShape();

      if (fpsPositionList.size () > 0)
      {
        deleteFrameFromHistory();
      }
    }
  }

  void addFrameToHistory(float frameRateValue)
  {
    float x = w;
    float y = map(frameRateValue, 0, 60, h, 5);
    fpsPositionList.add(new PVector(x, y));
  }

  void deleteFrameFromHistory()
  {
    if (fpsPositionList.size() > nbFrameToTracks)
    {
      fpsPositionList.remove(0);
    }
  }

  void moveFrameOnHistory()
  {
    for (int i=0; i<fpsPositionList.size ()-1; i++)
    {
      PVector nv = fpsPositionList.get(i);
      nv.x -= xPositionIncrement;
      fpsPositionList.set(i, nv);
    }
  }

  void drawShape()
  {
    trackerImage.beginDraw();
    if (fpsPositionList.size () > 0)
    {

      trackerImage.pushStyle();
      trackerImage.background(40);

      trackerImage.beginShape();
      trackerImage.strokeWeight(1);
      trackerImage.stroke(255, 220, 0);
      trackerImage.fill(0, 127);
      trackerImage.vertex(0, h);    
      trackerImage.vertex(0, fpsPositionList.get(0).y);
      for (PVector v : fpsPositionList)
      {
        trackerImage.vertex(v.x, v.y);
      }
      trackerImage.vertex(w, h);
      trackerImage.endShape();


      trackerImage.popStyle();


      trackerImage.pushStyle();
      trackerImage.colorMode(HSB, 360, 100, 100, 100);
      float hue = map(fpsPositionList.get(fpsPositionList.size()-1).y, 5, h, 130, 0);
      float fps = map(fpsPositionList.get(fpsPositionList.size()-1).y, 5, h, 60, 0);
      trackerImage.stroke(hue, 100, 100, 50);
      trackerImage.line(0, fpsPositionList.get(fpsPositionList.size()-1).y, w, fpsPositionList.get(fpsPositionList.size()-1).y);
      trackerImage.fill(hue, 100, 100, 50);
      trackerImage.textAlign(LEFT, TOP);
      trackerImage.text(fps, 10, 10);
      trackerImage.popStyle();
    }


    trackerImage.endDraw();
  }

  void reloadTimer()
  {
    samplingTimer.stop();
    samplingTimer.reset();
    samplingTimer.totalTime = round(samplingTime);
    samplingTimer.start();
  }

  //set
  void setSamplingTime(int value)
  {
    samplingTime = floor(1000/value);
  }

  void setTrackerDimension(float w_, float h_)
  {
    w = w_;
    h = h_;
    xPositionIncrement = w / nbFrameToTracks;
    trackerImage = createGraphics(round(w_), round(h_));
  }

  //get
  PImage getImageTracker()
  {
    return trackerImage;
  }
}

// ==================================================
// Timer
// ==================================================
public class Timer {

  int timerId;
  int timerTimeout;
  int savedTime;
  int totalTime;
  int passedTime;
  int remainingTime;
  boolean isFinished, timerStarted, timerPaused;

  Timer(int timerId_, int timerTimeout_) {
    timerId = timerId_;
    timerTimeout = timerTimeout_;
    totalTime = timerTimeout;
    timerStarted = false;
    timerPaused = false;
    isFinished = false;
  }

  public void start() {    
    if (!timerStarted || timerPaused) {
      //println(millis(), "Timer start", this);
      savedTime = millis();
      timerStarted = true;
      timerPaused = false;
      isFinished = false;
    }
  }

  public void pause() {
    if (!timerPaused) {
      //println(frameCount, "Timer Paused", this);
      totalTime = totalTime - passedTime;
      timerPaused = true;
    }
  }

  public void stop() {
    passedTime = 0;
    totalTime = timerTimeout;
    timerStarted = false;
    timerPaused = false;
    isFinished = true;
  }

  public void reset() {
    stop();
    start();
  }

  public void update() {
    //println(frameCount, "Update", timerStarted, timerPaused);
    if (timerStarted && !timerPaused) {
      passedTime = millis() - savedTime;
      remainingTime = totalTime - passedTime; 
      if (passedTime > totalTime) {
        stop();
      }
    }
  }

  public boolean isFinished() {
    return isFinished;
  }

  public int getRemainingTime() {   
    return remainingTime;
  }
  
  public int getPassedTime()
  {
    return passedTime;
  }
  
  
  public int getTotalTime()
  {
    return totalTime;
  }
  
  public void setTimeout(int t_)
  {
    timerTimeout = t_;
    totalTime = timerTimeout;
  }
  
  public float getNormalizedPassedTime()
  {
    return norm(passedTime, 0, timerTimeout);
  }
  
  public float getNormalizedRemainingTime()
  {
    return norm(remainingTime, timerTimeout, 0);
  }
}