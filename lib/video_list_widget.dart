import 'package:flutter/material.dart';
import 'package:goodchannel/video_model.dart';

class VideoListWidget extends StatelessWidget {
  final List<VideoItem> videos;
  final Function(String) onVideoSelected;
  final VoidCallback onPickLocalVideo;

  const VideoListWidget({
    super.key,
    required this.videos,
    required this.onVideoSelected,
    required this.onPickLocalVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.video_library,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sample Videos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Video list
          ...videos.map((video) => _buildVideoItem(video)),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Local video picker
          _buildLocalVideoButton(),
        ],
      ),
    );
  }

  Widget _buildVideoItem(VideoItem video) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: video.isHttp 
                ? Colors.orange.withOpacity(0.3)
                : Colors.blue.withOpacity(0.3),
          ),
          color: video.isHttp 
              ? Colors.orange.withOpacity(0.05)
              : Colors.blue.withOpacity(0.05),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onVideoSelected(video.url),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Video type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getVideoTypeColor(video).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getVideoTypeIcon(video),
                      color: _getVideoTypeColor(video),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Video info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                video.url,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (video.isHttp) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                size: 14,
                                color: Colors.orange[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'HTTP Stream',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Play button
                  Icon(
                    Icons.play_circle_outline,
                    color: _getVideoTypeColor(video),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalVideoButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Colors.purple[400]!,
            Colors.purple[600]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPickLocalVideo,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Pick Local Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getVideoTypeIcon(VideoItem video) {
    switch (video.type) {
      case VideoType.local:
        return Icons.folder;
      case VideoType.stream:
        return Icons.stream;
      case VideoType.remote:
        return Icons.cloud;
    }
  }

  Color _getVideoTypeColor(VideoItem video) {
    switch (video.type) {
      case VideoType.local:
        return Colors.green;
      case VideoType.stream:
        return video.isHttp ? Colors.orange : Colors.blue;
      case VideoType.remote:
        return Colors.blue;
    }
  }
}