//
//  MapUtil.cpp
//  MapUtil
//
//  Created by Water on 14-7-25.
//  Copyright (c) 2014年 Water. All rights reserved.
//

#include "MapUtil.h"

int MapUtil::initMapData(string mapData)
{
    stringstream ss(mapData);
    ss >> mapUrl;
    ss >> mapLength;
    ss >> mapWidth;
    string tmp_str;
    //init crossPoints
    while (getline(ss, tmp_str))
    {
        if (tmp_str == "road")
        {
            break;
        }
        else
        {
            stringstream tmp_ss(tmp_str);
            double tmp_x;
            double tmp_y;
            tmp_ss >> tmp_x;
            tmp_ss >> tmp_y;
            mapPoint tmp_point(tmp_x, tmp_y);
            crossPoints.push_back(tmp_point);
        }
    }
    //init roads
    while (getline(ss, tmp_str))
    {
        stringstream tmp_ss(tmp_str);
        Arc tmp_arc;
        double tmp_x;
        double tmp_y;
        tmp_ss >> tmp_x;
        tmp_ss >> tmp_y;
        mapPoint tmp_start_point(tmp_x, tmp_y);
        tmp_arc.startPoint = tmp_start_point;
        tmp_ss >> tmp_x;
        tmp_ss >> tmp_y;
        mapPoint tmp_end_point(tmp_x, tmp_y);
        tmp_arc.endPoint = tmp_end_point;
        tmp_ss >> tmp_arc.weight >> tmp_arc.width;
        tmp_arc.length = getDistance(tmp_start_point, tmp_end_point);
        roads.push_back(tmp_arc);
    }
    return 0;
};

vector<mapPoint> MapUtil::getPath(mapPoint startPoint, mapPoint endPoint, mapPoint originPoint, double times)
{
    vector<mapPoint> paths;
    paths.push_back(startPoint);
    vector<mapPoint> crossPaths = Dijkstra(findStartCrossPoint(startPoint), findEndCrossPoint(endPoint));
    for (int i = 0; i < crossPaths.size(); i++)
    {
        paths.insert(paths.begin() + 1 + i, crossPaths[i]);
    }
    paths.push_back(endPoint);
    if (paths.size() > 3)
    {
        if (getDistance(paths[0], endPoint) < getDistance(paths[1], endPoint))
        {
            paths.erase(paths.begin() + 1);
        }
        if (getDistance(startPoint, paths[paths.size() - 1]) < getDistance(startPoint, paths[paths.size() - 2]))
        {
            paths.erase(paths.end() - 2);
        }
    }
    return transform(paths, originPoint, times);
};

int MapUtil::isDirectConnected(mapPoint point1, mapPoint point2)
{
    int isConnected = -1;
    for (int i = 0; i < roads.size(); i++)
    {
        if((isSameMapPoint(roads[i].startPoint, point1) == 0 && isSameMapPoint(roads[i].endPoint, point2) == 0) || (isSameMapPoint(roads[i].endPoint, point1) == 0 && isSameMapPoint(roads[i].startPoint, point2) == 0))
        {
            isConnected = roads[i].length * roads[i].weight;
            cout << point1.first << "," << point1.second << " " << point2.first << "," << point2.second << "is Directed connected with" << isConnected << endl;
            break;
        }
        else
        {
            continue;
        }
    }
    return isConnected;
};

int MapUtil::isSameMapPoint(mapPoint point1, mapPoint point2)
{
    if (abs(point1.first - point2.first) < 0.01 && abs(point1.second - point2.second) < 0.01)
    {
        return 0;
    }
    else
    {
        return -1;
    }
};

int MapUtil::findStartCrossPoint(mapPoint startPoint)
{
    //find the nearest cross point to start
    double distance = pow(mapWidth, 2) + pow(mapLength, 2);
    int rtn_index = -1;
    for (int i = 0; i < crossPoints.size(); i++)
    {
        double tmp_distance = pow(crossPoints[i].first - startPoint.first, 2) + pow(crossPoints[i].second - startPoint.second, 2);
        if (tmp_distance < distance)
        {
            distance = tmp_distance;
            rtn_index = i;
        }
        else
        {
            continue;
        }
    }
    return rtn_index;
};

int MapUtil::findEndCrossPoint(mapPoint endPoint)
{
    //find the nearest cross point to end
    double distance = pow(mapWidth, 2) + pow(mapLength, 2);
    int rtn_index = -1;
    for (int i = 0; i < crossPoints.size(); i++)
    {
        double tmp_distance = pow(crossPoints[i].first - endPoint.first, 2) + pow(crossPoints[i].second - endPoint.second, 2);
        if (tmp_distance < distance)
        {
            distance = tmp_distance;
            rtn_index = i;
        }
        else
        {
            continue;
        }
    }
    return rtn_index;
};

