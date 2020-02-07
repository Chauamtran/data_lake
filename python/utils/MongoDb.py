from pymongo import MongoClient
from python.utils.LoggingUtils import Logger

__author__ = "Chau.Tran"

try:
    from urllib.parse import quote_plus
except Exception as ex:
    from urllib import quote_plus


class MongoDb(object):
    def __init__(self, host, port, authSource=None, username=None, password=None, replica=None):
        self.logger = Logger("MONGODB LOGGER")
        # Connection to Mongo DB
        try:
            if replica is not None:
                self.logger.info(replica)
                host_port = host + ":" + str(port)

                if username is not None:
                    uri = "mongodb://{}:{}@{}".format(username, password, host)
                    self.conn = MongoClient(uri,
                                            authSource=authSource,
                                            replicaSet=replica,
                                            readPreference='secondaryPreferred')
                else:
                    self.conn = MongoClient(host_port,
                                            replicaSet=replica,
                                            readPreference='secondaryPreferred')
            else:
                if username is not None:
                    uri = "mongodb://{}:{}@{}".format(username, password, host)
                    self.conn = MongoClient(uri, authSource=authSource)
                else:
                    self.conn = MongoClient(host=host, port=port)

            self.logger.info("Connected successfully!!!")
        except Exception as ex:
            self.logger.info("Could not connect to MongoDB: {}".format(ex.__str__()))

    def __del__(self):
        """
        Close a connection
        :return: None
        """
        self.conn.close()
        self.logger.info("Close database connection successfully!")

    def getCollections(self, database=None):
        """
        Get all collections from a database
        :param database: Database where to retrieve collections
        :return: list of collection objects
        """
        assert database is not None

        return self.conn[database].collection_names()

    def getOneCollection(self, database=None, collection=None):
        """
        Get one collection from a database
        :param database: Database to retrieve collection
        :param collection: collection name
        :return: collection object
        """
        assert database is not None
        assert collection is not None

        return self.conn[database][collection]

