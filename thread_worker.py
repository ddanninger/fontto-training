import threading, pika, logging, json
from back_processing import back_processing


def is_korean(unicode_input):
    return unicode_input >= '가' and unicode_input <= '힣'


class ThreadWorker(threading.Thread):

    def __init__(self, amqp_url, queue, thread_num):
        print(thread_num, "run")
        super().__init__()
        self.amqp_url = amqp_url
        self.thread_num = thread_num
        self.queue = queue
        self.channel = None

    def run(self):
        connection = pika.BlockingConnection(pika.URLParameters(self.amqp_url))
        self.channel = connection.channel()
        self.channel.queue_declare(queue=self.queue, durable=True)

        self.channel.basic_consume(
            self.processing_callback, queue=self.queue, no_ack=True)
        logging.info('fontto-training started!')
        self.channel.start_consuming()

    def processing_callback(self, ch, method, properties, body):
        logging.info("%s" % self.thread_num)
        logging.info("received %r" % body)

        received_message = json.loads(body.decode('utf8').replace("'", '"'))
        character_A = received_message['character1']
        character_B = received_message['character2']
        epoch = received_message['epoch']

        if (not is_korean(character_A) or not is_korean(character_B) or
                not type(epoch) == int):
            logging.warning(
                '!!!Wrong Input!!! [character_A : %s], [character_B : %s], [epoch : %s] '
                % (character_A, character_A, epoch))
        else:
            back_processing(character_A, character_B, epoch)

        received_message_dumps = json.dumps(received_message, indent=4)
        print(received_message_dumps)

        # processing...........
