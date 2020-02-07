import sys
import ast
import profilehooks
from confluent_kafka import Producer
from python.utils.LoggingUtils import Logger
from python.utils.ElasticSearch import ElasticSearch
from python.utils.ReadConfigUtils import ReadConfig

logger = Logger('ElasticSearch Extraction', log_file='./logs/elastic_search_extraction.log')

database_config = ReadConfig('./python/config/database.ini')

if len(sys.argv) == 1:
    logger.info(msg="Usage: python3.6 script_name.py arg1 \n" +
                    "- arg1: Environment server to read (prod, sb). Default = sb\n")
    exit(1)
else:
    es_host_port = ast.literal_eval(database_config.read_config(sys.argv[1], 'es_host_port'))
    es_test_index = ast.literal_eval(database_config.read_config(sys.argv[1], 'es_test_index'))

    kafka_broker_list = ast.literal_eval(database_config.read_config(sys.argv[1], 'kafka_broker_list'))
    kafka_test_topic_es = ast.literal_eval(database_config.read_config(sys.argv[1], 'kafka_test_topic_es'))

    es = ElasticSearch(host_port=es_host_port)


@profilehooks.timecall
def checkAndCreateTopics(topic_name=None, partition_num=4, replication_factor=3):

    from confluent_kafka.admin import AdminClient, NewTopic

    assert topic_name is not None

    try:
        a = AdminClient({'bootstrap.servers': kafka_broker_list})
        if topic_name in a.list_topics(topic=topic_name).topics:
            return True

        new_topic = [NewTopic(topic=topic_name, num_partitions=partition_num, replication_factor=replication_factor)]
        results = a.create_topics(new_topics=new_topic)
        for topic, f in results.items():
            try:
                f.result()
                logger.info("Topic {} created!".format(topic))
            except Exception as ex:
                logger.info("Failed to create topic {}:{}".format(topic, ex.__str__()))
                return False
    except Exception as ex:
        logger.info(msg=ex.__str__())

    return True


def generateBody():
    query = {
                "query":
                        {
                            "bool":
                                {
                                    "must_not": [
                                        {
                                        }
                                    ]
                                }
                        },
                "sort": [
                    {
                        "startTime":
                            {
                                "order": "asc"
                            }
                    }
                ]
            }

    return query


@profilehooks.timecall
def getESData(body=None):
    """
    Get data from Elastic Search
    :return: Json data from query
    """
    try:
        logger.info(msg='Init Scroll')
        data = es.initScroll(index=es_auth_account_index, body=body)
    except Exception as ex:
        logger.info(msg=ex.__str__())

    return data


def delivery_report(err, msg):
    """
    Called once for each message produced to indicate delivery result.
    Triggerd by poll() or flush()
    :param err:
    :param msg:
    :return:
    """

    if err is not None:
        logger.info(msg='Message delivery failed: {}'.format(err))
    else:
        logger.info(msg='Message delivery to {} [{}]'.format(msg.topic(), msg.partition()))


@profilehooks.timecall
def produceDataToKafka(data=None, topic=None):
    import simplejson as json

    assert data is not None
    assert topic is not None

    try:
        logger.info(msg='Check and create topics if not exists.')

        logger.info(msg='Produce Data to Kafka')
        p = Producer({'bootstrap.servers': kafka_broker_list})
        real_data = data['hits']['hits']
        for record in real_data:
            p.poll(0)

            # Produce message to Kafka
            json_obj = json.dumps(record['_source'])
            logger.info(msg='Produce {} to {}'.format(json_obj, topic))

            p.produce(topic=topic, value=json_obj.encode('utf-8'), callback=delivery_report)

        # Call back to trigger delivery report
        p.flush()
        logger.info(msg='Finished pushing to Kafka')
    except Exception as ex:
        logger.info(msg=ex.__str__())


@profilehooks.timecall
def processData():
    """
    Process data
    :return:
    """

    try:
        logger.info(msg='Generate query')
        query = generateBody()
        data = getESData(body=query)
        scroll_id = data['_scroll_id']
        scroll_size = len(data['hits']['hits'])

        checkAndCreateTopics(topic_name=kafka_test_topic_es, partition_num=4, replication_factor=3)
        while scroll_size > 0:
            logger.info(msg='Scroll Size: {}\n'.format(scroll_size))
            produceDataToKafka(data=data, topic=kafka_test_topic_es)

            # Call next scroll
            data = es.searchScroll(scroll_id=scroll_id, scroll='3m')

            # Update scroll_id
            scroll_id = data['_scroll_id']

            # Get new len of next batch
            scroll_size = len(data['hits']['hits'])

        logger.info('Finish pushing data.')
    except Exception as ex:
        logger.info(msg=ex.__str__())


if __name__ == "__main__":
    processData()