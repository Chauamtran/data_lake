import pymysql.cursors
from python.utils.LoggingUtils import Logger


class MySQL(object):

    def __init__(self, host, user, passwd, db):

        self.conn = pymysql.connect(
                    host=host,
                    user=user,
                    password=passwd,
                    db=db,
                    charset='utf8mb4',
                    cursorclass=pymysql.cursors.DictCursor
        )

        self.logger = Logger(name=' MYSQL LOGGER')
        self.logger.info(msg='Init connection at {}'.format(host))

    def __del__(self):
        """
        Close opened connections
        :return:
        """

        self.conn.close()

    def readOne(self, query, params=None):
        """
        Read one line data from sql
        :param query: Sql scripts
        :param params: Params to pass
        :return: Data to be read
        """

        with self.conn.cursor() as cursor:
            cursor.execute(query=query, args=params)
            result = cursor.fetchone()

        return result

    def readMany(self, query, params=None, size=10):
        """
        Read many lines data from sql
        :param query:
        :param params:
        :return:
        """
        with self.conn.cursor() as cursor:
            cursor.execute(query=query, args=params)
            result = cursor.fetchmany(size=size)

        return result

    def readAll(self, query, params=None):
        """
        Read all data from sql
        :param query:
        :param params:
        :return:
        """

        with self.conn.cursor() as cursor:
            cursor.execute(query=query, args=params)
            result = cursor.fetchall()

        return result

    def write(self, query, params=None):
        """
        Write/Update data
        :param query:
        :param params:
        :return:
        """

        with self.conn.cursor() as cursor:
            cursor.execute(query=query, args=params)
            self.conn.commit()
