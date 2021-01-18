import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimeCurvePage extends StatefulWidget {
  static const sName = "/test_page";

  @override
  _TimeCurvePageState createState() => _TimeCurvePageState();
}

class _TimeCurvePageState extends State<TimeCurvePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('機器狀態列表'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Text(
                '今日日期：1/18',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
              child: Card(
                color: Colors.lightBlue[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 5.0,
                child: Container(
                  height: 400.0,
                  padding: EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return TimelineTile(
                        alignment: TimelineAlign.manual,
                        lineXY: 0.2,
                        indicatorStyle: IndicatorStyle(
                          width: 40,
                          color: Colors.green,
                          iconStyle: IconStyle(
                            color: Colors.white,
                            iconData: Icons.check,
                          ),
                        ),
                        afterLineStyle: LineStyle(color: Colors.green),
                        beforeLineStyle: LineStyle(color: Colors.green),
                        endChild: Container(
                          margin: EdgeInsets.all(12.0),
                          child: Text(
                            'Index $index',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
