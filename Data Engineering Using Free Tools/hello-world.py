print('hello world')

# list of tuples
organisers = [
        ('Dominic', 'Winsor'),
        ('James', 'Yarrow'),
        ('Anna-Marie', 'Wykes')
        ]

# import tabulate
# this will need to be installed using pip ie pip install tabulate
from tabulate import tabulate

table = tabulate(organisers, headers=['First name', 'Last name'])

print(table)