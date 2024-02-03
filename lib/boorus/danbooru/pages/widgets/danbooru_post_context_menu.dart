// Flutter imports:
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';

class DanbooruPostContextMenu extends ConsumerWidget {
  const DanbooruPostContextMenu({
    super.key,
    required this.post,
    this.onMultiSelect,
    required this.hasAccount,
  });

  final DanbooruPost post;
  final void Function()? onMultiSelect;
  final bool hasAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);

    final noteRepo = ref.watch(danbooruNoteRepoProvider(booruConfig));

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'post.action.preview'.tr(),
            onPressed: () => goToImagePreviewPage(ref, context, post),
          ),
          if (post.hasComment)
            ContextMenuButtonConfig(
              'post.action.view_comments'.tr(),
              onPressed: () => goToCommentPage(context, ref, post.id),
            ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () {
              showDownloadStartToast(context);
              download(post);
            },
          ),
          if (!isBookmarked)
            ContextMenuButtonConfig(
              'post.detail.add_to_bookmark'.tr(),
              onPressed: () => ref.bookmarks
                ..addBookmarkWithToast(
                  booruConfig.booruId,
                  booruConfig.url,
                  post,
                ),
            )
          else
            ContextMenuButtonConfig(
              'post.detail.remove_from_bookmark'.tr(),
              onPressed: () => ref.bookmarks
                ..removeBookmarkWithToast(
                  bookmarkState.getBookmark(post, booruConfig.booruType)!,
                ),
            ),
          if (hasAccount)
            ContextMenuButtonConfig(
              'post.action.add_to_favorite_group'.tr(),
              onPressed: () {
                goToAddToFavoriteGroupSelectionPage(
                  context,
                  [post],
                );
              },
            ),
          if (!booruConfig.hasStrictSFW)
            ContextMenuButtonConfig(
              'Open in browser',
              onPressed: () =>
                  launchExternalUrlString(post.getLink(booruConfig.url)),
            ),
          ContextMenuButtonConfig(
            'View tags',
            onPressed: () {
              goToDanbooruShowTaglistPage(ref, context, post.extractTags());
            },
          ),
          ContextMenuButtonConfig(
            'View tag history',
            onPressed: () => goToPostVersionPage(context, post),
          ),
          if (hasAccount)
            ContextMenuButtonConfig(
              'Edit',
              onPressed: () {
                goToTagEditPage(
                  context,
                  post: post,
                );
              },
            ),
          if (onMultiSelect != null)
            ContextMenuButtonConfig(
              'post.action.select'.tr(),
              onPressed: () {
                onMultiSelect?.call();
              },
            ),
          ContextMenuButtonConfig(
            'Add note',
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => AnnotateImagePage(
                    imageUrl: post.sampleImageUrl,
                    originalImageWidth: post.width.toDouble(),
                    originalImageHeight: post.height.toDouble(),
                    aspectRatio: post.aspectRatio!,
                    onSendData: (squareData) {
                      noteRepo.createNote(
                        postId: post.id,
                        x: squareData[0]['x'],
                        y: squareData[0]['y'],
                        width: squareData[0]['width'],
                        height: squareData[0]['height'],
                        body: squareData[0]['body'],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class FavoriteGroupsPostContextMenu extends ConsumerWidget {
  const FavoriteGroupsPostContextMenu({
    super.key,
    required this.post,
    required this.onMultiSelect,
    required this.onRemoveFromFavGroup,
  });

  final Post post;
  final void Function()? onMultiSelect;
  final void Function()? onRemoveFromFavGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'Preview',
            onPressed: () => goToImagePreviewPage(ref, context, post),
          ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () {
              showDownloadStartToast(context);
              download(post);
            },
          ),
          if (config.hasLoginDetails())
            ContextMenuButtonConfig(
              'Remove from favorite group',
              onPressed: () {
                onRemoveFromFavGroup?.call();
              },
            ),
          ContextMenuButtonConfig(
            'Select',
            onPressed: () {
              onMultiSelect?.call();
            },
          ),
        ],
      ),
    );
  }
}

class AnnotateImagePage extends StatefulWidget {
  const AnnotateImagePage({
    super.key,
    required this.imageUrl,
    required this.aspectRatio,
    required this.originalImageWidth,
    required this.originalImageHeight,
    this.onSendData,
  });

  final String imageUrl;
  final double aspectRatio;
  final double originalImageWidth;
  final double originalImageHeight;
  final void Function(List<Map<String, dynamic>> squareData)? onSendData;

  @override
  _AnnotateImagePageState createState() => _AnnotateImagePageState();
}

