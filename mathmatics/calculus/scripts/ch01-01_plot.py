# import numpy as np
# import matplotlib.pyplot as plt

# plt.switch_backend('Agg')
# x = np.linspace(0, 2*np.pi, 100)
# y = np.sin(x)
# plt.plot(x, y)
# plt.show()


from sympy import symbols
from sympy.plotting import plot
x = symbols('x')
p1 = plot(x * x, show=False)
p2 = plot(x, show=False)
p1.append(p2[0])
# p1
# Plot object containing:
# [0]: cartesian line: x**2 for x over (-10.0, 10.0)
# [1]: cartesian line: x for x over (-10.0, 10.0)
p1.show()