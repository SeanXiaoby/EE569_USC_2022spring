# EE569 Homework Assignment #5 Sample Code
# requirements: python3 + pytorch
import math
import matplotlib.pyplot as plt
from matplotlib.pyplot import MultipleLocator
import numpy as np
import statistics as st
import os
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torchvision as tv
import torchvision.transforms as transforms

train_batch_size = 64
test_batch_size = 1000


class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.conv1 = nn.Conv2d(1, 6, 5, stride=1, padding=2)
        self.conv2 = nn.Conv2d(6, 16, 5, stride=1, padding=0)
        self.fc1 = nn.Linear(16 * 5 * 5, 120)
        self.fc2 = nn.Linear(120, 84)
        self.fc3 = nn.Linear(84, 10)

    def forward(self, x):
        x = F.max_pool2d(F.relu(self.conv1(x)), 2)
        x = F.max_pool2d(F.relu(self.conv2(x)), 2)
        x = x.view(-1, self.num_flat_features(x))
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        x = self.fc3(x)
        return x

    def num_flat_features(self, x):
        # x is a 4D tensor
        x_size = x.size()[1:]
        num = 1
        for n in x_size:
            num *= n
        return num


def load_data():
    transform = transforms.Compose(
        [transforms.ToTensor(),
         transforms.Normalize((0.1307,), (0.3081,))])
    train_set = tv.datasets.MNIST(
        root='./data',
        train=True,
        download=True,
        transform=transform
    )
    train_set = add_noise(train_set, 0.4)
    train_loader = torch.utils.data.DataLoader(
        train_set,
        batch_size=train_batch_size,
        shuffle=True,
        num_workers=2)
    test_set = tv.datasets.MNIST(
        root='./data',
        train=False,
        download=True,
        transform=transform
    )
    test_loader = torch.utils.data.DataLoader(
        test_set,
        batch_size=test_batch_size,
        shuffle=False,
        num_workers=2)
    print("data loaded successfully...")
    return train_loader, test_loader, train_set, test_set


# def add_noise(dataset, error_rate=0.4):
#     confusion_matrix = np.zeros([10, 10])
#     total = [0] * 10
#     a = 0
#     for index, data in enumerate(dataset):
#         images, labels = data
#         if a == 0:
#             print(labels)
#             a+=1
#         for i in range(len(labels)):
#             total[labels[i]] += 1
#             ori_labels = int(labels[i])
#             if np.random.rand(1) > (1 - error_rate):
#                 whole_label = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
#                 whole_label.remove(labels[i])
#                 labels[i] = whole_label[np.random.randint(0, 9)]
#             # print(str(ori_labels) + " " + (labels[i]))
#             #     print(f"{ori_labels} {labels[i]}")
#             confusion_matrix[labels[i], ori_labels] += 1
#
#     for col in range(np.size(confusion_matrix, 1)):
#         for row in range(np.size(confusion_matrix, 0)):
#             confusion_matrix[row][col] = confusion_matrix[row][col] / total[col]
#
#     a = 0
#     for data in dataset:
#         images, labels = data
#         if a == 0:
#             print(labels)
#             a+=1
#
#     return confusion_matrix

def add_noise(dataset, error_rate = 0.4):

    labels = dataset.targets
    for i in range(len(labels)):
        if np.random.rand(1) > (1 - error_rate):
            whole_label = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
            whole_label.remove(labels[i])
            labels[i] = whole_label[np.random.randint(0, 9)]
    dataset.targets = labels

    return dataset


def accuracy(model, x, neg=False):
    with torch.no_grad():
        correct = 0
        total = 0
        class_correct = list(0. for i in range(10))
        class_total = list(0. for i in range(10))
        for data in x:
            images, labels = data
            if neg:
                images = -images
            images, labels = images, labels
            outputs = model(images)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

        return (100 * correct / total)


def getConfusion(model, x, neg=False):
    with torch.no_grad():
        confusionMatrix = np.zeros([10, 10])
        total = [0] * 10
        class_correct = list(0. for i in range(10))
        class_total = list(0. for i in range(10))
        for data in x:
            images, labels = data
            if neg:
                images = -images
            images, labels = images, labels
            outputs = model(images)
            _, predicted = torch.max(outputs.data, 1)
            for i in range(len(labels)):
                total[labels[i]] += 1
                confusionMatrix[predicted[i]][labels[i]] += 1

        for col in range(np.size(confusionMatrix, 1)):
            for row in range(np.size(confusionMatrix, 0)):
                confusionMatrix[row][col] = confusionMatrix[row][col] / total[col]

        return confusionMatrix


def train(train_loader, test_loader, model, criterion, optimizer, epoch):
    model.train()
    running_loss = 0
    for i, data in enumerate(train_loader, 0):
        inputs, labels = data
        inputs, labels = inputs, labels
        optimizer.zero_grad()
        outputs = net(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        # print statistics
        running_loss += loss.item()
        if i % 200 == 199:
            print("[epoch %d, iter %5d] loss: %.3f" % (epoch + 1, i + 1, running_loss / 200))
            running_loss = 0.0
    train_acc = accuracy(model, train_loader)
    test_acc = accuracy(model, test_loader)
    print("epoch %d: train_acc %.3f, test_acc %.3f" % (epoch + 1, train_acc, test_acc))
    return train_acc, test_acc


def display(train_acc, test_acc):
    fig, ax = plt.subplots()
    ax.plot(range(1, len(train_acc) + 1), train_acc, color='r', label='train_acc')
    ax.plot(range(1, len(test_acc) + 1), test_acc, color='b', label='test_acc')
    ax.legend(loc='lower right')
    ax.set_xlabel('epoch#')
    ax.set_ylabel('accuracy')
    plt.show()


def show_confusion(confusionMatrix):
    fig, ax = plt.subplots()
    im = ax.imshow(confusionMatrix, cmap="Blues")
    ax.figure.colorbar(im)
    for row in range(len(confusionMatrix)):
        for col in range(len(confusionMatrix[row])):
            ax.text(col, row, np.round_(confusionMatrix[row][col], decimals=2), fontsize=9, verticalalignment="center",
                    horizontalalignment="center")
    ax.xaxis.set_major_locator(MultipleLocator(1))
    ax.yaxis.set_major_locator(MultipleLocator(1))
    ax.set_xlabel('Actual value')
    ax.set_ylabel('Predicted value')
    plt.show()


if __name__ == '__main__':
    # input MNIST
    train_loader, test_loader, train_set, test_set = load_data()
    testing_accuracies = [0]*5
    for i in range(5):
        # new model
        net = Net()

        print('*****Now start run#'+str(i)+'*****')

        # training
        learning_rate = 0.002
        momentum = 0.75
        decay = 0
        max_epoch = 10
        criterion = nn.CrossEntropyLoss()
        optimizer = optim.SGD(net.parameters(), lr=learning_rate, momentum=momentum, weight_decay=decay)

        train_acc = []
        test_acc = []
        for epoch in range(max_epoch):
            train_acc_t, test_acc_t = train(train_loader, test_loader, net, criterion, optimizer, epoch)
            train_acc.append(train_acc_t)
            test_acc.append(test_acc_t)
            # if test_acc[len(test_acc)-1] >= 99:
            #     break

        display(train_acc, test_acc)

        testing_accuracies[i] = test_acc[-1]

    print("Final testing accuracy: %.3f, standard deviation: %.3f" % (st.mean(testing_accuracies), st.stdev(testing_accuracies)))


    # confusionMatrix = getConfusion(net, test_loader)
    # show_confusion(confusionMatrix)
