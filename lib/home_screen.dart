import 'package:flutter/material.dart';
import 'package:tb_prakmobile/db_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _filteredData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addData() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Title and Description cannot be empty"),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: "Dismiss",
          onPressed: () {},
          textColor: Colors.white,
        ),
      ));
      return;
    }

    bool shouldAdd = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm"),
        content: Text("selamat anda berhasil"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Add"),
          ),
        ],
      ),
    );

    if (shouldAdd) {
      await SQLHelper.createData(_titleController.text, _descController.text);
      _refreshData();
    }
  }

  Future<void> _updateData(int id) async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Title and Description cannot be empty"),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: "Dismiss",
          onPressed: () {},
          textColor: Colors.white,
        ),
      ));
      return;
    }

    bool shouldUpdate = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm"),
        content: Text("yakin ingin mengupdate"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Update"),
          ),
        ],
      ),
    );

    if (shouldUpdate) {
      await SQLHelper.updateData(id, _titleController.text, _descController.text);
      _refreshData();
    }
  }

  void _deleteData(int id) async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("apkah anda yakin ingin menghapus"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete) {
      await SQLHelper.deleteData(id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Data Deleted",
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () async {
            await SQLHelper.createData(_titleController.text, _descController.text);
            _refreshData();
          },
          textColor: Colors.white,
        ),
      ));
      _refreshData();
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Judul",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Masukkan deskripsi",
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  }
                  if (id != null) {
                    await _updateData(id);
                  }

                  _titleController.text = "";
                  _descController.text = "";

                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Tambahkan" : "Update",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterData(String query) {
    final filtered = _allData.where((data) {
      final titleLower = data['title'].toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredData = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "Diary Memo",
          style: GoogleFonts.lato(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("About Diary Memo"),
                  content: Text(
                      "This app aplikasi untuk catatan, atau memori yang simpan di hp anda."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Search by title",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _filterData(value);
                    },
                  ),
                ),
                Expanded(
                  child: _filteredData.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada data.',
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : AnimationLimiter(
                          child: ListView.builder(
                            itemCount: _filteredData.length,
                            itemBuilder: (context, index) =>
                                AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 8,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: ListTile(
                                      title: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          _filteredData[index]['title'],
                                          style: GoogleFonts.lato(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(_filteredData[index]['desc']),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              showBottomSheet(
                                                  _filteredData[index]['id']);
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _deleteData(
                                                  _filteredData[index]['id']);
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.create),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
