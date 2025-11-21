import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/battle_room/cubits/message_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/multi_user_battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/models/message.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/utils/extensions.dart';

class MessageBoxContainer extends StatefulWidget {
  const MessageBoxContainer({
    required this.closeMessageBox,
    required this.battleRoomId,
    required this.quizType,
    super.key,
    this.topPadding,
  });

  final VoidCallback closeMessageBox;
  final double? topPadding;
  final String battleRoomId;
  final QuizTypes quizType;

  @override
  State<MessageBoxContainer> createState() => _MessageBoxContainerState();
}

const double tabBarHeightPercentage = 0.080;
const double messageBoxWidthPercentage = 0.775;

class _MessageBoxContainerState extends State<MessageBoxContainer> {
  late int _currentSelectedIndex = 1;
  late double messageBoxDetailsHeightPercentage =
      widget.quizType == QuizTypes.groupPlay ? .63 : .735;
  late final double messageBoxHeightPercentage = 0.45;

  Widget _buildTabbarTextContainer(String text, int index) {
    final size = context;
    return Container(
      height: size.height * .05,
      width: size.width * messageBoxWidthPercentage / 2.21,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.height * .05 / 2),
        color: index == _currentSelectedIndex
            ? Theme.of(context).primaryColor
            : Colors.transparent,
      ),
      child: Center(
        child: InkWell(
          onTap: () => setState(() => _currentSelectedIndex = index),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeights.regular,
              fontSize: 14,
              color: index == _currentSelectedIndex
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(
                      context,
                    ).colorScheme.onTertiary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final size = context;
    return Container(
      height: size.height * .05,
      width: size.width * messageBoxWidthPercentage,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(size.height * .05 / 2),
      ),
      margin: const EdgeInsets.only(top: 25, left: 13, right: 13, bottom: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabbarTextContainer(context.tr(messagesKey)!, 1),
          _buildTabbarTextContainer(context.tr(emojisKey)!, 2),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    if (_currentSelectedIndex == 0) {
      return const SizedBox();
    } else if (_currentSelectedIndex == 1) {
      return MessagesContainer(
        battleRoomId: widget.battleRoomId,
        closeMessageBox: widget.closeMessageBox,
      );
    }
    return EmojisContainer(
      battleRoomId: widget.battleRoomId,
      closeMessageBox: widget.closeMessageBox,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top:
            widget.topPadding ??
            (MediaQuery.of(context).padding.top + 7.5 + context.height * 0.09),
      ),
      width: context.width * messageBoxWidthPercentage,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: context.height * 0.085 * 0.25),
              width: context.width * messageBoxWidthPercentage,
              padding: const EdgeInsets.only(bottom: 15),
              height: context.height * messageBoxDetailsHeightPercentage,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildTabBarView(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
              ),
              child: _buildTabBar(context),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatContainer extends StatelessWidget {
  const ChatContainer({required this.quizType, super.key});

  final QuizTypes quizType;

  Widget _buildMessage(BuildContext context, Message message) {
    final messageByCurrentUser =
        message.by == context.read<UserDetailsCubit>().userId();
    final battleRoomCubit = context.read<MultiUserBattleRoomCubit>();

    return Align(
      alignment: messageByCurrentUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
          minWidth: context.width * 0.3,
          maxWidth: context.width * 0.5,
        ),
        margin: messageByCurrentUser
            ? const EdgeInsets.only(bottom: 20, right: 15)
            : const EdgeInsets.only(bottom: 20, left: 15),
        child: Column(
          crossAxisAlignment: messageByCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //
                if (messageByCurrentUser)
                  const SizedBox()
                else
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: 5,
                      start: 10,
                    ),
                    child: Text(
                      '${battleRoomCubit.getUser(message.by)!.name}  ',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),

                Padding(
                  padding: messageByCurrentUser
                      ? const EdgeInsets.only(bottom: 5, right: 10)
                      : const EdgeInsets.only(bottom: 5, left: 10),
                  child: Text(
                    '${message.timestamp.toDate().hour}:${message.timestamp.toDate().minute}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ],
            ),
            CustomPaint(
              painter: ChatMessagePainter(
                isLeft: !messageByCurrentUser,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: message.isTextMessage
                    ? Text(
                        message.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.25,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.85),
                        ),
                      )
                    : SizedBox(
                        height: 30,
                        width: context.width * 0.2,
                        child: SvgPicture.asset(
                          Assets.emoji(message.message),
                          colorFilter: ColorFilter.mode(
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.85),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      bloc: context.read<MessageCubit>(),
      builder: (context, state) {
        if (state is MessageFetchedSuccess) {
          var messages = state.messages;
          messages = messages.reversed.toList();
          return messages.isEmpty
              ? const SizedBox()
              : ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.only(
                    top: context.height * tabBarHeightPercentage,
                    bottom: 10,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(context, messages[index]);
                  },
                );
        }
        return const SizedBox();
      },
    );
  }
}

class MessagesContainer extends StatefulWidget {
  const MessagesContainer({
    required this.closeMessageBox,
    required this.battleRoomId,
    super.key,
  });

  final String battleRoomId;
  final VoidCallback closeMessageBox;

  @override
  State<MessagesContainer> createState() => _MessagesContainerState();
}

class _MessagesContainerState extends State<MessagesContainer> {
  int currentlySelectedMessageIndex = -1;

  Widget _buildMessages() {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: context.height * tabBarHeightPercentage,
        bottom: 10,
      ),
      itemCount: kPredefinedMessages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.width * .05,
            vertical: 10,
          ),
          child: InkWell(
            onTap: () {
              final messageCubit = context.read<MessageCubit>();

              final userDetailsCubit = context.read<UserDetailsCubit>();
              messageCubit.addMessage(
                message: kPredefinedMessages[index],
                by: userDetailsCubit.userId(),
                roomId: widget.battleRoomId,
                isTextMessage: true,
              );
              widget.closeMessageBox();
            },
            child: Text(
              kPredefinedMessages[index],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeights.semiBold,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(alignment: Alignment.topCenter, child: _buildMessages()),
      ],
    );
  }
}

class EmojisContainer extends StatefulWidget {
  const EmojisContainer({
    required this.closeMessageBox,
    required this.battleRoomId,
    super.key,
  });

  final VoidCallback closeMessageBox;
  final String battleRoomId;

  @override
  State<EmojisContainer> createState() => _EmojisContainerState();
}

class _EmojisContainerState extends State<EmojisContainer> {
  int currentlySelectedEmojiIndex = -1;

  Widget _buildEmojies(List<String> emojis) {
    return GridView.builder(
      padding: EdgeInsets.only(
        top: context.height * tabBarHeightPercentage,
        left: context.width * 0.05,
        right: context.width * 0.05,
        bottom: 10,
      ),
      itemCount: emojis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            final messageCubit = context.read<MessageCubit>();

            final userDetailsCubit = context.read<UserDetailsCubit>();
            messageCubit.addMessage(
              message: emojis[index],
              by: userDetailsCubit.userId(),
              roomId: widget.battleRoomId,
              isTextMessage: false,
            );
            widget.closeMessageBox();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: index == currentlySelectedEmojiIndex
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).scaffoldBackgroundColor,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 15),
            child: SvgPicture.asset(Assets.emoji(emojis[index])),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final emojis = context.read<SystemConfigCubit>().getEmojis();
    return Stack(
      children: [
        Align(alignment: Alignment.topCenter, child: _buildEmojies(emojis)),
      ],
    );
  }
}

class ChatMessagePainter extends CustomPainter {
  ChatMessagePainter({required this.isLeft, required this.color});

