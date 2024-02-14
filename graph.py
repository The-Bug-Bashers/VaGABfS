import matplotlib.pyplot as plt
import numpy as np

fig = plt.figure()
ax = plt.gca()

font = {'family': 'serif',
        'color':  'white',
        'weight': 'normal',
        'size': 12,
        }

fig.patch.set_facecolor("#49565c")
ax.set_facecolor("#49565c")

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_color("#ffffff")
ax.spines["bottom"].set_color("#ffffff")

xvalueja = ["ja"]
yvalueja = [3]
xvaluenein = ["nein"]
yvaluenein = [8]

p1 = plt.barh(xvalueja, yvalueja, color="#00ff00")
p2 = plt.barh(xvaluenein, yvaluenein, color="#ff0000")

plt.xlabel("Anzahl der Stimmen", fontdict=font)
plt.ylabel("Antwortmöglichkeiten", fontdict=font)
plt.show()