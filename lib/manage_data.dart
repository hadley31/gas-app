import 'package:gas_app/firebase_user_data.dart';
import 'package:gas_app/firebase_user_auth.dart';
import 'package:gas_app/gas_form.dart';

import 'package:flutter/material.dart';

class ManageDataPage extends StatelessWidget {
  _createNewEntry(BuildContext context) async {
    final entry = await showGasForm(context);

    if (entry != null) {
      updateUserSubmission(map: entry);
    }
  }

  @override
  build(context) {
    return Scaffold(
      body: UserAuth.signedIn()
          ? UserSubmissionStream(builder: (BuildContext context, List<UserSubmission> submissions) {
              if (submissions != null && submissions.length > 0) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    return _SubmissionListElement(submissions[index]);
                  },
                );
              } else {
                return Center(
                  child: Text('No submissions found.'),
                );
              }
            })
          : Center(
              child: MaterialButton(
                child: Text('Sign In'),
                color: Colors.blueGrey,
                onPressed: () => showSignInPage(context),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _createNewEntry(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _SubmissionListElement extends StatelessWidget {
  final UserSubmission submission;

  _SubmissionListElement(this.submission);

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
        color: Colors.grey[800],
        elevation: 10.0,
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  submission.station,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 15.0),
                ),
                Text('${submission.date.month}/${submission.date.day}/${submission.date.year}'),
              ],
            ),
            Expanded(child: Container()),
            Column(
              children: <Widget>[
                Text(submission.miles.toString() + ' mi.'),
                Text('\$' + submission.cost.toString()),
                Text(submission.gallons.toString() + ' gal.'),
              ],
            ),
          ],
        ),
        onPressed: () {
          _openEditPage(context);
        },
      ),
    );
  }

  _openEditPage(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => _EditSubmissionPage(submission)));
  }
}

class _EditSubmissionPage extends StatefulWidget {
  final UserSubmission submission;

  _EditSubmissionPage(this.submission);

  @override
  createState() => _EditSubmissionPageState();
}

class _EditSubmissionPageState extends State<_EditSubmissionPage> {
  final _stationTextController = TextEditingController();
  final _milesTextController = TextEditingController();
  final _costTextController = TextEditingController();
  final _gallonsTextController = TextEditingController();

  _save() async {
    Map<String, dynamic> result = {};

    String station = _stationTextController.text;
    double miles = double.tryParse(_milesTextController.text);
    double cost = double.tryParse(_costTextController.text);
    double gal = double.tryParse(_gallonsTextController.text);

    if (station != widget.submission.station) {
      result.putIfAbsent('station', () => station);
    }

    if (miles != widget.submission.miles) {
      result.putIfAbsent('miles', () => miles);
    }

    if (cost != widget.submission.cost) {
      result.putIfAbsent('cost', () => cost);
    }

    if (gal != widget.submission.gallons) {
      result.putIfAbsent('gallons', () => gal);
    }

    await updateUserSubmission(documentID: widget.submission.documentID, map: result);

    Navigator.pop(context);
  }

  @override
  initState() {
    super.initState();

    _stationTextController.text = widget.submission.station;
    _milesTextController.text = widget.submission.miles.toString();
    _costTextController.text = widget.submission.cost.toString();
    _gallonsTextController.text = widget.submission.gallons.toString();
  }

  @override
  build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.submission.date.month}/${widget.submission.date.day}/${widget.submission.date.year}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              labelText: 'Station',
              hintText: 'Enter the station',
              icon: Icon(Icons.local_gas_station),
            ),
            textInputAction: TextInputAction.done,
            controller: _stationTextController,
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Miles',
              hintText: 'Enter the total gallons',
              suffixText: 'mi.',
              icon: Icon(Icons.time_to_leave),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textInputAction: TextInputAction.done,
            controller: _milesTextController,
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Total Cost',
              hintText: 'Enter the total cost',
              prefixText: '\$',
              icon: Icon(Icons.attach_money),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textInputAction: TextInputAction.done,
            controller: _costTextController,
          ),
          TextField(
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
            controller: _gallonsTextController,
          ),
          MaterialButton(
            child: Text('Delete'),
            color: Colors.red,
            onPressed: () {
              deleteUserSubmission(widget.submission.documentID);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