class _AnnotateImagePageState extends State<AnnotateImagePage> {
  List<Square> squares = [];
  List<Square> squaresDraw = [];
  List<Map<String, dynamic>> squareData = [];
  Offset? _startPosition;
  Offset? _currentPosition;
  final _imageKey = GlobalKey();
  var _edit = false;

  final transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    transformationController.addListener(() {
      final clampedMatrix = Matrix4.diagonal3Values(
        transformationController.value.right.x,
        transformationController.value.up.y,
        transformationController.value.forward.z,
      );

      // widget.onZoomUpdated?.call(!clampedMatrix.isIdentity());
    });
  }

  @override
  void dispose() {
    super.dispose();
    transformationController.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    RenderBox box = _imageKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.globalToLocal(details.globalPosition);

    setState(() {
      _startPosition = position;
      _currentPosition = position;
      squaresDraw.add(Square(details.localPosition, details.localPosition));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox box = _imageKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.globalToLocal(details.globalPosition);

    setState(() {
      _currentPosition = position;
      if (squares.isEmpty) {
        squares.add(Square(_startPosition!, _currentPosition!));
      } else {
        squares[0] = Square(_startPosition!, _currentPosition!);
      }

      squaresDraw[0] = Square(squaresDraw[0].start, details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_startPosition != null && _currentPosition != null) {
      setState(() {
        List<Map<String, dynamic>> squareData = calcSquareData(squares);

        // Sending data to the server
        print(squareData);
        setState(() {
          this.squareData = squareData;
        });
        _currentPosition = null;
        _startPosition = null;

        squaresDraw.clear();
      });
    }
  }

  List<Map<String, dynamic>> calcSquareData(List<Square> squares) {
    // Assuming you have added fields for original image dimensions in the widget
    Size imageSize =
        Size(widget.originalImageWidth, widget.originalImageHeight);

    // Getting the size of the Image widget
    RenderBox box = _imageKey.currentContext!.findRenderObject() as RenderBox;
    Size widgetSize = box.size;

    // Calculating scale factors
    double scaleX = imageSize.width / widgetSize.width;
    double scaleY = imageSize.height / widgetSize.height;

    // Transforming coordinates
    List<Map<String, dynamic>> squareData = squares.map((square) {
      double startX = square.start.dx * scaleX;
      double startY = square.start.dy * scaleY;
      double endX = square.end.dx * scaleX;
      double endY = square.end.dy * scaleY;

      return {
        'x': startX.toInt(),
        'y': startY.toInt(),
        'width': (endX - startX).toInt(),
        'height': (endY - startY).toInt(),
        'body': 'test',
      };
    }).toList();

    return squareData;
  }

  void sendDataToServer() {
    widget.onSendData?.call(squareData);
  }

  @override
  Widget build(BuildContext context) {
    final image = InteractiveImage(
      useOriginalSize: false,
      transformationController: transformationController,
      image: AspectRatio(
        aspectRatio: widget.aspectRatio!,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              ExtendedImage.network(
                key: _imageKey,
                widget.imageUrl,
                width:
                    constraints.maxWidth.isFinite ? constraints.maxWidth : null,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : null,
                fit: BoxFit.contain,
              ),
              ...squareData
                  .map(
                (e) => Note(
                  coordinate: NoteCoordinate(
                    x: e['x'].toDouble(),
                    y: e['y'].toDouble(),
                    height: e['height'].toDouble(),
                    width: e['width'].toDouble(),
                  ),
                  content: e['body'],
                ),
              )
                  .map((e) {
                final widthConstraint = constraints.maxWidth;
                final heightConstraint = constraints.maxHeight;
                final widthPercent =
                    widthConstraint / widget.originalImageWidth;
                final heightPercent =
                    heightConstraint / widget.originalImageHeight;

                return e.copyWith(
                  coordinate:
                      e.coordinate.withPercent(widthPercent, heightPercent),
                );
              }).map((e) => PostNote(
                        coordinate: e.coordinate,
                        content: e.content,
                      ))
            ],
          ),
        ),
      ),
    );

    final stack = Stack(
      children: [
        if (!_edit) image else IgnorePointer(child: image),
        if (_edit)
          CustomPaint(
            painter: SquarePainter(squaresDraw),
            child: Container(),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Annotate Image'),
        actions: [
          if (_edit)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _edit = false;
                });
              },
            )
          else
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _edit = true;
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: sendDataToServer,
          ),
        ],
      ),
      body: _edit
          ? GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: stack,
            )
          : stack,
    );
  }
}

class Square {
  Offset start;
  Offset end;

  Square(this.start, this.end);
}

class SquarePainter extends CustomPainter {
  final List<Square> squares;

  SquarePainter(this.squares);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (var square in squares) {
      canvas.drawRect(
        Rect.fromPoints(square.start, square.end),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SquarePainter oldDelegate) => true;
}
