import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:length_unit/length_unit.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/preset_shape_map.dart';

class LengthSlider extends StatefulWidget {
  const LengthSlider({
    this.min,
    this.max,
    this.divisions = 30,
    this.sliderColor = Colors.amber,
    this.sliderValue,
    @required this.valueChanged,
    @required this.constraintSize,
    this.allowedUnits = const ["px"],
  });

  final double min;
  final double max;
  final int divisions;
  final Color sliderColor;
  final List<String> allowedUnits;
  final Length sliderValue;
  final double constraintSize;

  final ValueChanged valueChanged;

  @override
  _LengthSlider createState() => _LengthSlider();
}

class _LengthSlider extends State<LengthSlider> {
  Length _sliderValue;

  double min;
  double max;
  int divisions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sliderValue != null) {
      _sliderValue = widget.sliderValue
          .copyWith(value: widget.sliderValue.value.roundWithPrecision(1));
    } else {
      if (widget.min != null && widget.max != null) {
        _sliderValue = Length((widget.min + widget.max) / 2);
      } else {
        _sliderValue = Length(1);
      }
    }

    if (_sliderValue.unit == LengthUnit.px) {
      min = widget.min ?? 0.0;
      max = widget.max ?? widget.constraintSize.roundWithPrecision(1);
      divisions = ((max - min) > 10 ? (max - min) / 5 : (max - min)).round();
    } else {
      min = 0;
      max = 100.0;
      divisions = widget.divisions;
    }

    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(top: 3.0),
                  alignment: Alignment.center,
                  child: Offstage(
                    offstage: _sliderValue == null,
                    child: Slider(
                      activeColor: widget.sliderColor,
                      min: min,
                      max: max,
                      divisions: divisions,
                      //label:
                      //    '${((_sliderValue.value ?? 0) * 100).round() / 100.0}',
                      value: (_sliderValue.value ?? 0).clamp(min, max),
                      onChanged: (newValue) {
                        setState(() {
                          //textController.text =
                          //    '${newValue.roundWithPrecision(1)}';
                          widget.valueChanged(widget.sliderValue.copyWith(value: newValue));
                        });
                      },
                    ),
                  ))),
          //editable text field
          Container(
            decoration: BoxDecoration(
              color: Colors.black38,
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            width: 100,
            height: 40,
            margin: EdgeInsets.only(right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _sliderValue != null
                    ? Container(
                        alignment: Alignment.centerLeft,
                        width: 50,
                        child: FocusTextField(
                          key: ObjectKey(_sliderValue.value),
                          initText: _sliderValue.value.toStringAsFixed(1),
                          onSubmitted: (value) {
                            double newValue=double.tryParse(value) ?? widget.sliderValue.value;
                            widget.valueChanged(widget.sliderValue.copyWith(value: newValue));
                          },
                        ))
                    : Container(
                        width: 10,
                      ),
                Container(
                  width: _sliderValue != null ? 38 : 50,
                  height: 30,
                  margin: EdgeInsets.only(right: 4),
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.25),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  alignment: Alignment.center,
                  child: DropdownButton<String>(
                    elevation: 1,
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.1,
                        color: Colors.black),
                    isDense: true,
                    isExpanded: true,
                    iconSize: 0,
                    underline: Container(),
                    value: _sliderValue.getUnit(),
                    onChanged: (String value) {
                      setState(() {
                        ///avoid null for non auto values
                        double oldPX = _sliderValue.toPX(
                              constraintSize: widget.constraintSize,
                            ) ??
                            100;
                        LengthUnit newUnit =
                            lengthUnitMap[value] ?? LengthUnit.px;
                        widget.valueChanged(_sliderValue.copyWith(
                            value: Length.newValue(
                              oldPX,
                              newUnit,
                              constraintSize: widget.constraintSize,
                            ),
                            unit: newUnit));
                        //myController.text =
                        //    '${(_sliderValue.value * 100).round() / 100.0}';
                      });
                    },
                    items: widget.allowedUnits
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(width: 100, child: Text(value)),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class FixedUnitValuePicker extends StatefulWidget {

  final double value;
  final String unit;
  final Function onValueChanged;

  FixedUnitValuePicker({this.value, this.unit, this.onValueChanged});

  @override
  _FixedUnitValuePickerState createState() => _FixedUnitValuePickerState();
}

class _FixedUnitValuePickerState extends State<FixedUnitValuePicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        border: Border.all(width: 1, color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      width: 100,
      height: 40,
      margin: EdgeInsets.only(right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              width: 50,
              child: FocusTextField(
                key: ObjectKey(widget.value),
                initText: widget.value.toStringAsFixed(1),
                onSubmitted: (value) {
                  double newValue=double.tryParse(value) ?? widget.value;
                  widget.onValueChanged(newValue);
                },
              ))
              ,
          Container(
            width: 38,
            height: 30,
            margin: EdgeInsets.only(right: 4),
            padding: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.25),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            alignment: Alignment.center,
            child:  Text(widget.unit, style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.1,
                color: Colors.black),)
          )
        ],
      ),
    );
  }
}

class OffsetPicker extends StatefulWidget {
  final Offset position;
  final Size constraintSize;
  final Function onPositionChanged;

  const OffsetPicker(
      {this.position, this.onPositionChanged, this.constraintSize});

  @override
  _OffsetPickerState createState() => _OffsetPickerState();
}

