from unicode2class import unicode2class
import os

STANDARD = [
    '',
    '라',
    '영',
    '젊',
    '후',
    '음',
    '끓',
    '회',
    '원',
    '봤',
]

count = 0
EPOCH = 1000
HOW_MANY = 200
FILE_NAME = "korean_freq.txt"

f = open(FILE_NAME, 'r')

while count < HOW_MANY:
    line = f.readline()
    if not line: break
    classNum = unicode2class(ord(line[0]))
    if classNum >= 1:
        print("[%d]%c -> %c" % (count + 1, STANDARD[classNum], line[0]))
        os.system(
            'node ./test-publisher/send_to_queue.js --hangle1=%s --hangle2=%s --epoch=%d'
            % (STANDARD[classNum], line[0], EPOCH))

        count += 1

f.close()
