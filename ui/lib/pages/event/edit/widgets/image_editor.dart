import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A widget for editing a list of event images.
///
/// Displays existing images from URLs and newly picked images from files.
/// Allows removing existing images and adding new ones.
class EventImageEditor extends StatefulWidget {
  final List<String> initialImageUrls;
  final Function(List<String> remainingUrls, List<File> newFiles) onImagesChanged;

  const EventImageEditor({
    super.key,
    required this.initialImageUrls,
    required this.onImagesChanged,
  });

  @override
  State<EventImageEditor> createState() => _EventImageEditorState();
}

class _EventImageEditorState extends State<EventImageEditor> {
  late List<String> _retainedImageUrls;
  final List<File> _newImages = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _retainedImageUrls = List.from(widget.initialImageUrls);
  }

  void _notifyParent() {
    widget.onImagesChanged(_retainedImageUrls, _newImages);
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.map((f) => File(f.path)));
      });
      _notifyParent();
    }
  }

  void _removeUrl(int index) {
    setState(() {
      _retainedImageUrls.removeAt(index);
    });
    _notifyParent();
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ảnh sự kiện", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _retainedImageUrls.length + _newImages.length + 1,
          itemBuilder: (context, index) {
            // The last item is the 'Add' button
            if (index == _retainedImageUrls.length + _newImages.length) {
              return _buildAddButton();
            }

            // Display existing images from URLs
            if (index < _retainedImageUrls.length) {
              final imageUrl = _retainedImageUrls[index];
              return _buildImageItem(Image.network(imageUrl, fit: BoxFit.cover), () => _removeUrl(index));
            }

            // Display new images from Files
            final newImageIndex = index - _retainedImageUrls.length;
            final imageFile = _newImages[newImageIndex];
            return _buildImageItem(Image.file(imageFile, fit: BoxFit.cover), () => _removeNewImage(newImageIndex));
          },
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 28),
              SizedBox(height: 4),
              Text("Thêm ảnh", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(Image image, VoidCallback onDelete) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
