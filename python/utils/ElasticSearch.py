from elasticsearch import Elasticsearch
from python.utils.Logging import Logger


class ElasticSearch:
    timeout = 1000

    def __init__(self, host_port):
        # host_port = str(host) + ':' + str(port)
        self.conn = Elasticsearch(
                    hosts=host_port,
                    timeout=self.timeout,
                    retry_on_timeout=True
                    # sniff_on_start=True,
                    # sniff_on_connection_fail=True,
                    # sniff_timeout=True
        )

        self.logger = Logger(name='ElasticSearch LOGGER')
        self.logger.info(msg='Init connection at {}'.format(host_port))

    def __del__(self):
        """
        Close opened connections
        :return:
        """
        for conn in self.conn.transport.connection_pool.connections:
            conn.pool.close()

    def search(self, index=None, doc_type='message', body={}, size=1000):
        """
        Normal search
        :param index: index to search
        :param doc_type: type of index
        :param body: query
        :param size: size of return records
        :return: data with query
        """
        try:
            assert index is not None

            if self.conn.indices.exists(index=index):
                data = self.conn.search(
                    index=index,
                    doc_type=doc_type,
                    size=size,
                    body=body
                )
        except Exception as ex:
            self.logger.info(msg=ex.__str__())

        return data

    def initScroll(self, scroll='5m', index=None, doc_type='message', size=1000, body={}):
        """
        Init search with scroll
        :param scroll: Expired time of a scroll search
        :param index: Index to search
        :param doc_type: Type of docs
        :param size: Size of
        :param body:
        :return:
        """
        try:
            if self.conn.indices.exists(index=index):
                data = self.conn.search(
                    index=index,
                    doc_type=doc_type,
                    scroll=scroll,
                    size=size,
                    body=body
                )
        except Exception as ex:
            self.logger.info(msg=ex.__str__())

        return data

    def searchScroll(self, scroll_id=None, scroll='5m'):
        try:
            return self.conn.scroll(scroll_id=scroll_id, scroll=scroll)
        except Exception as ex:
            self.logger.info(msg=ex.__str__())

        return None




