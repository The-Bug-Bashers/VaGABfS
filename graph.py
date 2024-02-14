import matplotlib.pyplot as plt
import numpy as np

xvalues = ["ja", "nein"]
yvalues = [3,8]
plt.barh(xvalues, yvalues)
plt.xlabel("Anzahl der Stimmen")
plt.ylabel("Antwortmöglichkeiten")
plt.show()