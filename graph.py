import matplotlib.pyplot as plt
import numpy as np
import os
from random import shuffle
import sys

#defining
fig = plt.figure()
ax = plt.gca()
barcount = 0

#setting values
xvalues = ["ja", "enthaltung", "nein"]
yvalues = [3, 2, 7]
if len(xvalues) > 6:
    print("too many answers")
    sys.exit()
if len(yvalues) != len(xvalues):
    print("answer and votes must be same amount of vars")
    sys.exit()

#font settings
font = {'family': 'serif',
        'color':  'white',
        'weight': 'normal',
        'size': 12,
        }

heading = {'family': 'serif',
        'color':  'white',
        'weight': 'normal',
        'size': 16,
        }

#set background color
fig.patch.set_facecolor("#49565c")
ax.set_facecolor("#49565c")

#configure spines
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_color("#ffffff")
ax.spines["bottom"].set_color("#ffffff")

#setting tick color
plt.tick_params(color="#ffffff",labelcolor="#ffffff")

#setting heading
title = "Platzhalter für Überschrift und Nummer"
plt.title(title, fontdict=heading, loc="center")


#setting bar colors
if xvalues == ["ja", "enthaltung", "nein"]:
    barcolors = ["green", "yellow", "red"]
else:
    barcolors = ["red", "orange", "yellow", "green", "blue", "purple"]
    shuffle(barcolors)


#creating bars
for x in xvalues:
    plt.barh(xvalues[barcount], yvalues[barcount], color=barcolors[barcount])
    barcount = barcount + 1


#configuring labels
plt.xlabel("Anzahl der Stimmen", fontdict=font)
plt.ylabel("Antwortmöglichkeiten", fontdict=font)

#generating image
if os.path.exists("graphs"):
    os.chdir("graphs")
    if os.path.isfile("counter"):
        r = open("counter", "r")
        counter = int(r.read())
        r.close()
        counter = counter + 1
        c = open("counter", "w")
        counter = str(counter)
        c.write(counter)
        c.close()
    else:
        counter = 1
        c = open("counter", "w")
        counter = str(counter)
        c.write(counter)
        c.close()
else:
    os.mkdir("graphs")
    os.chdir("graphs")
    counter = 1
    c = open("counter", "w")
    counter = str(counter)
    c.write(counter)
    c.close()

plt.savefig("graph" + counter + ".png")