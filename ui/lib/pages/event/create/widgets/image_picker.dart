import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class EventMultiImagePicker extends StatefulWidget {
  final Function(List<File>) onImagesSelected;

  const EventMultiImagePicker({super.key, required this.onImagesSelected});

  @override
  State<EventMultiImagePicker> createState() => _EventMultiImagePickerState();
}

class _EventMultiImagePickerState extends State<EventMultiImagePicker> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];
  static const int _maxImages = 8;
  static const int _maxFileSizeMB = 5;

  /// Mở sheet chọn nguồn ảnh
  Future<void> _showPickOptionSheet() async {
    if (_images.length >= _maxImages) {
      _showSnack("⚠️ Tối đa $_maxImages ảnh");
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Chọn từ thư viện"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Chụp ảnh mới"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              if (_images.isNotEmpty)
                ListTile(
                  leading:
                  const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text(
                    "Xóa tất cả ảnh",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _images.clear());
                    widget.onImagesSelected(_images);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Chọn nhiều ảnh từ thư viện
  Future<void> _pickFromGallery() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isEmpty) return;

      for (final picked in pickedFiles) {
        final file = File(picked.path);

        if (!_isValidImage(file)) continue;

        if (_images.length < _maxImages) {
          _images.add(file);
        } else {
          _showSnack("⚠️ Chỉ chọn tối đa $_maxImages ảnh");
          break;
        }
      }

      setState(() {});
      widget.onImagesSelected(_images);
    } catch (e) {
      _showSnack("❌ Lỗi khi chọn ảnh: $e");
    }
  }

  /// Chụp ảnh mới bằng camera
  Future<void> _pickFromCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (picked == null) return;

      final file = File(picked.path);
      if (!_isValidImage(file)) return;

      if (_images.length < _maxImages) {
        setState(() => _images.add(file));
        widget.onImagesSelected(_images);
      } else {
        _showSnack("⚠️ Tối đa $_maxImages ảnh");
      }
    } catch (e) {
      _showSnack("❌ Lỗi khi chụp ảnh: $e");
    }
  }

  /// Kiểm tra định dạng và dung lượng
  bool _isValidImage(File file) {
    final ext = path.extension(file.path).toLowerCase();
    final validExts = [".jpg", ".jpeg", ".png", ".webp"];

    if (!validExts.contains(ext)) {
      _showSnack("⚠️ Chỉ chấp nhận ảnh JPG, PNG, hoặc WEBP");
      return false;
    }

    final sizeMB = file.lengthSync() / (1024 * 1024);
    if (sizeMB > _maxFileSizeMB) {
      _showSnack("⚠️ Ảnh ${path.basename(file.path)} vượt quá 5MB");
      return false;
    }

    return true;
  }

  /// Hiển thị snackbar
  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Hiển thị thông tin ảnh
  String _fileInfo(File file) {
    final sizeKB = (file.lengthSync() / 1024).toStringAsFixed(1);
    final modified =
    DateFormat("dd/MM/yyyy HH:mm").format(file.lastModifiedSync());
    return "${path.basename(file.path)} • $sizeKB KB • $modified";
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showPickOptionSheet,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(12),
            child: _images.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 40, color: color.primary),
                  const SizedBox(height: 8),
                  Text("Chọn ảnh nơi tổ chức (tối đa 8 ảnh)",
                      style:
                      TextStyle(color: color.onSurfaceVariant)),
                ],
              ),
            )
                : Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _images.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, i) {
                    final img = _images[i];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(img, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() => _images.removeAt(i));
                              widget.onImagesSelected(_images);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  "Đã chọn ${_images.length}/$_maxImages ảnh",
                  style: TextStyle(
                    fontSize: 13,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_images.isNotEmpty)
          ..._images.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Text(
              _fileInfo(f),
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          )),
      ],
    );
  }
}
