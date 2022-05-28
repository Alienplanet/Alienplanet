import 'package:equalizer/equalizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_xlider/flutter_xlider.dart';

class EqualizerPage extends StatefulWidget {
  const EqualizerPage() : super();

  @override
  _EqualizerState createState() => _EqualizerState();
}

class _EqualizerState extends State<EqualizerPage> {

  bool enableCustomEQ = false;

  @override
  void initState() {
    super.initState();
    Equalizer.init(0);
  }

  @override
  void dispose() {
    Equalizer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 10.0),
          Container(
            color: Colors.grey.withOpacity(0.1),
            child: SwitchListTile(
              title: Text('Custom Equalizer'),
              value: enableCustomEQ,
              onChanged: (value) {
                Equalizer.setEnabled(value);
                setState(() {
                  enableCustomEQ = value;
                });
              },
            ),
          ),
          FutureBuilder<List<int>>(
            future: Equalizer.getBandLevelRange(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? CustomEQ(enableCustomEQ, snapshot.data!.toList())
                  : CircularProgressIndicator();
            },
          ),
          SizedBox(height: 10,),
          Center(
            child: Builder(
              builder: (context) {
                var FlatButton;
                return
                  FlatButton.icon(
                  icon: Icon(Icons.equalizer),
                  label: Text('Open device equalizer'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () async {
                    try {
                      await Equalizer.open(0);
                    } on PlatformException catch (e) {
                      final snackBar = SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('${e.message}\n${e.details}'),
                      );
                      // Scaffold.of(context).showSnackBar(snackBar);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomEQ extends StatefulWidget {
  const CustomEQ(this.enabled, this.bandLevelRange);

  final bool enabled;
  final List<int> bandLevelRange;

  @override
  _CustomEQState createState() => _CustomEQState();
}

class _CustomEQState extends State<CustomEQ> {
  late double min, max;
  late String _selectedValue;
  late Future<List<String>> fetchPresets;

  @override
  void initState() {
    super.initState();
    min = widget.bandLevelRange[0].toDouble();
    max = widget.bandLevelRange[1].toDouble();
    fetchPresets = Equalizer.getPresetNames();
  }

  @override
  Widget build(BuildContext context) {
    int bandId = 0;

    return FutureBuilder<List<int>>(
      future: Equalizer.getCenterBandFreqs(),
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: snapshot.data
                  !.map((freq) => _buildSliderBand(freq, bandId++))
                  .toList(),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildPresets(),
            ),
          ],
        )
            : CircularProgressIndicator();
      },
    );
  }

  Widget _buildSliderBand(int freq, int bandId) {
    return Column(
      children: [
        SizedBox(
          height: 250.0,
          child: FutureBuilder<int>(
            future: Equalizer.getBandLevel(bandId),
            builder: (context, snapshot) {
              return FlutterSlider(
                disabled: !widget.enabled,
                axis: Axis.vertical,
                rtl: true,
                min: min,
                max: max,
                trackBar: FlutterSliderTrackBar(
                  inactiveTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black12,
                    border: Border.all(width: 10, color: Colors.black87),
                    boxShadow: [
                      new BoxShadow(
                        color: Color(0XFF171717),
                        offset: Offset(-3.0, -3.0),
                        blurRadius: 3.0,
                      ),
                      new BoxShadow(
                        color: Color(0XFF404040),
                        offset: Offset(1.0, 1.0),
                        blurRadius: 0.5,
                      ),
                    ],
                  ),
                  activeTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      new BoxShadow(
                        color: Color(0XFF171717),
                        offset: Offset(-3.0, -3.0),
                        blurRadius: 3.0,
                      ),
                      new BoxShadow(
                        color: Color(0XFF404040),
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [Color(0xFF00C9FF), Color(0xFF92fe9d)],
                      begin: Alignment(-1, -1),
                      end: Alignment(1.0, 1.0),
                    ),
                  ),
                ),
                values: [snapshot.hasData ? snapshot.data!.toDouble() : 0],
                onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                  Equalizer.setBandLevel(bandId, lowerValue.toInt());
                },
              );
            },
          ),
        ),
        Text('${freq ~/ 1000} Hz'),
      ],
    );
  }

  Widget _buildPresets() {
    return FutureBuilder<List<String>>(
      future: fetchPresets,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final presets = snapshot.data;
          if (presets!.isEmpty) return Text('No presets available!');
          return DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Available Presets',
              border: OutlineInputBorder(),
            ),
            value: _selectedValue,
            onChanged: widget.enabled
                ? (String? value) {
              Equalizer.setPreset(value);
              setState(() {
                _selectedValue = value!;
              });
            }
                : null,
            items: presets.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        } else if (snapshot.hasError)
          return Text(snapshot.error.toString());
        else
          return CircularProgressIndicator();
      },
    );
  }
}