  bool isLeft;
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (isLeft) {
      path
        ..moveTo(size.width * 0.1, 0)
        ..lineTo(size.width * 0.9, 0)
        //add top-right curve effect
        ..quadraticBezierTo(size.width, 0, size.width, size.height * 0.2)
        ..lineTo(size.width, size.height * 0.8)
        //add bottom-right curve
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width * 0.9,
          size.height,
        )
        ..lineTo(size.width * 0.125, size.height)
        //add botom left shape
        ..lineTo(size.width * 0.025, size.height * 1.175)
        ..quadraticBezierTo(-10, size.height * 1.275, 0, size.height * 0.8)
        //add left-top curve
        ..lineTo(0, size.height * 0.2)
        ..quadraticBezierTo(0, 0, size.width * 0.1, 0);
      canvas.drawPath(path, paint);
    } else {
      //

      path
        ..moveTo(size.width * 0.1, 0)
        ..quadraticBezierTo(0, 0, 0, size.height * 0.2)
        ..lineTo(0, size.height * 0.8)
        ..quadraticBezierTo(0, size.height, size.width * 0.1, size.height)
        ..lineTo(size.width * 0.875, size.height)
        //add bottom right shape
        ..lineTo(size.width * 0.975, size.height * 1.175)
        ..quadraticBezierTo(
          size.width + 10,
          size.height * 1.275,
          size.width,
          size.height * 0.8,
        )
        ..lineTo(size.width, size.height * 0.2)
        ..quadraticBezierTo(size.width, 0, size.width * 0.9, 0)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