class _OffsetPickerState extends State<OffsetPicker> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 50,
      child: Row(
        children: [
          Text("X  "),
          FixedUnitValuePicker(
            value: widget.position.dx,
            onValueChanged: (value) {
              widget.onPositionChanged(Offset(value, widget.position.dy));
            },
            unit: "px",
          ),
          Container(width: 10,),
          Text("Y  "),
          FixedUnitValuePicker(
            value: widget.position.dy,
            onValueChanged: (value) {
              widget.onPositionChanged(Offset(widget.position.dx, value));
            },
            unit: "px",
          ),
        ],
      ),
    );
  }
}

class FocusTextField extends StatefulWidget {

  final String initText;
  final Function onSubmitted;

  const FocusTextField({Key key, this.initText, this.onSubmitted}): super(key: key);

  @override
  _FocusTextFieldState createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<FocusTextField> {

  TextEditingController textController;
  FocusNode focus;
  String hintText;
  bool hasSubmitted=false;

  @override
  void initState() {
    super.initState();

    hintText=widget.initText;
    focus = FocusNode();
    focus.addListener(() {
      if(focus.hasFocus) {
        textController.text= widget.initText;
      }else{
        textController.clear();
      }
    });
    textController =
        TextEditingController(text: widget.initText);
    textController.addListener(() {

      if(textController.text.isEmpty) {
        if(!hasSubmitted) {
          setState(() {
            hintText="";
          });
        }
        else{
          setState(() {
           hasSubmitted=false;
           hintText=widget.initText;
          });
        }

      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return TextField(
      focusNode: focus,
      textAlign: TextAlign.center,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.all(0),
      ),
      style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
          color: Colors.white),
      controller: textController,
      onSubmitted: (value) {
        if(value.isEmpty) {
          setState(() {
            hasSubmitted=true;
          });
        }else{
          widget.onSubmitted(value);
        }
      },
    );
  }

  @override
  void dispose() {
    focus.dispose();
    textController.dispose();
    super.dispose();
  }

}

bool useWhiteForeground(Color color) {
  return 1.05 / (color.computeLuminance() + 0.05) > 4.5;
}

typedef PickerLayoutBuilder = Widget Function(
    BuildContext context, List<String> allShape, PickerItem child);
typedef PickerItem = Widget Function(String shape);
typedef PickerItemBuilder = Widget Function(
    String shape,
    bool isCurrentShape,
    void Function() changeShape,
    );

class BlockShapePicker extends StatefulWidget {
  const BlockShapePicker({
    @required this.onShapeChanged,
    this.itemBuilder = defaultItemBuilder,
  });

  final ValueChanged<String> onShapeChanged;
  final PickerItemBuilder itemBuilder;

  static Widget defaultItemBuilder(
      String shape, bool isCurrentShape, void Function() changeShape) {
    return Material(
      clipBehavior: Clip.antiAlias,
      type: MaterialType.canvas,
      shape: MorphableShapeBorder(
          shape: presetShapeMap[shape]??RectangleShape(borderRadius: DynamicBorderRadius.all(DynamicRadius.zero)),
          borderWidth: isCurrentShape ? 4 : 2,
          borderColor: isCurrentShape ? Colors.black87 : Colors.grey),
      child: Container(
        color:
        isCurrentShape ? Colors.grey.withOpacity(0.25) : Colors.transparent,
        child: InkWell(
          onTap: changeShape,
          radius: 60,
          child: Container(),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _BlockShapePickerState();
}

class _BlockShapePickerState extends State<BlockShapePicker> {
  String _currentShape;

  @override
  void initState() {
    _currentShape = "Rectangle";
    super.initState();
  }

  void changeShape(String shape) {
    setState(() => _currentShape = shape);
    widget.onShapeChanged(shape);
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      width: orientation == Orientation.portrait ? 300.0 : 300.0,
      height: orientation == Orientation.portrait ? 360.0 : 200.0,
      child: GridView.count(
        crossAxisCount: orientation == Orientation.portrait ? 4 : 6,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        children: presetShapeMap.keys
            .map((String shape) => widget.itemBuilder(
            shape, shape == _currentShape, () => changeShape(shape)))
            .toList(),
      ),
    );
  }
}

class BottomSheetShapePicker extends StatefulWidget {
  BottomSheetShapePicker({
    this.headText = "Pick a shape",
    this.currentShape,
    @required this.valueChanged,
  });

  final String headText;
  final Shape currentShape;
  final ValueChanged valueChanged;

  @override
  _BottomSheetShapePicker createState() => _BottomSheetShapePicker();
}

class _BottomSheetShapePicker extends State<BottomSheetShapePicker> {
  Shape currentShape;

  @override
  void initState() {
    currentShape = widget.currentShape ?? RectangleShape();
    super.initState();
  }

  void changeShape(String shape) {
    setState(() => currentShape = presetShapeMap[shape]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(0),
        child: RawMaterialButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(widget.headText,

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),)),
                        BlockShapePicker(
                          onShapeChanged: changeShape,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Got it'),
                      onPressed: () {
                        setState(() {
                          widget.valueChanged(currentShape);
                        });
                        Navigator.of(context)?.pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(
            Icons.streetview_outlined,
            size: 28,
          ),
          elevation: 5.0,
          constraints: BoxConstraints.tight(Size(24, 24)),
          padding: const EdgeInsets.all(0.5),
        ));
  }
}
