__author__ = "Chau.Tran"


def Logger(name, max_MBbyte=500, log_level=None, log_file=None):
    """
    Wrap logger function with some addtional options
    :param name: Name of logger function
    :param max_MBbyte: Maximum capacity of a logger file
    :param log_level: Level to log
    :param log_file: Location to log to file
    :return:
    """
    import logging.handlers

    logger = logging.getLogger(name)
    if log_level:
        logger.setLevel(log_level)
    else:
        logger.setLevel(logging.INFO)

    formatter = logging.Formatter('%(asctime)s %(levelname)s %(name)s: %(message)s')
    if log_file:
        # print("LOGGING TO %s" % log_file)
        fh = logging.handlers.RotatingFileHandler(log_file, maxBytes=max_MBbyte * 1024 * 1024, backupCount=3)
        fh.setFormatter(formatter)
        logger.addHandler(fh)
    else:
        ch = logging.StreamHandler()
        ch.setFormatter(formatter)
        logger.addHandler(ch)
    return logger



