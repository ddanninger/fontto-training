import logging
import subprocess


def back_processing(unicode_A, unicode_B, epoch):

    try:
        result = subprocess.check_output('./train.sh %s %s %d' % (unicode_A, unicode_B, epoch), shell=True)
    except Exception as e:
        logging.error("[%s]" % (e))