vector<mapPoint> MapUtil::Dijkstra(int startCrossPointIndex, int endCrossPointIndex)
{
    vector<mapPoint> paths;
    vector<double> distance;
    vector<int> unconnected;
    vector<int> previousIndex;
    double maxDistance = pow(mapWidth, 2) + pow(mapLength, 2);
    for(int i = 0; i < crossPoints.size(); i++)
    {
        distance.push_back(maxDistance);
        previousIndex.push_back(-1);
    }
    
    for(int i = 0; i < crossPoints.size(); i++)
    {
        if (i == startCrossPointIndex)
        {
            distance[startCrossPointIndex] = 0;
        }
        else
        {
            if (isDirectConnected(crossPoints[startCrossPointIndex], crossPoints[i]) > 0)
            {
                unconnected.push_back(i);
                distance[i] = isDirectConnected(crossPoints[startCrossPointIndex], crossPoints[i]);
                previousIndex[i] = startCrossPointIndex;
            }
            else
            {
                unconnected.push_back(i);
            }
        }
    }
    while (unconnected.size() != 0)
    {
        cout << "unconnected size: " << unconnected.size() << endl;
        int minDistanceIndex = -1;
        double minDistance = maxDistance;
        for (int i = 0; i < unconnected.size(); i++)
        {
            if(distance[unconnected[i]] < minDistance)
            {
                minDistanceIndex = unconnected[i];
                minDistance = distance[unconnected[i]];
            }
            else
            {
                continue;
            }
        }
        if (minDistanceIndex == endCrossPointIndex)
        {
            break;
        }
        for (int i = 0; i < unconnected.size(); i++)
        {
            if (unconnected[i] == minDistanceIndex)
            {
                unconnected.erase(unconnected.begin()+i);
            }
        }
        for (int i = 0; i < unconnected.size(); i++)
        {
            if (isDirectConnected(crossPoints[minDistanceIndex], crossPoints[unconnected[i]]) > 0)
            {
                cout << "isDirectConnected: " << minDistanceIndex << "\t" << unconnected[i] << endl;
                if (distance[unconnected[i]] > (isDirectConnected(crossPoints[minDistanceIndex], crossPoints[unconnected[i]]) + distance[minDistanceIndex]))
                {
                    distance[unconnected[i]] = isDirectConnected(crossPoints[minDistanceIndex], crossPoints[unconnected[i]]) + distance[minDistanceIndex];
                    previousIndex[unconnected[i]] = minDistanceIndex;
                }
            }
        }
    }
    paths.push_back(crossPoints[endCrossPointIndex]);
    int tmp_previous_index = endCrossPointIndex;
    while (true)
    {
        tmp_previous_index = previousIndex[tmp_previous_index];
        if (tmp_previous_index == -1)
        {
            break;
        }
        else
        {
            paths.insert(paths.begin(), crossPoints[tmp_previous_index]);
            if (tmp_previous_index == startCrossPointIndex)
            {
                break;
            }
            else
            {
                continue;
            }
        }
    }
    return paths;
};

double MapUtil::getDistance(mapPoint startPoint, mapPoint endPoint)
{
    return sqrt(pow(startPoint.first - endPoint.first, 2) + pow(startPoint.second - endPoint.second, 2));
};

vector<mapPoint> MapUtil::transform(vector<mapPoint> originPaths, mapPoint originPoint, double times)
{
    vector<mapPoint> transformedPaths;
    for (int i = 0; i < originPaths.size(); i++)
    {
        mapPoint tmp_mp;
        tmp_mp.first = (originPaths[i].first + originPoint.first) * times;
        tmp_mp.second = (originPaths[i].second + originPoint.second) * times;
        transformedPaths.push_back(tmp_mp);
    }
    return transformedPaths;
};

double getDistanceFrom2Points(mapPoint startPoint, mapPoint endPoint)
{
    return sqrt(pow(startPoint.first - endPoint.first, 2) + pow(startPoint.second - endPoint.second, 2));
};


double getDistanceFromPointToLine(mapPoint mp, mapPoint sp, mapPoint ep)
{
    double cross = (ep.first - sp.first) * (mp.first - sp.first) + (ep.second - sp.second) * (mp.second - sp.second);
    if (cross <= 0) return sqrt((mp.first - sp.first) * (mp.first - sp.first) + (mp.second - sp.second) * (mp.second - sp.second));
    
    double d2 = (ep.first - sp.first) * (ep.first - sp.first) + (ep.second - sp.second) * (ep.second - sp.second);
    if (cross >= d2) return sqrt((mp.first - ep.first) * (mp.first - ep.first) + (mp.second - ep.second) * (mp.second - ep.second));
    
    double r = cross / d2;
    double px = sp.first + (ep.first - sp.first) * r;
    double py = sp.second + (ep.second - sp.second) * r;
    return sqrt((mp.first - px) * (mp.first - px) + (py - mp.second) * (py - mp.second));
};


