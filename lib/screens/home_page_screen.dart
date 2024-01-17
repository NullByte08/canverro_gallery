import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends ConsumerState<HomePageScreen> {
  static const _pageSize = 4;

  final PagingController<int, String> _pagingController = PagingController(firstPageKey: 0);

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
        "https://picsum.photos/${100 * (1 + random.nextInt(10))}/${100 * (1 + random.nextInt(10))}",
        "https://picsum.photos/${100 * (1 + random.nextInt(10))}/${100 * (1 + random.nextInt(10))}",
        "https://picsum.photos/${100 * (1 + random.nextInt(10))}/${100 * (1 + random.nextInt(10))}",
        "https://picsum.photos/${100 * (1 + random.nextInt(10))}/${100 * (1 + random.nextInt(10))}",
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
                  Expanded(
                    child: PagedMasonryGridView<int, String>.count(
                      padding: const EdgeInsets.all(0),
                      physics: const PageScrollPhysics(),
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, item, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: CachedNetworkImage(
                              imageUrl: item,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                      crossAxisCount: 2,
                    ),
                  ),
                ],
              ),

              //Header
              Container(
                height: screenHeight * 0.07,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                          const Icon(
                            Icons.grid_view_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          const Icon(
                            Icons.list_alt,
                            color: Colors.white,
                            size: 30,
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
