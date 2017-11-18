import time
from options.train_options import TrainOptions
from data.data_loader import CreateDataLoader
from models.models import create_model
# from util.visualizer import Visualizer
from slackbot import slackbot

opt = TrainOptions().parse()
data_loader = CreateDataLoader(opt)
dataset = data_loader.load_data()
dataset_size = len(data_loader)
print('#training images = %d' % dataset_size)

model = create_model(opt)
# visualizer = Visualizer(opt)
total_steps = 0
time_start_training = time.time()
total_epoch = opt.niter + opt.niter_decay
bot = slackbot(opt.name)
is_debugging = opt.debugging
if (not is_debugging):
    bot.trainingBegin(total_epoch, opt.slack_freq)
if (is_debugging):
    print("--------------------this is debugging mode--------------------")

for epoch in range(opt.epoch_count, opt.niter + opt.niter_decay + 1):
    epoch_start_time = time.time()
    epoch_iter = 0

    if (is_debugging):
        time_before_dataEnum = time.time()
    print("::start enumerate dataset::")
    for i, data in enumerate(dataset):
        # print("::model begin::")
        iter_start_time = time.time()
        if (is_debugging):
            print("::[%d]time_data_enumerate : (%4f)::" %
                  (i, iter_start_time - time_before_dataEnum))
        total_steps += opt.batchSize
        epoch_iter += opt.batchSize
        model.set_input(data)
        model.optimize_parameters()
        if (is_debugging):
            time_after_modelOptimize = time.time()
            print("::[%d]time_model_optimize : (%4f)::" %
                  (i, time_after_modelOptimize - iter_start_time))

        # if total_steps % opt.display_freq == 0:
        #     visualizer.display_current_results(model.get_current_visuals(),
        #                                        epoch)

        if total_steps % opt.print_freq == 0:
            errors = model.get_current_errors()
            t = (time.time() - iter_start_time) / opt.batchSize
            # visualizer.print_current_errors(epoch, epoch_iter, errors, t)
            # if opt.display_id > 0:
            #     visualizer.plot_current_errors(epoch,
            #                                    float(epoch_iter) / dataset_size,
            #                                    opt, errors)

        if total_steps % opt.save_latest_freq == 0:
            print('saving the latest model (epoch %d, total_steps %d)' %
                  (epoch, total_steps))
            model.save('latest')
        if (is_debugging):
            iter_end_time = time.time()
            print("::[%d]time_etc: (%4f)::" % (i,
                  iter_end_time - time_after_modelOptimize))
            print("::[%d]time_total_iter: (%4f)::" % (i,
                  iter_end_time - iter_start_time))
            print("")
            time_before_dataEnum = time.time()

    if epoch % opt.save_epoch_freq == 0:
        print('saving the model at the end of epoch %d, iters %d' %
              (epoch, total_steps))
        time_taken = time.strftime(
            "%H:%M:%S", time.gmtime(time.time() - time_start_training))
        print('Time Taken: %s' % time_taken)
        model.save('latest')
        model.save(epoch)
    if epoch % opt.slack_freq == 0:
        time_taken = time.strftime(
            "%H:%M:%S", time.gmtime(time.time() - time_start_training))
        bot.trainingProgress(epoch, time_taken)

    print('End of epoch %d / %d \t Time Taken: %d sec' %
          (epoch, total_epoch, time.time() - epoch_start_time))
    model.update_learning_rate()

time_taken = time.strftime("%H:%M:%S",
                           time.gmtime(time.time() - time_start_training))
print('End of training of epoch (%d) \t Time Taken: %s' % (total_epoch,
                                                           time_taken))
if (not is_debugging):
    bot.trainingDone(total_epoch, time_taken)
