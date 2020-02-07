import datetime

__author__ = "Chau.Tran"


def generate_zero_day():
    """
        Zero seconds, minutes, hours of today
        :return: zeroed_today_date in milisecond
    """
    now_date = datetime.datetime.now()
    now_date_zero = datetime.datetime(now_date.year, now_date.month, now_date.day)
    now_date_zero_milis = int(now_date_zero.strftime("%s")) * 1000
    return now_date_zero_milis


def get_end_of_today():
    """
    Return last time of today in milisecond
    :return:
    """
    now_date = datetime.datetime.now()
    end_date = datetime.datetime(now_date.year, now_date.month, now_date.day, 23, 59, 59)
    end_date_milis = int(end_date.strftime("%s")) * 1000
    return end_date_milis


def is_today(today, time_milisecond):
    """
    Check time_milisecond equivalents to today
    :param today: datetime
    :param time_milisecond: time in milisecond
    :return: True/False
    """
    import datetime

    # Convert from timestamp to datetime
    time = time_milisecond / 1000
    received_date = datetime.datetime.fromtimestamp(time).date()

    # # Get today date
    # today_date = datetime.datetime.today().date()

    if received_date == today:
        return True
    return False


def generate_zero_yesterday():
    """
        Zero minutes, seconds, hours of yesterday
        :return:
    """
    now_date = datetime.datetime.now()
    yesterday_date_zero = datetime.datetime(now_date.year, now_date.month, now_date.day) - datetime.timedelta(days=1)
    yesterday_date_zero_milis = int(yesterday_date_zero.strftime("%s")) * 1000

    return yesterday_date_zero_milis

def generate_milisecond(date):

    date_zero = datetime.datetime(date.year, date.month, date.day)
    date_zero_milis = int(date_zero.strftime("%s")) * 1000

    return date_zero_milis

def generate_zero_tomorrow():
    """
        Zero minutes, seconds, hours of tomorrow
        :return:
    """
    now_date = datetime.datetime.now()
    tomorrow_date_zero = datetime.datetime(now_date.year, now_date.month, now_date.day) + datetime.timedelta(days=1)
    tomorrow_date_zero_milis = int(tomorrow_date_zero.strftime("%s")) * 1000

    return tomorrow_date_zero_milis

def generate_zero_today():
    """
        Zero minutes, seconds, hours of today
        :return:
    """
    now_date = datetime.datetime.now()
    today_date_zero = datetime.datetime(now_date.year, now_date.month, now_date.day)
    today_date_zero_milis = int(today_date_zero.strftime("%s")) * 1000

    return today_date_zero_milis

def generateBeginMonth():
    """
        Zero minutes, seconds, hours and beginning day of a month
        :return:
    """
    now_date = datetime.datetime.now()
    month_date_zero = datetime.datetime(now_date.year, now_date.month, 1)
    month_date_zero_milis = int(month_date_zero.strftime("%s")) * 1000

    return month_date_zero_milis


def getDifferentDays(from_date, to_date):
    """
        :param from_date: in miliseconds
        :param to_date:  in miliseconds
        :return: days in difference
    """
    from datetime import datetime

    return (datetime.fromtimestamp(int(to_date) / 1000).date() - datetime.fromtimestamp(int(from_date) / 1000).date()).days

def getDifferentMonths(from_date, to_date):
    """
        :param from_date: in miliseconds
        :param to_date:  in miliseconds
        :return: months in difference
    """
    from datetime import datetime

    return abs(datetime.fromtimestamp(int(to_date) / 1000).month - datetime.fromtimestamp(int(from_date) / 1000).month)


def generateDateRange(from_date=None, to_date=None, date_range=30):
    """
    If from_date is None, then to_date is datetime object
    Otherwise, to_date is string object

        :param from_date: from_date in string
        :param to_date: to_date in string
        :return: a list of from_date to to_date
    """
    import datetime

    date_ranges = []
    if from_date:
        fr_datetime = datetime.datetime.strptime(from_date, "%Y-%m-%d")
        to_datetime = datetime.datetime.strptime(to_date, "%Y-%m-%d")
        delta_days = (to_datetime - fr_datetime).days
        for i in range(delta_days):
            date_ranges.append((fr_datetime + datetime.timedelta(i)).strftime("%Y-%m-%d"))

    else:
        for i in range(date_range + 1):
            date_ranges.append((to_date - datetime.timedelta(i)).strftime("%Y-%m-%d"))

    return sorted(date_ranges)

def generateShiftedDateRange(date_list, next_days=7):
    """
    If from_date is None, then to_date is datetime object
    Otherwise, to_date is string object

        :param from_date: from_date in string
        :param to_date: to_date in string
        :return: a list of from_date to to_date
    """
    import datetime

    new_date_list = []
    datetime_objects = []

    for date in date_list:
        datetime_objects.append(datetime.datetime.strptime(date, "%Y-%m-%d"))

    for date_count in range(next_days):
        to_date = datetime_objects[-1] + datetime.timedelta(1)
        from_date = datetime_objects[1]
        datetime_objects.append(datetime_objects[-1] + datetime.timedelta(1))
        new_date_list.append(generateDateRange(from_date=from_date.strftime("%Y-%m-%d"),
                                               to_date=to_date.strftime("%Y-%m-%d")))
        datetime_objects.pop(0)

    return new_date_list

def generateContinuousDateRange(date, next_days=7):
    """
    This function to generate continuous dates from date

        :param date: the checkpoint date
        :param next_days: Number of dates to generate
        :return: a list of continuous dates
    """
    import datetime

    new_date_list = []

    datetime_objects = datetime.datetime.strptime(date, "%Y-%m-%d")

    for date_count in range(1, next_days + 1):
        datetime_objects = datetime_objects + datetime.timedelta(1)
        new_date_list.append(datetime_objects)

    return new_date_list


def generateDate(format="%Y-%m-%d"):
    """
        :param timestamp: in miliseconds
        :param format: format of output
        :return: date in format
    """
    from datetime import datetime

    now_date = datetime.now()
    today = datetime(now_date.year, now_date.month, now_date.day)
    today_date = datetime.strftime(today, format)

    return today_date


def getLastMonth():
    """
        Zero minutes, seconds, hours and beginning day of a month
        :return:
    """
    from dateutil.relativedelta import relativedelta

    now_date = datetime.datetime.now()
    now_month = datetime.datetime(now_date.year, now_date.month, 1)
    last_month = now_month - relativedelta(months=+1)

    last_month_str = datetime.datetime.strftime(last_month, "%Y-%m")

    return last_month_str


def getYesterday():
    """
        Zero minutes, seconds, hours of yesterday
        :return:
    """
    now_date = datetime.datetime.now()
    yesterday_date_zero = datetime.datetime(now_date.year, now_date.month, now_date.day) - datetime.timedelta(days=1)
    yesterday = datetime.datetime.strftime(yesterday_date_zero, "%Y-%m-%d")

    return yesterday
