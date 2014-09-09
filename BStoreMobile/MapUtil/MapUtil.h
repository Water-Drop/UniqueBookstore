//
//  MapUtil.h
//  MapUtil
//
//  Created by Water on 14-7-25.
//  Copyright (c) 2014年 Water. All rights reserved.
//

#ifndef MapUtil_MapUtil_h
#define MapUtil_MapUtil_h

#include <vector>
#include <iostream>
#include <cmath>
#include <sstream>

using namespace std;

typedef pair<double, double>  mapPoint;

class Area
{
public:
    int ID;
    int shape;
    mapPoint A_Point;
    mapPoint C_Point;
};

class Arc
{
public:
    mapPoint startPoint;
    mapPoint endPoint;
    double width;
    double length;
    double weight;
};

class MapUtil
{
public:
    int initMapData(string mapData);
    vector<mapPoint> getPath(mapPoint startPoint, mapPoint endPoint, mapPoint originPoint, double times);
private:
    vector<mapPoint> crossPoints;
    vector<Area> bookshelves;
    vector<Area> obstacles;
    vector<Arc> roads;
    int isDirectConnected(mapPoint point1, mapPoint point2);
    int isSameMapPoint(mapPoint point1, mapPoint point2);
    int findStartCrossPoint(mapPoint point);
    int findEndCrossPoint(mapPoint point);
    double mapWidth;
    double mapLength;
    vector<mapPoint> Dijkstra(int startCrossPointIndex, int endCrossPointIndex);
    string mapUrl;
    double getDistance(mapPoint startPoint, mapPoint endPoint);
    vector<mapPoint> transform(vector<mapPoint> originPaths, mapPoint originPoint, double times);
};

double getDistanceFrom2Points(mapPoint startPoint, mapPoint endPoint);
double getDistanceFromPointToLine(mapPoint mp, mapPoint sp, mapPoint ep);
#endif
