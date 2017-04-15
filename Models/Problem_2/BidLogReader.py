
import csv

class BidLogReader():
    __reader = None


#Constructor of the class
#log_file_full_path: path (with file name) to the csv file
#Return: instance of BidLogReader
    def __init__ (self, log_file_full_path):
        f = open(log_file_full_path, 'rb')
        self.__reader = csv.DictReader(f)

#GetBidLog
#Return: List of dictionaries, each dictionary is a row in the csv file.
#               -->Dictionary key: column name as defined in the csv header
#               -->Dictionary value: STRING with the content of the cell
    def GetBidLog(self):
        return list(self.__reader)

