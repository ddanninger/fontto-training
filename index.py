import logging, thread_worker, sys
from logging import handlers
import os

def main():
    # set args
    amqp_url = os.environ["AMQP_TRAINING"]
    queue = 'dev_trainingQueue'
    log_path = 'output.log'
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
