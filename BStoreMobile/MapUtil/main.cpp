//
//  main.cpp
//  MapUtil
//
//  Created by Water on 14-7-25.
//  Copyright (c) 2014年 Water. All rights reserved.
//

#include "MapUtil.h"
#include <fstream>

string double2string(double d){
    stringstream ss;
    ss << d;
    string rtn;
    ss >> rtn;
    return rtn;
}

int main(int argc, const char * argv[])
{
    /*
    MapUtil map = MapUtil();
    string mapData = "test.jpg 600 400 0 0\n20 0\n20 50\n200 50\n200 200\n600 400\nroad\n0 0 20 0 1 1\n20 0 20 50 1 1\n20 50 200 50 1 1\n200 50 200 200 1 1\n200 200 600 400 1 1\n0 0 20 50 1 1\n20 50 200 200 1 1\n";
    map.initMapData(mapData);
    mapPoint start = mapPoint(2.0, 2.0);
    mapPoint end = mapPoint(201.0,201.0);
    mapPoint origin = mapPoint(-5.0,-5.0);
    vector<mapPoint> paths = map.getPath(start, end, origin, 2.0);
    for (int i = 0; i < paths.size(); i++)
    {
        cout << paths[i].first << "\t" << paths[i].second << endl;
    }
     */
    /*
    vector<mapPoint> mapDataPoints;
    vector<Arc> mapDataRoads;
    string mapData = "map.jpg 650 190 ";
    ifstream ifs("/Users/Water/Documents/XCodeWorkspace/MapUtil/a.csv");
    ifstream ifs2("/Users/Water/Documents/XCodeWorkspace/MapUtil/b.csv");
    string tmp;
    while (getline(ifs, tmp))
    {
        for (int i = 0; i < tmp.size(); i++)
        {
            if (tmp[i] == ';')
            {
                tmp[i] = '\t';
            }
            else
            {
                continue;
            }
        }
        stringstream ss(tmp);
        double x;
        double y;
        while (ss >> x >> y)
        {
            mapPoint tmpPoint;
            tmpPoint.first = x;
            tmpPoint.second = y;
            mapDataPoints.push_back(tmpPoint);
        }
    }
    while (getline(ifs2, tmp))
    {
        for (int i = 0; i < tmp.size(); i++)
        {
            if (tmp[i] == ';')
            {
                tmp[i] = '\t';
            }
            else
            {
                continue;
            }
        }
        cout << "tmp:" << tmp << endl;
        stringstream ss(tmp);
        double x;
        double y;
        double x2;
        double y2;
        while (ss >> x >> y >> x2 >> y2)
        {
            mapPoint tmpPoint;
            tmpPoint.first = x;
            tmpPoint.second = y;
            mapPoint tmpPoint2;
            tmpPoint2.first = x2;
            tmpPoint2.second = y2;
            Arc tmpArc;
            tmpArc.startPoint = tmpPoint;
            tmpArc.endPoint = tmpPoint2;
            tmpArc.weight = 1;
            tmpArc.width = 1;
            mapDataRoads.push_back(tmpArc);
        }
    }
        for (int i = 0; i < mapDataPoints.size(); i++)
    {
        mapData = mapData + double2string(mapDataPoints[i].first) + " " + double2string(mapDataPoints[i].second) + '\n';
    }
    mapData += "road\n";
    for (int i = 0; i < mapDataRoads.size(); i++)
    {
        mapData = mapData + double2string(mapDataRoads[i].startPoint.first) + " " + double2string(mapDataRoads[i].startPoint.second) + " " + double2string(mapDataRoads[i].endPoint.first) + " " + double2string(mapDataRoads[i].endPoint.second) + " " + double2string(mapDataRoads[i].weight) + " " + double2string(mapDataRoads[i].width) + '\n';
    }
    cout << mapData;
    
    
     MapUtil map = MapUtil();
     //string mapData = "test.jpg 600 400 0 0\n20 0\n20 50\n200 50\n200 200\n600 400\nroad\n0 0 20 0 1 1\n20 0 20 50 1 1\n20 50 200 50 1 1\n200 50 200 200 1 1\n200 200 600 400 1 1\n0 0 20 50 1 1\n20 50 200 200 1 1\n";
     map.initMapData(mapData);
     mapPoint start = mapPoint(14.0, 9.0);
     mapPoint end = mapPoint(650.0,188.0);
     mapPoint origin = mapPoint(0.0,0.0);
     vector<mapPoint> paths = map.getPath(start, end, origin, 1.0);
     for (int i = 0; i < paths.size(); i++)
     {
     cout << paths[i].first << "\t" << paths[i].second << endl;
     }
     */
    mapPoint mp(40, 0);
    mapPoint sp(0,0);
    mapPoint ep(100,100);
    
    cout << getDistanceFromPointToLine(mp, sp, ep) << endl;
    
    return 0;
}

