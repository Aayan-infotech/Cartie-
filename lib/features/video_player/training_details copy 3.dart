// import 'package:cartie/core/models/course_model.dart' as course;
// import 'package:cartie/core/theme/app_theme.dart';
// import 'package:cartie/core/theme/theme_provider.dart';
// import 'package:cartie/core/utills/branded_primary_button.dart';
// import 'package:cartie/features/providers/course_provider.dart';
// import 'package:cartie/features/video_player/assisment_screen.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';

// class TrainingDetailScreen extends StatefulWidget {
//   const TrainingDetailScreen({super.key});

//   @override
//   State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
// }

// class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
//   VideoPlayerController? _videoController;
//   ChewieController? _chewieController;
//   int _currentVideoIndex = 0;
//   bool _isInitialized = false;
//   int _selectedTabIndex = 1;
//   late CourseProvider _courseProvider;

//   List<String> _videoUrls = [];
//   List<Section> _uiSections = [];
//   List<course.Video> _allVideos = [];

//   @override
//   void initState() {
//     super.initState();
//     _courseProvider = Provider.of<CourseProvider>(context, listen: false);
//     _courseProvider.addListener(_onProviderUpdate);

//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       _courseProvider.fetchCourseSections();
//     });
//   }

//   void _onProviderUpdate() {
//     if (!mounted) return;

//     if (_courseProvider.sections != null) {
//       final course = _courseProvider.sections!;
//       final newVideoUrls = course.sections
//           .expand((section) => section.videos.map((v) => v.url))
//           .toList();
//       _allVideos = course.sections.expand((s) => s.videos).toList();
//       final newUISections = _convertToUISections(course);

//       if (mounted) {
//         setState(() {
//           _videoUrls = newVideoUrls;
//           _uiSections = newUISections;
//         });
//       }

//       if (newVideoUrls.isNotEmpty) {
//         if (!_isInitialized || _currentVideoIndex >= newVideoUrls.length) {
//           _currentVideoIndex = 0;
//           _initializeVideo(_currentVideoIndex);
//         }
//       }
//     }
//   }

//   List<Section> _convertToUISections(course.Course course) {
//     List<Section> uiSections = [];
//     int lessonIndex = 1;
//     int videoIndexCounter = 0;

//     for (var section in course.sections) {
//       List<Lesson> lessons = [];
//       for (var video in section.videos) {
//         lessons.add(Lesson(
//           index: lessonIndex++,
//           title: video.title,
//           time: video.durationTime,
//           videoIndex: videoIndexCounter++,
//         ));
//       }
//       uiSections.add(Section(
//         title: 'Section ${section.sectionNumber} - ${section.title}',
//         duration: section.durationTime,
//         lessons: lessons,
//         sectionId: section.id,
//       ));
//     }
//     return uiSections;
//   }

//   Future<void> _initializeVideo(int index) async {
//     if (index >= _videoUrls.length) return;

//     final currentVideo = _allVideos[index];
//     final newController =
//         VideoPlayerController.networkUrl(Uri.parse(_videoUrls[index]));
//     await newController.initialize();

//     // Check for saved progress
//     final savedPosition = currentVideo
//         .watchedDuration; //_courseProvider.getVideoProgress(currentVideo.id);
//     if (savedPosition != null) {
//       await newController.seekTo(Duration(seconds: savedPosition));
//     }

//     // Add listener to save progress on pause
//     // newController.addListener(() async {
//     //   if (!newController.value.isPlaying &&
//     //       newController.value.position < newController.value.duration) {
//     //     await _courseProvider.updateVideoProgress(
//     //       locationId: _courseProvider.sections!.location,
//     //       sectionId: currentVideo.sectionId,
//     //       videoId: currentVideo.id,
//     //       watchedDuration: newController.value.position.inSeconds.toString(),
//     //     );
//     //   }
//     // });
//     newController.addListener(() async {
//       final position = newController.value.position;
//       final duration = newController.value.duration;

//       if (position >= duration) {
//         await _courseProvider.markVideoCompleted(
//           locationId: _courseProvider.sections!.location,
//           sectionId: currentVideo.sectionId,
//           videoId: currentVideo.id,
//         );
//       } else if (!newController.value.isPlaying) {
//         await _courseProvider.updateVideoProgress(
//           locationId: _courseProvider.sections!.location,
//           sectionId: currentVideo.sectionId,
//           videoId: currentVideo.id,
//           watchedDuration: position.inSeconds.toString(),
//         );
//       }
//     });

