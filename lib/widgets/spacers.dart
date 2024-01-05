import 'package:flutter/cupertino.dart';

class VerticalSpacer extends StatelessWidget {
  final double size;

  const VerticalSpacer(this.size, {Key? key}) : super(key: key);

  const VerticalSpacer.of2({Key? key})
      : size = 2,
        super(key: key);

  const VerticalSpacer.of10({Key? key})
      : size = 10,
        super(key: key);

  const VerticalSpacer.of13({Key? key})
      : size = 13,
        super(key: key);

  const VerticalSpacer.of20({Key? key})
      : size = 20,
        super(key: key);

  const VerticalSpacer.of23({Key? key})
      : size = 23,
        super(key: key);

  const VerticalSpacer.of30({Key? key})
      : size = 30,
        super(key: key);

  const VerticalSpacer.of40({Key? key})
      : size = 40,
        super(key: key);

  const VerticalSpacer.of60({Key? key})
      : size = 60,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size);
  }
}

class HorizontalSpacer extends StatelessWidget {
  final double size;

  const HorizontalSpacer(this.size, {Key? key}) : super(key: key);

  const HorizontalSpacer.of2({Key? key})
      : size = 2,
        super(key: key);

  const HorizontalSpacer.of10({Key? key})
      : size = 10,
        super(key: key);

  const HorizontalSpacer.of20({Key? key})
      : size = 20,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size);
  }
}
