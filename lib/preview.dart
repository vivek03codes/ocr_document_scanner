import 'package:flutter/material.dart';

class Previews extends StatefulWidget {
  final List<String> text;
  const Previews(this.text, {super.key});

  @override
  State<Previews> createState() => _PreviewsState();
}

class _PreviewsState extends State<Previews> {
  List<TextEditingController> controllers = [];
  List<String> updatedText = [];

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the data
    for (String value in widget.text) {
      controllers.add(TextEditingController(text: value));
    }
  }

  bool checkList(List<String> list) {
    if (list.length > 5) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    // Dispose of the controllers when done
    for (TextEditingController controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: GestureDetector(
            onTap: () => {Navigator.of(context).pop()},
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: const Text(
            "Preview",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: checkList(widget.text)
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: widget.text.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: controllers[index],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const Center(
                child: Text(
                  "No preview available!",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ));
  }
}
