import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: _TabsNonScrollableDemo(),
      ),
    );
  }
}

class _TabsNonScrollableDemo extends StatefulWidget {
  @override
  __TabsNonScrollableDemoState createState() =>
  __TabsNonScrollableDemoState();
}

class __TabsNonScrollableDemoState extends State<_TabsNonScrollableDemo>
  with SingleTickerProviderStateMixin, RestorationMixin {
  late TabController _tabController;

  final RestorableInt tabIndex = RestorableInt(0);
  String _imageUrl = '';

  @override
  String get restorationId => 'tabs_non_scrollable_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'tab_index');
    _tabController.index = tabIndex.value;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 4,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        tabIndex.value = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    tabIndex.dispose();
    super.dispose();
  }

  Widget _buildTab1(BuildContext context) {
    return Container(
      color: Colors.amber.shade50,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tab 1 Boyyyy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Hello from Tab 1'),
                    content: Text('This is a dialog triggered from Tab 1.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Show Dialog'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab2() {
    return Container(
      color: Colors.lightBlue.shade50,
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Enter Image URL',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _imageUrl = value;
              });
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: _imageUrl.isEmpty
                ? Center(child: Text('Enter a URL to display an image'))
                : Image.network(
                    _imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text('Failed to load image'));
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab3(BuildContext context) {
    return Container(
      color: Colors.green.shade50,
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hello from Tab 3!'),
                backgroundColor: Colors.green.shade50,
              ),
            );
          },
          child: Text('Show Snackbar'),
        ),
      ),
    );
  }

  Widget _buildTab4() {
    return Container(
      color: Colors.purple.shade50,
      child: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            child: ListTile(
              leading: Icon(Icons.star, color: Colors.purple),
              title: Text('Item 1'),
              subtitle: Text('This is the first item in the list'),
            ),
          ),
          SizedBox(height: 8),
          Card(
            elevation: 4,
            child: ListTile(
              leading: Icon(Icons.favorite, color: Colors.purple),
              title: Text('Item 2'),
              subtitle: Text('This is the second item in the list'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // For the To do task hint: consider defining the widget and name of the tabs here
    final tabs = ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Tabs Demo',
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: [
            for (final tab in tabs) Tab(text: tab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1 content
          _buildTab1(context),
          // Tab 2 content
          _buildTab2(),
          // Tab 3 content
          _buildTab3(context),
          // Tab 4 content
          _buildTab4(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey.shade50,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              Icon(Icons.home, color: Colors.blueAccent),
              SizedBox(width: 12),
              Text(
                'Bottom App Bar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}