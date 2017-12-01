import argparse, logging, thread_worker, sys
from logging import handlers


def parse_args():
    desc = "ttf/otf fonts to jpg images set (JUST KOREAN)"
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--amqp-url', type=str, help='amqp url', required=True)
    parser.add_argument('--queue', type=str, help='queue name', required=True)
    parser.add_argument(
        '--log-path',
        type=str,
        default='output.log',
        help='log file path with filename',
        required=False)

    return parser.parse_args()


def main():
    # set args
    args = parse_args()
    amqp_url = args.amqp_url
    queue = args.queue
    log_path = args.log_path
    thread_num = 1

    # set logging
    log = logging.getLogger('')
    log.setLevel(logging.DEBUG)
    format = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s")

    ch = logging.StreamHandler(sys.stdout)
    ch.setFormatter(format)
    log.addHandler(ch)

    fh = handlers.RotatingFileHandler(
        log_path, maxBytes=(1048576 * 5), backupCount=7)
    fh.setFormatter(format)
    log.addHandler(fh)

    logging.basicConfig(
        filename=log_path, datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.DEBUG)

    # threading
    for i in range(0, thread_num):
        tw = thread_worker.ThreadWorker(amqp_url, queue,
                                        "Thread Number : " + str(i))
        tw.start()


if __name__ == '__main__':
    main()
