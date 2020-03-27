import 'package:editors/editors.dart' hide TitlePlacement;
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:titles/titles.dart';

void main() => runApp(_App());

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(title: 'Titles Samples', home: TitlesExamplePage());
}

class TitlesExamplePage extends StatefulWidget {
  @override
  _TitlesExamplePageState createState() => _TitlesExamplePageState();
}

class _TitlesExamplePageState extends State<TitlesExamplePage> {
  static const faker = const Faker();
  final placementEditor = EnumEditor<TitlePlacement>(
      title: 'Title Placement',
      value: TitlePlacement.label,
      getList: () => TitlePlacement.values
          .where((e) => e != TitlePlacement.placeholder)
          .toList());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Titles Samples')),
        body: TitlesContext(
          parameters: TitleParameters(
              placement: placementEditor.value,
              style: TextStyle(color: Theme.of(context).disabledColor)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                    width: 200,
                    child: EditorsContext(
                        onValueChanged: (_, __) {
                          setState(() {});
                          return true;
                        },
                        child: placementEditor.build())),
              ),
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 450,
                        child: Row(
                          children: [
                            const Icon(Icons.person,
                                size: 64, color: Colors.grey),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(faker.person.firstName(),
                                                overflow: TextOverflow.ellipsis)
                                            .buildTitled('First Name'),
                                      ),
                                      Expanded(
                                        child: Text(faker.person.lastName(),
                                                overflow: TextOverflow.ellipsis)
                                            .buildTitled('Last Name'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(faker.job.title(),
                                                overflow: TextOverflow.ellipsis)
                                            .buildTitled('Title'),
                                      ),
                                      Expanded(
                                        child: Text(
                                                faker.internet.ipv4Address(),
                                                overflow: TextOverflow.ellipsis)
                                            .buildTitled('IP'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
