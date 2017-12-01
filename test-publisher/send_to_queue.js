var amqp = require('amqplib/callback_api');
var args = require('args');

function bail(err) {
    console.error(err);
    process.exit(1);
}

function checkArgs(flags) {
    if (flags.hangle1 === undefined || flags.hangle1 === undefined || flags.epoch === undefined) {
        return false;
    } else {
        return true;
    }
}

args.option('hangle1', 'hangle 1')
    .option('hangle2', 'hangle 2')
    .option('epoch', 'epoch')

const flags = args.parse(process.argv);

if (!checkArgs(flags)) {
    console.log('check arguments!')
} else {
    const hangle1 = flags.hangle1;
    const hangle2 = flags.hangle2;
    const epoch = flags.epoch;

    const queue = 'dev_trainingQueue';
    const amqpUrl = process.env.AMQP_TRAINING

    amqp.connect(amqpUrl, function (err, conn) {
        if (err !== null) bail(err);

        conn.createChannel(on_open);

        function on_open(err, ch) {
            if (err != null) bail(err);
            ch.assertQueue(queue);
            
            var messageObj = {};
            messageObj.character1 = hangle1
            messageObj.character2 = hangle2
            messageObj.epoch = epoch
            var message = JSON.stringify(messageObj);

            code = ch.sendToQueue(queue, new Buffer(message));

            console.log('-----------------------------');
            console.log(messageObj);
            console.log('-----------------------------');
            setTimeout(function () { process.exit(2); }, 1000);
        }
    });
}
