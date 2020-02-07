import csv

__author__ = "Chau.Tran"


def read_csv(filename, ignore_header=True):
    """
    Read data from a normal csv file, not a machine learning dataset
    :param filename:
    :param ignore_header:
    :return:
    """
    with open(filename, 'rb') as f:
        reader = csv.reader(f)

        if ignore_header:
            reader.next()
        for row in reader:
            yield row


def write_csv(filename, rows, header=None):
    """Write iterable of row dict into filename"""

    with open(filename, 'w+') as f:
        w = csv.writer(f, dialect='excel')

        if len(header) > 0:
            w.writerow(header)
        count = 0

        for row in rows:
            w.writerow(row)
            count += 1
            print('Write %s rows into %s' % (count, f.name))


def write_df_csv(filename, df, header):
    """Write a dataframe to csv file"""

    with open(filename, 'w+') as f:
        df.to_csv(f, header=header, index=False)


def write_df_gzip(filename, df, header=None):
    """Write a Pandas dataframe to csv file"""

    import gzip

    with gzip.open(filename, 'w+') as f:
        df.to_csv(f, header=header, index=False, compression='gzip', encoding='utf-8', date_format='%s')
