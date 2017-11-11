import argparse
from slackbot import slackbot


def parse_args():
    desc = "send message to slack"
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--msg', type=str, help='message', required=True)
    parser.add_argument(
        '--channel',
        type=str,
        default='bot',
        help='which channel you want to send to',
        required=False)
    parser.add_argument(
        '--tocken', type=str, default='-1', help='put a token', required=False)

    return parser.parse_args()


def main():
    args = parse_args()

    channel = "#" + args.channel
    msg = args.msg
    tocken = args.tocken

    bot = slackbot()
    bot.sendMessage(channel, msg)
    print("sent a massege to %s!" % channel)


if __name__ == '__main__':
    main()
