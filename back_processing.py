import logging
import subprocess
import os


def back_processing(character_A, character_B, epoch):

    print(type(character_A))
    unicode_A = hex(ord(character_A))[2:].upper()
    unicode_B = hex(ord(character_B))[2:].upper()
    try:
        os.system('sh ./train_fromQueue.sh %s %s %s %s %s >> out.txt' % (character_A, character_B,
                                                         epoch, unicode_A, unicode_B))
    except Exception as e:
        logging.error("[%s]" % (e))
