import matplotlib.pyplot as plt
import numpy as np

#defining
fig = plt.figure()
ax = plt.gca()

#font settings
font = {'family': 'serif',
        'color':  'white',
        'weight': 'normal',
        'size': 12,
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

#setting values
xvalueja = ["ja"]
yvalueja = [3]
xvaluenein = ["nein"]
yvaluenein = [8]

#configuring bars
p1 = plt.barh(xvalueja, yvalueja, color="#00ff00")
p2 = plt.barh(xvaluenein, yvaluenein, color="#ff0000")

#configuring labels
plt.xlabel("Anzahl der Stimmen", fontdict=font)
plt.ylabel("Antwortmöglichkeiten", fontdict=font)

#showing graph
plt.show()