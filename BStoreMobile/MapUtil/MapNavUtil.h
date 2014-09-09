//
//  MapNavUtil.h
//  MapUtil
//
//  Created by Water on 14-9-6.
//  Copyright (c) 2014年 Water. All rights reserved.
//

#ifndef __MapUtil__MapNavUtil__
#define __MapUtil__MapNavUtil__

#include <iostream>
#include <vector>
#include "MapUtil.h"

class MapNavUtil
{
public:
    int init(vector<mapPoint> pathsNav);
    int addAnchorPoints(mapPoint mp);
    int getNextDirection();
    double getDistanceToNextCorner();
private:
    int anchorPointsSize;
    vector<mapPoint> anchorPoints;
    vector<mapPoint> paths;
    int getStartIndexOfCurrentRoad();
    int getCurrentDirection();
    int getDirection(mapPoint startPoint, mapPoint endPoint);
};

#endif /* defined(__MapUtil__MapNavUtil__) */