//     if (mounted) {
//       _videoController?.dispose();
//       _chewieController?.dispose();

//       setState(() {
//         _videoController = newController;
//         _isInitialized = true;

//         _chewieController = ChewieController(
//           videoPlayerController: _videoController!,
//           autoPlay: true,
//           looping: false,
//           allowFullScreen: true,
//           showControls: true,
//           materialProgressColors: ChewieProgressColors(
//             playedColor: Theme.of(context).colorScheme.primary,
//             handleColor: Colors.blue,
//             backgroundColor: Colors.grey,
//             bufferedColor: Colors.lightGreen,
//           ),
//           placeholder: Container(color: Colors.grey),
//           customControls: const CupertinoControls(
//             backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
//             iconColor: Colors.white,
//           ),
//           errorBuilder: (context, errorMessage) {
//             return Center(
//               child: Text(
//                 errorMessage,
//                 style: const TextStyle(color: Colors.white),
//               ),
//             );
//           },
//         );
//       });
//     } else {
//       newController.dispose();
//     }
//   }

//   void _changeVideo(int index) async {
//     if (index != _currentVideoIndex && index < _videoUrls.length) {
//       // Save current video progress
//       if (_videoController != null && _videoController!.value.isInitialized) {
//         final currentPosition = _videoController!.value.position;
//         final currentVideo = _allVideos[_currentVideoIndex];
//         if (currentPosition < _videoController!.value.duration) {
//           await _courseProvider.updateVideoProgress(
//               locationId: _courseProvider.sections!.id,
//               sectionId: currentVideo.sectionId,
//               videoId: currentVideo.id,
//               watchedDuration: currentPosition.inSeconds.toString());
//         }
//       }

//       _currentVideoIndex = index;
//       await _chewieController?.pause();
//       await _videoController?.dispose();
//       if (mounted) {
//         setState(() => _isInitialized = false);
//       }
//       await _initializeVideo(index);
//     }
//   }

//   @override
//   void dispose() {
//     _courseProvider.removeListener(_onProviderUpdate);
//     // Save progress when screen is disposed
//     if (_videoController != null && _videoController!.value.isInitialized) {
//       final currentPosition = _videoController!.value.position;
//       final currentVideo = _allVideos[_currentVideoIndex];
//       if (currentPosition < _videoController!.value.duration) {
//         _courseProvider.updateVideoProgress(
//           locationId: _courseProvider.sections!.location,
//           sectionId: currentVideo.sectionId,
//           videoId: currentVideo.id,
//           watchedDuration: currentPosition.inSeconds.toString(),
//         );
//       }
//     }
//     _videoController?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final textTheme = theme.textTheme;

