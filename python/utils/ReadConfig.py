class ReadConfig:
    def __init__(self, config_file):
        import os
        import configparser

        try:
            parser = configparser.ConfigParser()
            try:
                path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
                print("PATH: {}".format(path))
            except Exception as ex:
                import traceback
                import sys
                ei = sys.exc_info()
                traceback.print_exception(ei[0], ei[1], ei[2], None, sys.stderr)
                del ei
                path = None

            parser.read("%s/%s" % (path, config_file))
            self.config = parser

        except Exception as ex:
            import traceback
            import sys
            ei = sys.exc_info()
            traceback.print_exception(ei[0], ei[1], ei[2], None, sys.stderr)
            del ei

            print("Exception: %s" % ex)

    def readConfig(self, section, key=None):
        """
        Read a config from a config file
        :param section: Name of a category
        :param key: Key of a config under a category
        :return: Value of a key
        """
        try:
            if key is None:
                exists = self.config.has_section(section)

                if exists:
                    return self.config.items(section)
                else:
                    print("Exists: %s" % exists)
            else:
                exists = self.config.has_option(section, key)
                if exists:

                    return self.config.get(section, key)
                else:
                    print("Exists: %s" % exists)
        except Exception as ex:
            import traceback
            import sys
            ei = sys.exc_info()
            traceback.print_exception(ei[0], ei[1], ei[2], None, sys.stderr)
            del ei

            print("Exception: %s" % ex)
