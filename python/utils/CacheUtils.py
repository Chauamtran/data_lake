import time
from python.utils.LoggingUtils import Logger

__author__ = "Chau.Tran"


class Memoize(object):
    """Memoize With Timeout"""
    _caches = {}
    _timeouts = {}

    def __init__(self, timeout=3600):
        self.timeout = timeout
        self.logger_cache = Logger(name="CacheUtils")

    def clearCache(self):
        """Clear cache of results which have timed out"""
        self.logger_cache.info("> clear Cache...")

        for func in self._caches:
            cache = {}
            for key in self._caches[func]:
                if (time.time() - self._caches[func][key][1]) < self._timeouts[func]:
                    cache[key] = self._caches[func][key]
            self._caches[func] = cache

    def __call__(self, f):
        self.cache = self._caches[f] = {}
        print("cache data: {}".format(self.cache))
        self._timeouts[f] = self.timeout

        def func(*args, **kwargs):
            kw = sorted(kwargs.items())
            key = (args, tuple(kw))

            self.logger_cache.info("key: {}".format(key))

            try:
                if kw:
                    v = self.cache[kw[0]]
                else:
                    v = self.cache[key[0][1]]
                    # v = self.cache[key]
                self.logger_cache.info("cached")
                if (time.time() - v[1]) > self.timeout:
                    print("KeyError")
                    self.logger_cache.info("KeyError")
                    raise KeyError
            except KeyError:
                self.logger_cache.info("new")
                if kw:
                    v = self.cache[kw[0]] = f(*args, **kwargs), time.time()
                else:
                    v = self.cache[key[0][1]] = f(*args, **kwargs), time.time()

                # v = self.cache[key] = f(*args, **kwargs), time.time()
            return v[0]

        func.func_name = f.__name__

        return func


