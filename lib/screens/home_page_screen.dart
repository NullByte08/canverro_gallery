import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends ConsumerState<HomePageScreen> {
  static const _pageSize = 4;

  final PagingController<int, String> _pagingController = PagingController(firstPageKey: 0);

  bool _list = false;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    var random = Random();
    try {
      final newItems = [
        "https://picsum.photos/seed/${random.nextInt(999999)}/${100 * (1 + random.nextInt(10))}/${100 * (1 + random.nextInt(10))}",
        "https://picsum.photos/seed/${random.nextInt(999999)}/${100 * (1 + random.nextInt(10))}/${100 * (1 + random.nextInt(10))}",
        "https://picsum.photos/seed/${random.nextInt(999999)}/${100 * (1 + random.nextInt(10))}/${100 * (1 + random.nextInt(10))}",
        "https://picsum.photos/seed/${random.nextInt(999999)}/${100 * (1 + random.nextInt(10))}/${100 * (1 + random.nextInt(10))}",
      ];
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var screenWidth = constraints.maxWidth;
      var screenHeight = constraints.maxHeight;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              //Body
              Row(
                children: [
                  !_list
                      ? Expanded(
                          child: PagedMasonryGridView<int, String>.count(
                            padding: const EdgeInsets.all(0),
                            physics: const PageScrollPhysics(),
                            pagingController: _pagingController,
                            builderDelegate: PagedChildBuilderDelegate(
                              itemBuilder: (context, item, index) {
                                return ImageBox(
                                  imageUrl: item,
                                );
                              },
                            ),
                            crossAxisCount: 2,
                          ),
                        )
                      : Expanded(
                          child: PagedListView<int, String>(
                            padding: const EdgeInsets.all(0),
                            physics: const PageScrollPhysics(),
                            pagingController: _pagingController,
                            builderDelegate: PagedChildBuilderDelegate(
                              itemBuilder: (context, item, index) {
                                return ImageBox(
                                  imageUrl: item,
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),

              //Header
              Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Canverro Gallery",
                            style: GoogleFonts.aBeeZee(
                              color: Colors.white.withAlpha(200),
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _list = !_list;
                              });
                            },
                            child: Icon(
                              _list ? Icons.grid_view_outlined : Icons.list_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class ImageBox extends StatefulWidget {
  const ImageBox({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<ImageBox> createState() => _ImageBoxState();
}

class _ImageBoxState extends State<ImageBox> with TickerProviderStateMixin {
  bool _shrink = false;

  @override
  Widget build(BuildContext context) {
    var imageWidget = CachedNetworkImage(
      imageUrl: widget.imageUrl,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.black,
        highlightColor: Colors.grey.shade700,
        child: Container(
          width: 100,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.contain,
    );
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _shrink = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          _shrink = false;
        });
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            return DetailsBottomSheet(
              imageUrl: widget.imageUrl,
              imageWidget: imageWidget,
            );
          },
          isScrollControlled: true,
          transitionAnimationController: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
      onLongPress: () {
        setState(() {
          _shrink = true;
        });
      },
      onLongPressUp: () {
        setState(() {
          _shrink = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: _shrink ? const EdgeInsets.fromLTRB(20, 0, 20, 20) : const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: imageWidget,
      ),
    );
  }
}

class DetailsBottomSheet extends StatelessWidget {
  const DetailsBottomSheet({
    super.key,
    required this.imageUrl,
    required this.imageWidget,
  });

  final String imageUrl;
  final CachedNetworkImage imageWidget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            width: double.infinity,
            child: Opacity(
              opacity: 0.3,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 30),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: imageWidget,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "URL used:\n${imageWidget.imageUrl}",
                    style: GoogleFonts.labrada(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
