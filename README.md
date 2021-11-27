# ruler_picker

This is a picker with ruler style for flutter.


# demo

![demo](https://i.imgur.com/zYizFdT.gif)

# Usage

```
RulerPicker(
  controller: _rulerPickerController,
  onValueChange: (value) {
    setState(() {
      _textEditingController.text = value.toString();
    });
  },
  width: 300,
  height: 100,
),
```
# Example

./example

# TODO

- [ ] multiple precision
- [ ] custom marker
- [ ] start and end range