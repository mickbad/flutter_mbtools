library ripple_image_button;

/** MIT License

    Copyright (c) 2023 Neander, Cave Dwellers

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
 * */

import 'package:flutter/material.dart';

/// [RippleImageButton]
/// required parameters are [_image], [_onTap]
///
/// width, height are inference parent's size
///
/// [_image] : AssetImage('assets/example/image.png') or
/// [_image] : NetworkImage('https://example.com/image.png')
///
/// [margin], [padding] measure EdgeInsetsGeometry
/// [constraints] if you want measure max width/height or min width/height size
///   ex) BoxConstraints(maxWidth: 300)
///
/// [borderRadius] is measure shape's radius.
/// [fit] is image's auto size in container
/// [splashColor] is tab color, if you tab on [ImageRippleButton] it will be
///
/// show to ripple effect
class RippleImageButton extends StatelessWidget {
  const RippleImageButton({
    super.key,
    this.image,
    this.color,
    Function()? onTap,
    this.width = double.infinity,
    this.height = 80.0,
    this.margin,
    this.padding,
    this.constraints,
    this.borderRadius = 0.0,
    this.borderColor,
    this.fit = BoxFit.cover,
    this.splashColor,
    this.overlayColor,
    this.imageColorFilterEnabled = false,
    this.imageColorFilter =
        const ColorFilter.mode(Colors.purple, BlendMode.softLight),
    this.children,
    this.childrenMainAxisAlignment = MainAxisAlignment.center,
    this.childrenCrossAxisAlignment = CrossAxisAlignment.center,
    this.trailing,
    this.leading,
  })  : _onTap = onTap,
        assert(image != null || color != null, "image or color is required");

  final ImageProvider? image;
  final Color? color;
  final Function()? _onTap;
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final double borderRadius;
  final Color? borderColor;
  final BoxFit fit;
  final Color? splashColor;
  final Color? overlayColor;
  final bool imageColorFilterEnabled;
  final ColorFilter? imageColorFilter;
  final List<Widget>? children;
  final MainAxisAlignment childrenMainAxisAlignment;
  final CrossAxisAlignment childrenCrossAxisAlignment;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    // content
    Widget btnContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(
            width: 10.0,
          ),
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: childrenMainAxisAlignment,
            crossAxisAlignment: childrenCrossAxisAlignment,
            children: children ?? [],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(
            width: 10.0,
          ),
          trailing!,
        ],
      ],
    );

    return Stack(
      children: [
        Container(
          margin: margin,
          constraints: constraints,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.transparent,
            ),
            color: color ?? Colors.transparent,
            image: (image != null)
                ? DecorationImage(
                    image: image!,
                    fit: fit,
                    colorFilter:
                        (imageColorFilterEnabled) ? imageColorFilter : null,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: splashColor,
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: _onTap,
              child: Container(
                width: width,
                height: height,
                padding: padding,
                child: btnContent,
              ),
            ),
          ),
        ),

        // overlay
        Container(
          width: width,
          height: height,
          margin: margin,
          color: overlayColor,
        ),
      ],
    );
  }
}
