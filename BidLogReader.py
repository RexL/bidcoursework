
import csv

class BidLogReader():
    __reader = None

    def __init__ (self, log_file_full_path):
        f = open(log_file_full_path, 'rb')
        self.__reader = csv.DictReader(f)

    def GetBidLog(self):
        return list(self.__reader)

