import pandas as pd
from tabulate import tabulate


def print_table(title, columns, data):
    print("\n" + "=" * 60)
    print(title)
    print("=" * 60)

    df = pd.DataFrame(data, columns=columns)

    print(tabulate(df,
                   headers="keys",
                   tablefmt="fancy_grid",
                   showindex=False))