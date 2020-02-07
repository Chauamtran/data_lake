import sys
import ast
import profilehooks
from confluent_kafka import Producer
from python.utils.LoggingUtils import Logger
from python.utils.MongoDb import MongoDb
from python.utils.ReadConfigUtils import ReadConfig

logger = Logger('Mongo DB Extraction', log_file='./logs/mongo_extraction.log')

database_config = ReadConfig('./Python/config/database.ini')

if len(sys.argv) == 1 or len(sys.argv) == 2:
    logger.info(msg="Usage: python3.6 script_name.py arg1 db_name\n" +
                    "- arg1: Environment server to read (prod, sb). Default = sb\n" +
                    "- arg2: Authen db\n"
                )
    exit(1)
else:

    mongo_host = ast.literal_eval(database_config.read_config(sys.argv[1], 'mongo_host'))
    mongo_port = ast.literal_eval(database_config.read_config(sys.argv[1], 'mongo_port'))
    mongo_username = ast.literal_eval(database_config.read_config(sys.argv[1], 'mongo_username'))
    mongo_password = ast.literal_eval(database_config.read_config(sys.argv[1], 'mongo_password'))
    mongo_replica_set = ast.literal_eval(database_config.read_config(sys.argv[1], 'mongo_replica_set'))
    kafka_broker_list = ast.literal_eval(database_config.read_config(sys.argv[1], 'kafka_broker_list'))
    kafka_auth_account_topic_mongo = ast.literal_eval(database_config.read_config(sys.argv[1],
                                                                                  'kafka_auth_account_topic_mongo'))

    authen_db = sys.argv[2]
    mongo_conn = MongoDb(host=mongo_host, port=mongo_port,
                         username=mongo_username,
                         password=mongo_password,
                         authSource=authen_db,
                         replica=mongo_replica_set)


@profilehooks.timecall
def checkAndCreateTopics(topic_name=None, partition_num=4, replication_factor=3):

    from confluent_kafka.admin import AdminClient, NewTopic

    assert topic_name is not None
    assert partition_num is not None
    assert replication_factor is not None

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


# @profilehooks.timecall
# def getMongoDataList(page_size=None, page_number=None):
#     """
#     Approach 1, just run once
#
#     Get data from MongoDB
#     Return a list of documents belonging to page_number and size of each page is page_size
#     :return: List of data
#
#     """
#
#     assert page_number is not None
#     assert page_size is not None
#
#     try:
#         # Calculate number of documents to skip
#         skip_nums = (page_number-1)*page_size
#
#         results = mongo_conn.getOneCollection(database=authen_db, collection=authen_db).\
#                              find().skip(skip=skip_nums).limit(limit=page_size)
#     except Exception as ex:
#         logger.info(msg=ex.__str__())
#
#     return [doc for doc in results]


@profilehooks.timecall
def getMongoDataList(page_size=None, last_id=None):
    """
    Approach 2, can run incrementally
    Get data from MongoDB

    :param page_size: size of one turn
    :param last_id: last id for next run
    :return: data, last_id
    """
    from bson import ObjectId

    assert page_size is not None

    try:
        # Run for first time
        if last_id is None:
            result = mongo_conn.getOneCollection(database=authen_db, collection=authen_db). \
                                find().limit(limit=page_size)
        else:
            result = mongo_conn.getOneCollection(database=authen_db, collection=authen_db). \
                                find({'_id': {'$gt': ObjectId(last_id)}}).limit(limit=page_size)

        data = [x for x in result]

        # Get last id from data for next run, else keep last_id at previous run
        last_id_record = data[-1]['_id'] if len(data) > 0 else last_id

        return data, last_id_record

    except Exception as ex:
        logger.info(msg=ex.__str__())


def delivery_report(err, msg):
    """
    Called once for each message produced to indicate delivery result.
    Triggerd by poll() or flush()
    :param err:
    :param msg:
    :return: None
    """

    if err is not None:
        logger.info(msg='Message delivery failed: {}'.format(err))
    else:
        logger.info(msg='Message delivery to {} [{}]'.format(msg.topic(), msg.partition()))


@profilehooks.timecall
def produceDataToKafka(data=None, topic=None):
    """
    Push data to kafka
    :param data: data to push
    :param topic: topic name
    :return: None
    """
    import simplejson as json

    assert data is not None
    assert topic is not None

    try:
        logger.info(msg='Check and create topics if not exists.')

        logger.info(msg='Produce Data to Kafka')
        p = Producer({'bootstrap.servers': kafka_broker_list})
        for record in data:
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
def processData(last_id=None):
    """
    Process data incrementally and push to kafka
    :return: last_id to store
    """

    try:
        logger.info(msg='Processing data')
        data_list, last_id_record = getMongoDataList(page_size=100, last_id=last_id)
        logger.info(data_list)
        checkAndCreateTopics(topic_name=kafka_auth_account_topic_mongo)
        while len(data_list) > 0:
            logger.info(msg='Data Size: {}\n'.format(len(data_list)))
            produceDataToKafka(data=data_list, topic=kafka_auth_account_topic_mongo)

            # Call next scroll
            data_list, last_id_record = getMongoDataList(page_size=100, last_id=last_id_record)

        logger.info('Finish pushing data.')
        return last_id_record
    except Exception as ex:
        logger.info(msg=ex.__str__())

    return None


@profilehooks.timecall
def storeLastId(last_id=None, last_id_file='last_id.txt'):
    """
    Store last id for next run
    :param last_id_file:
    :return: None
    """

    assert last_id is not None

    with open(last_id_file, 'a+') as id_file:
        id_file.write(str(last_id)+'\n')


@profilehooks.timecall
def getLastId(last_id_file='last_id.txt'):
    """
    Store last id for next run
    :param last_id_file:
    :return: None
    """

    try:
        with open(last_id_file, 'r') as id_file:
            lines = id_file.read().splitlines()
            last_lines = lines[-1]
            last_id = last_lines.replace('\n', '')

            return last_id
    except Exception as ex:
        logger.info(msg=ex.__str__())

    return None


if __name__ == "__main__":
    id_file = './MongoDbData/last_id.txt'
    # Get last id from previous run
    previous_id = getLastId(last_id_file=id_file)
    # Process data and return last id for this run
    last_id = processData(last_id=previous_id)
    # Store to file for next run
    storeLastId(last_id=last_id, last_id_file=id_file)
    logger.info(msg="Store last_id successfully!DONE")
