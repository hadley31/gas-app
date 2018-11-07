import 'package:gas_app/firebase_user_auth.dart';
import 'package:gas_app/firebase_user_data.dart';
import 'package:flutter/material.dart';

import 'package:gas_app/helper_functions.dart';

class SettingsMenu extends StatefulWidget {
  @override
  createState() => SettingsState();
}

class SettingsState extends State<SettingsMenu> {
  _signIn() {
    showSignInPage(context);
  }

  _signOut() async {
    await UserAuth.signOut();
    setState(() {});
  }

  _manageCars() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => _ManageCarsPage()));
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Settings')),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          MaterialButton(
            child: Text('Manage Cars'),
            color: Colors.blueGrey,
            onPressed: UserAuth.signedIn() ? _manageCars : null,
          ),
          Divider(),
          !UserAuth.signedIn()
              ? MaterialButton(
                  child: Text('Sign in'),
                  color: Colors.blueGrey,
                  onPressed: _signIn,
                )
              : MaterialButton(
                  child: Text('Sign Out'),
                  color: Colors.red,
                  onPressed: _signOut,
                ),
        ],
      ),
    );
  }
}

class _ManageCarsPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Cars')),
      body: UserCarStream(builder: (BuildContext context, List<UserCar> cars) {
        if (cars != null && cars.length > 0) {
          return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                return _CarListElement(cars[index]);
              });
        } else {
          return Center(
            child: Text('No car entries found.'),
          );
        }
      }),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => _CarForm()));
        },
      ),
    );
  }
}

class _CarListElement extends StatelessWidget {
  final UserCar car;

  const _CarListElement(this.car) : assert(car != null);

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
        color: Colors.grey[800],
        elevation: 10.0,
        child: Center(
          child: Text(car.toString()),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => _CarForm()));
        },
      ),
    );
  }
}

class _CarForm extends StatefulWidget {
  @override
  createState() => _CarFormState();
}

class _CarFormState extends State<_CarForm> {
  final _formKey = GlobalKey<FormState>();

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearTextController = TextEditingController();

  final _makeNode = FocusNode();
  final _modelNode = FocusNode();
  final _yearNode = FocusNode();

  bool _submitEnabled = false;

  _validate() {
    return !isNullOrEmpty(_makeController.text) && !isNullOrEmpty(_modelController.text) && !isNullOrEmpty(_yearTextController.text);
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

    String make = _makeController.text;
    String model = _modelController.text;
    int year = int.tryParse(_yearTextController.text);

    final result = {
      'make': make,
      'model': model,
      'year': year,
    };

    Navigator.pop(context, result);
  }

  @override
  build(BuildContext context) {
    _submitEnabled = _validate();

    return Scaffold(
      appBar: AppBar(title: Text('New Car')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Make',
                hintText: 'The maker of the car',
                icon: Icon(Icons.directions_car),
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_modelNode);
              },
              focusNode: _makeNode,
              controller: _makeController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'The model of the car',
                icon: Icon(Icons.directions_car),
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_yearNode);
              },
              focusNode: _modelNode,
              controller: _modelController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'The year the car was manufactured',
                icon: Icon(Icons.calendar_today),
              ),
              keyboardType: const TextInputType.numberWithOptions(),
              textInputAction: TextInputAction.done,
              focusNode: _yearNode,
              controller: _yearTextController,
            ),
            RaisedButton(
              child: Text('Add'),
              onPressed: _submitEnabled ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