//     return Scaffold(
//       backgroundColor: colorScheme.background,
//       appBar: AppBar(
//         backgroundColor: colorScheme.background,
//         foregroundColor: colorScheme.onBackground,
//         scrolledUnderElevation: 0,
//         // forceMaterialTransparency: true,
//         title: Text(
//           'Training',
//           style: GoogleFonts.montserrat(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: colorScheme.onBackground,
//           ),
//         ),
//       ),
//       body: Consumer<CourseProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (_videoUrls.isEmpty) {
//             // Fixed condition to check for empty list
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: colorScheme.surfaceVariant.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.video_library_outlined,
//                         size: 64,
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'No Courses Available',
//                       style: GoogleFonts.montserrat(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                         color: colorScheme.onBackground,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       "We couldn't find any courses for your location.\nCheck back later or contact support.",
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.montserrat(
//                         fontSize: 16,
//                         color: colorScheme.onSurfaceVariant,
//                         height: 1.5,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     // OutlinedButton.icon(
//                     //   icon: Icon(Icons.contact_support,
//                     //       size: 18,
//                     //       color: colorScheme.primary),
//                     //   label: Text('Contact Support',
//                     //       style: TextStyle(color: colorScheme.primary)),
//                     //   onPressed: () => _contactSupport(),
//                     //   style: OutlinedButton.styleFrom(
//                     //     padding: const EdgeInsets.symmetric(
//                     //         horizontal: 24, vertical: 12),
//                     //     side: BorderSide(color: colorScheme.primary),
//                     //     shape: RoundedRectangleBorder(
//                     //       borderRadius: BorderRadius.circular(8),
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final totalVideos = _videoUrls.length;
//           final currentVideo = _currentVideoIndex < _allVideos.length
//               ? _allVideos[_currentVideoIndex]
//               : null;

//           return Column(children: [
//             _isInitialized && _videoUrls.isNotEmpty && _chewieController != null
//                 ? AspectRatio(
//                     aspectRatio: 16 / 9,
//                     child: Chewie(controller: _chewieController!),
//                   )
//                 : AspectRatio(
//                     aspectRatio: 16 / 9,
//                     child: Center(
//                       child: _videoUrls.isEmpty
//                           ? const CircularProgressIndicator()
//                           : const Text('Loading...'),
//                     ),
//                   ),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: colorScheme.surface,
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: [
//                     if (currentVideo != null)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * 0.7,
//                                 child: Text(currentVideo.title,
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 3,
//                                     style: GoogleFonts.montserrat(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: colorScheme.onSurface)),
//                               ),
//                               const Spacer(),
//                               Text(currentVideo.durationTime,
//                                   style: TextStyle(
//                                       color: colorScheme.onSurfaceVariant)),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                         ],
//                       ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.video_collection,
//                             color: colorScheme.onSurfaceVariant, size: 16),
//                         const SizedBox(width: 4),
//                         Text('$totalVideos Videos',
//                             style:
//                                 TextStyle(color: colorScheme.onSurfaceVariant)),
//                         const SizedBox(width: 12),
//                         // Icon(Icons.access_time,
//                         //     color: colorScheme.onSurfaceVariant, size: 16),
//                         const SizedBox(width: 4),
//                         // Text('42 Hours',
//                         //     style:
//                         //         TextStyle(color: colorScheme.onSurfaceVariant)),
//                         const Spacer(),
//                         // Text('\$28',
//                         //     style: TextStyle(
//                         //         color: colorScheme.primary,
//                         //         fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         _buildTabButton(0, 'About', colorScheme),
//                         const SizedBox(width: 10),
//                         _buildTabButton(1, 'Curriculum', colorScheme),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     _selectedTabIndex == 0
//                         ? _buildAboutTab(textTheme, colorScheme,
//                             "Learn creative problem-solving techniques to tackle real-world challenges with confidence and innovation.")
//                         : _buildCurriculumTab(colorScheme),
//                     const SizedBox(height: 20),
//                     if (_selectedTabIndex != 0)
//                       BrandedPrimaryButton(
//                         isEnabled: true,
//                         name: "Take Assessment",
//                         onPressed: () async {
//                           //  provider.fetchQuiz(locationId: currentV, sectionId: sectionId, sectionNumber: sectionNumber)
//                           // await Navigator.of(context).push(
//                           //   MaterialPageRoute(
//                           //     builder: (context) => AssessmentScreen(),
//                           //   ),
//                           // );
//                         },
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ]);
//         },
//       ),
//     );
//   }

