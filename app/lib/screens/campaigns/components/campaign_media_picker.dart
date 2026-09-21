import 'dart:io';
import 'package:flutter/material.dart';

class CampaignMediaPicker extends StatelessWidget {
  final File? highlightVideo;
  final File? projectRecordPdf;
  final List<File> galleryImages;
  final VoidCallback onPickVideo;
  final VoidCallback onPickPdf;
  final VoidCallback onPickGalleryImages;
  final Function(int) onRemoveGalleryImage;

  const CampaignMediaPicker({
    super.key,
    required this.highlightVideo,
    required this.projectRecordPdf,
    required this.galleryImages,
    required this.onPickVideo,
    required this.onPickPdf,
    required this.onPickGalleryImages,
    required this.onRemoveGalleryImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Multimedia (Optional)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),

        // Highlight Video
        ListTile(
          leading: const Icon(Icons.video_library),
          title: const Text('Highlight Video (MP4)'),
          subtitle: Text(
            highlightVideo != null
                ? highlightVideo!.path.split('\\').last.split('/').last
                : 'No video selected',
          ),
          trailing: OutlinedButton(
            onPressed: onPickVideo,
            child: const Text('Pick Video'),
          ),
        ),

        // Project Record PDF
        ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: const Text('Project Record (PDF)'),
          subtitle: Text(
            projectRecordPdf != null
                ? projectRecordPdf!.path.split('\\').last.split('/').last
                : 'No PDF selected',
          ),
          trailing: OutlinedButton(
            onPressed: onPickPdf,
            child: const Text('Pick PDF'),
          ),
        ),

        // Gallery Images
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Gallery Images'),
          subtitle: Text('${galleryImages.length} images selected'),
          trailing: OutlinedButton(
            onPressed: onPickGalleryImages,
            child: const Text('Pick Images'),
          ),
        ),
        if (galleryImages.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0, top: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          galleryImages[index],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => onRemoveGalleryImage(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
