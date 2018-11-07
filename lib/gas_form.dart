import 'package:gas_app/helper_functions.dart';
import 'package:gas_app/firebase_user_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> showGasForm(BuildContext context, {String documentID}) async {
  return await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => _GasForm()));
}

// Define a Custom Form Widget
class _GasForm extends StatefulWidget {
  @override
  createState() => _GasFormState();
}

// Define a corresponding State class. This class will hold the data related to
// the form.
class _GasFormState extends State<_GasForm> {
  final _stations = ['Walmart', 'Parker\'s', 'Flash Foods', 'Other'];

  final _formKey = GlobalKey<FormState>();

  String _stationDropdownValue;
  String _station;

  final _otherStationTextController = TextEditingController();
  final _milesTextController = TextEditingController();
  final _costTextController = TextEditingController();
  final _gallonsTextController = TextEditingController();

  final _otherStationNode = FocusNode();
  final _milesNode = FocusNode();
  final _costNode = FocusNode();
  final _gallonsNode = FocusNode();

  bool _submitEnabled = false;

  _GasFormState() {
    _otherStationTextController.addListener(_updateSubmitEnabled);
    _milesTextController.addListener(_updateSubmitEnabled);
    _costTextController.addListener(_updateSubmitEnabled);
    _gallonsTextController.addListener(_updateSubmitEnabled);
  }

  _validate() {
    return !isNullOrEmpty(_station) &&
        !isNullOrEmpty(_milesTextController.text) &&
        !isNullOrEmpty(_costTextController.text) &&
        !isNullOrEmpty(_gallonsTextController.text);
  }

  _updateSubmitEnabled() {
    setState(() {
      _submitEnabled = _validate();
    });
  }

  _submit() {
    if (!UserAuth.signedIn()) {
      showMustSignInError(context);
      return;
    }

    if (!_validate()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('An error occured!'),
            content: const Text('Make sure you filled in all the fields correctly.'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Okay'),
              ),
            ],
          );
        },
      );
      return;
    }

    // If we have made it this far w/o returning, we can go ahead and return the result

    double miles = double.tryParse(_milesTextController.text);
    double cost = double.tryParse(_costTextController.text);
    double gal = double.tryParse(_gallonsTextController.text);

    final result = {
      'date': DateTime.now(),
      'station': _station,
      'miles': miles,
      'cost': cost,
      'gallons': gal,
    };

    Navigator.pop(context, result);
  }

  @override
  build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return Scaffold(
      appBar: AppBar(title: Text('New Submission')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            InputDecorator(
              decoration: const InputDecoration(
                icon: Icon(Icons.location_on),
                labelText: 'Gas Station',
              ),
              isEmpty: isNullOrEmpty(_station),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _stationDropdownValue,
                  isDense: true,
                  onChanged: (value) {
                    setState(() {
                      _stationDropdownValue = value.toString();
                      if (_stationDropdownValue == 'Other') {
                        FocusScope.of(context).requestFocus(_otherStationNode);
                      } else {
                        _station = value;
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    });
                  },
                  items: _stations.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            _stationDropdownValue == 'Other'
                ? TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Other Gas Station',
                      hintText: 'Enter an unlisted gas station',
                      icon: Icon(Icons.location_on),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    focusNode: _otherStationNode,
                    controller: _otherStationTextController,
                    onFieldSubmitted: (value) {
                      _station = value;
                      FocusScope.of(context).requestFocus(_milesNode);
                    },
                  )
                : Container(),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Miles',
                hintText: 'Enter the total miles you travelled',
                suffixText: 'mi.',
                icon: Icon(Icons.time_to_leave),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_costNode);
              },
              focusNode: _milesNode,
              controller: _milesTextController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Total Cost',
                hintText: 'Enter the total cost',
                prefixText: '\$',
                icon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_gallonsNode);
              },
              focusNode: _costNode,
              controller: _costTextController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Gallons',
                hintText: 'Enter the total gallons',
                suffixText: 'gal.',
                icon: Icon(Icons.local_gas_station),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              focusNode: _gallonsNode,
              controller: _gallonsTextController,
            ),
            RaisedButton(
              child: Text('Submit'),
              onPressed: _submitEnabled ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