//   Widget _buildTabButton(int index, String label, ColorScheme colorScheme) {
//     final isSelected = _selectedTabIndex == index;
//     final isLightTheme = Theme.of(context).brightness == Brightness.light;
//     print(isLightTheme);
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedTabIndex = index),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: isSelected ? colorScheme.primary : colorScheme.secondary,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Text(
//             label,
//             style: GoogleFonts.montserrat(
//               color: isLightTheme ? Colors.white : colorScheme.onPrimary,
//               //: colorScheme.onSecondary,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAboutTab(
//       TextTheme textTheme, ColorScheme colorScheme, String description) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Course Description',
//             style:
//                 textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
//         const SizedBox(height: 12),
//         Text(description,
//             style: textTheme.bodyMedium
//                 ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5)),
//       ],
//     );
//   }

//   Widget _buildCurriculumTab(ColorScheme colorScheme) {
//     final originalSections = _courseProvider.sections?.sections ?? [];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: _uiSections.map((uiSection) {
//         final originalSectionIndex = originalSections.indexWhere(
//           (s) => uiSection.title.contains('Section ${s.sectionNumber}'),
//         );
//         // final originalSection = originalSectionIndex != -1
//         //     ? originalSections[originalSectionIndex]
//         //     : null;
//         final originalSection = _courseProvider.sections!.sections
//             .firstWhere((s) => s.id == uiSection.sectionId);
//         final hasQuiz =
//             _courseProvider.getQuizForSection(uiSection.sectionId) != null;
//         final isQuizCompleted =
//             _courseProvider.isQuizCompleted(uiSection.sectionId);

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(uiSection.title,
//                 style: GoogleFonts.montserrat(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: colorScheme.onSurface)),
//             const SizedBox(height: 6),
//             Text('Duration: ${uiSection.duration}',
//                 style: TextStyle(
//                     color: colorScheme.onSurfaceVariant, fontSize: 13)),
//             const SizedBox(height: 8),
//             ...uiSection.lessons.map((lesson) {
//               final video = _allVideos[lesson.videoIndex];
//               final section = originalSections.firstWhere(
//                   (s) => s.id == video.sectionId,
//                   orElse: () => course.Section(
//                       durationTime: '',
//                       id: '',
//                       isSectionCompleted: false,
//                       sectionNumber: 1,
//                       title: '',
//                       videos: []));

//               // Check previous sections
//               final sectionIndex = originalSections.indexOf(section);
//               bool previousSectionsCompleted = true;
//               for (int i = 0; i < sectionIndex; i++) {
//                 if (!originalSections[i].isSectionCompleted) {
//                   previousSectionsCompleted = false;
//                   break;
//                 }
//               }

//               // Check previous videos in current section
//               final videoIndexInSection = section.videos.indexOf(video);
//               bool previousVideosCompleted = true;
//               for (int i = 0; i < videoIndexInSection; i++) {
//                 if (!section.videos[i].isCompleted) {
//                   previousVideosCompleted = false;
//                   break;
//                 }
//               }

//               final isEnabled =
//                   previousSectionsCompleted && previousVideosCompleted;

//               return ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 onTap: isEnabled ? () => _changeVideo(lesson.videoIndex) : null,
//                 leading: isEnabled
//                     ? Icon(
//                         _currentVideoIndex == lesson.videoIndex
//                             ? Icons.pause
//                             : Icons.play_circle_fill,
//                         color: _currentVideoIndex == lesson.videoIndex
//                             ? colorScheme.primary
//                             : colorScheme.onSurfaceVariant,
//                         size: 28,
//                       )
//                     : Icon(Icons.lock, color: Colors.grey, size: 28),
//                 title: Text(
//                   '${lesson.index}. ${lesson.title}',
//                   style: GoogleFonts.montserrat(
//                     color: isEnabled
//                         ? (_currentVideoIndex == lesson.videoIndex
//                             ? colorScheme.primary
//                             : colorScheme.onSurface)
//                         : Colors.grey,
//                     fontWeight: _currentVideoIndex == lesson.videoIndex
//                         ? FontWeight.w600
//                         : FontWeight.normal,
//                   ),
//                 ),
//                 subtitle: Text(
//                   lesson.time,
//                   style: GoogleFonts.montserrat(
//                     color: isEnabled
//                         ? (_currentVideoIndex == lesson.videoIndex
//                             ? colorScheme.primary
//                             : colorScheme.onSurfaceVariant)
//                         : Colors.grey,
//                   ),
//                 ),
//                 trailing: video.isCompleted
//                     ? Icon(Icons.check_circle,
//                         color: colorScheme.primary, size: 20)
//                     : null,
//               );
//             }).toList(),
//             if (originalSection.isSectionCompleted &&
//                 hasQuiz &&
//                 !isQuizCompleted)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0),
//                 child: BrandedPrimaryButton(
//                   isEnabled: true,
//                   name: "Take Assessment",
//                   onPressed: () async {
//                     final quiz =
//                         _courseProvider.getQuizForSection(uiSection.sectionId);
//                     if (quiz != null) {
//                       final passed = await Navigator.push<bool>(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AssessmentScreen(
//                             quiz: quiz,
//                             sectionId: uiSection.sectionId,
//                           ),
//                         ),
//                       );

//                       if (passed == true) {
//                         _courseProvider.markQuizCompleted(uiSection.sectionId);
//                       }
//                     }
//                   },
//                 ),
//               ),
//             const SizedBox(height: 16),
//           ],
//         );
//       }).toList(),
//     );
//   }
// }

// class Section {
//   final String title;
//   final String duration;
//   final List<Lesson> lessons;
//   final String sectionId;

//   Section({
//     required this.title,
//     required this.duration,
//     required this.lessons,
//     required this.sectionId,
//   });
// }

// class Lesson {
//   final int index;
//   final String title;
//   final String time;
//   final int videoIndex;

//   Lesson({
//     required this.index,
//     required this.title,
//     required this.time,
//     required this.videoIndex,
//   });
// }
