//
//  MapNavUtil.cpp
//  MapUtil
//
//  Created by Water on 14-9-6.
//  Copyright (c) 2014年 Water. All rights reserved.
//

#include "MapNavUtil.h"

int MapNavUtil::init(vector<mapPoint> pathsNav)
{
    anchorPointsSize = 5;
    for (unsigned int i = 0; i < anchorPointsSize; i++)
    {
        paths.push_back(pathsNav[i]);
    }
    return 0;
};

int MapNavUtil::addAnchorPoints(mapPoint mp)
{
  if (anchorPoints.size() < anchorPointsSize)
  {
      anchorPoints.insert(anchorPoints.begin(), mp);
  }
  else
  {
      anchorPoints.erase(anchorPoints.end());
      anchorPoints.insert(anchorPoints.begin(), mp);
  }
    return 0;
};

int MapNavUtil::getNextDirection()
{
    int currentDirection = getCurrentDirection();
    if (currentDirection < 0)
    {
      if (paths.size() <= 1)
      {
          return -1; // Can not determine current direction and can not find path direction
      }
      else
      {
          if (paths.size() == 2)
          {
              return 0; // Go Straight!
          }
          else // paths.size() > 2
          {
              if (anchorPoints.size() == 0) // No anchor points
              {
                  int currentPathDirection = getDirection(paths[0], paths[1]);
              }
              else if (getStartIndexOfCurrentRoad() == (paths.size() - 2))
              {
                  return 0; // No next paths, Go Straight!
              }
              else
              {
                  int startIndex = getStartIndexOfCurrentRoad();
                  int currentPathDirection = getDirection(paths[startIndex], paths[startIndex + 1]);
                  int currentDirection = getCurrentDirection();
                  int direction = 0;
                  if (currentDirection == -1)
                  {
                      direction = 1;
                  }
                  else
                  {
                      direction = 0 - ((int)((abs)(currentDirection - currentPathDirection) / 2) * 2 - 1);// 1 right direction -1 wrong direction
                  }
                  int nextPathDirection = getDirection(paths[startIndex + 1], paths[startIndex + 2]);
                  int delDirection = nextPathDirection - currentPathDirection;
                  if (abs(delDirection) >= 4)
                  {
                      if (delDirection > 0)
                      {
                          return 2 * direction; // Turn left
                      }
                      else
                      {
                          return 4 * direction; // Turn right
                          
                      }
                      
                  }
                  else
                  {
                      if (delDirection > 0)
                      {
                          return 4 * direction; // Turn right
                      }
                      else if (delDirection < 0)
                      {
                          return 2 * direction; // Turn left
                      }
                      else
                      {
                          return 0;
                      }
                  }

              }
          }
      }
    }
    else
    {
        
    }
    return 0;
};

double MapNavUtil::getDistanceToNextCorner() // Accuracy = 1e1
{
    double distance = 0;
    if (anchorPoints.size() > 0)
    {
        int pathStartIndex = getStartIndexOfCurrentRoad();
        distance = getDistanceFrom2Point(anchorPoints[0], paths[pathStartIndex + 1]);
        return ((int)((distance / 10) + 0.5)) * 10;
    }
    else
    {
        if (paths.size >= 2)
        {
            return getDistanceFrom2Point(paths[0], paths[1]);
        }
        else
        {
            return 0;
        }
    }
};

int MapNavUtil::getStartIndexOfCurrentRoad()
{
    if (anchorPoints.size() > 0 && paths.size() >= 2)
    {
        int minDistance = getDistanceFromPointToLine(anchorPoints[0], paths[0], paths[1]);
        int minDistanceIndex = 0;
        for (unsigned int i = 1; i < paths.size() - 1; i++)
        {
            if (getDistanceFromPointToLine(anchorPoints[0], paths[i], paths[i + 1]) < minDistance)
            {
                minDistance = getDistanceFromPointToLine(anchorPoints[0], paths[i], paths[i + 1]);
                minDistanceIndex = i;
            }
            else
            {
                continue;
            }
        }
        return minDistanceIndex;
    }
    else
    {
        return 0;
    }
};

int MapNavUtil::getCurrentDirection()
{
    double avgDirection = 0；
    if（anchorPoints.size() <= 1)
    {
        return -1; // Can not determined
    }
    else
    {
        for (unsigned int i = 0; i < anchorPoints.size() - 1; i++)
        {
            avgDirection += getDirection(anchorPoints[i], anchorPoints[i + 1]);
        }
        avgDirection /= (anchorPoints.size() - 1);
    }
    return (int)(avgDirection + 0.5);
};

int MapNavUtil::getDirection(mapPoint startPoint, mapPoint endPoint)
{
    double dx = startPoint.first - endPoint.first;
    double dy = startPoint.second - endPoint.second;
    if (abs(dx) > 2 * abs(dy)) // dy = 0
    {
        if (dx > 0)
        {
            return 4; // South
        }
        else if (dx < 0)
        {
            return 0; // North
        }
        else
        {
            return -1; // Autochthonous
        }
    }
    else if (abs(dy) > 2 * abs(dx)) // dx = 0
    {
        if (dy > 0)
        {
            return 2; // East
        }
        else if (dy < 0)
        {
            return 6; // West
        }
        else
        {
            return -1; // Autochthonous
        }
    }
    else
    {
        if (dx > 0 && dy > 0)
        {
            return 3; // SouthEast
        }
        else if （dx > 0 && dy < 0)
        {
            return 5; // SouthWest
        }
        else if (dx < 0 && dy > 0)
        {
            return 1; // NorthEast
        }
        else if (dx < 0 && dy < 0)
        {
            return 7; // NorthWest
        }
        else
        {
            return -1; // Autochthonous
        }
    }
};